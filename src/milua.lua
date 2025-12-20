--[[
milua: Lua micro framework for web development

This file is a mostly rewritten version of https://github.com/duarnimator/lua-http
]]

local os = require "os"
local url = require "net.url"
local signal = require "posix.signal"
local http_server = require "http.server"
local http_headers = require "http.headers"
local logger = require "milua_log"

local app = {}
local path_handlers = {}
local default_response_headers = http_headers.new()
default_response_headers:append(":status", "200")

function app.add_callback(method, path_pattern, callback)
    local path_param_pattern = "{([^}]+)}"
    local path_param_names = {}
    for path_param_name in path_pattern:gmatch(path_param_pattern) do
        table.insert(path_param_names, path_param_name)
    end

    local final_pattern = "^" .. path_pattern:gsub(path_param_pattern, "([^/?]+)") .. "$"
    if (path_handlers[final_pattern] == nil) then
        path_handlers[final_pattern] = {}
    end
    if (path_handlers[final_pattern][method] ~= nil) then
        logger.ERROR("Cannot add repeated endpoint: " .. method .. " " .. final_pattern)
        os.exit()
    end

    path_handlers[final_pattern][method] = { callback = callback, param_names = path_param_names }
end

for _, http_verb in ipairs({ "GET", "HEAD", "POST", "PUT", "DELETE", "CONNECT", "OPTIONS", "TRACE", "PATCH" }) do
    app[http_verb:lower()] = function(url_pattern, callback)
        app.add_callback(http_verb, url_pattern, callback)
    end
end

local headers_to_table = function(headers)
    local headers_table = {}
    for key, value in headers:each() do
        headers_table[key] = value
    end

    return headers_table
end

local captures_to_named_params = function(params, captures)
    local named_params = {}
    for i, param in ipairs(params) do
        named_params[param] = captures[i]
    end

    return named_params
end

local send_answer = function(stream, headers, body)
    local result = stream:write_headers(headers, false)
    if (not (result)) then
        logger.ERROR(string.format("Could not write response headers: %s", headers))
    end
    if (body) then
        result = stream:write_body_from_string(body, false)
        if (not (result)) then
            logger.ERROR(string.format("Could not write response body: %s", headers))
        end
    end
end

local send_method_not_allowed = function(stream)
    local response_headers = default_response_headers:clone()
    response_headers:upsert(":status", "405")
    response_headers:upsert("content-type", "text/plain")
    send_answer(stream, response_headers, "Method not allowed")
end

local send_not_found = function(stream)
    local response_headers = default_response_headers:clone()
    response_headers:upsert(":status", "404")
    response_headers:upsert("content-type", "text/plain")
    send_answer(stream, response_headers, "Not found")
end

local send_internal_server_error = function(stream, body)
    local response_headers = default_response_headers:clone()
    response_headers:upsert(":status", "500")
    response_headers:upsert("content-type", "text/plain")
    send_answer(stream, response_headers, body)
end

local function reply(stream) -- luacheck: ignore 212
    local req_headers = assert(stream:get_headers())
    local req_method = req_headers:get ":method"
    local req_path = req_headers:get(":path") or ""

    logger.INFO(
        string.format(
            '"%s %s HTTP/%g" "%s" "%s"',
            req_method or "",
            req_path,
            stream.connection.version,
            req_headers:get("referer") or "-",
            req_headers:get("user-agent") or "-"
        )
    )

    local req_url = url.parse(req_path):normalize()
    local pattern, method_handlers = next(path_handlers)
    local is_resolved = false

    while (not (is_resolved) and pattern ~= nil and method_handlers ~= nil) do
        local captures = { req_url.path:match(pattern) }
        is_resolved = #captures > 0

        if is_resolved then
            local response_headers = default_response_headers:clone()
            local handler = method_handlers[req_method]
            if (handler == nil) then
                send_method_not_allowed(stream)
                return
            end
            local response_body, user_headers = handler.callback(
                captures_to_named_params(handler.param_names, captures),
                req_url.query,
                headers_to_table(req_headers),
                stream:get_body_as_string()
            )

            for key, value in pairs(user_headers or {}) do
                response_headers:upsert(string.lower(key), value)
            end

            send_answer(stream, response_headers, response_body)
        else
            pattern, method_handlers = next(path_handlers, pattern)
        end
    end

    if (not (is_resolved)) then
        send_not_found(stream)
    end
end

local onstream = function(_, stream) -- luacheck: ignore 212
    xpcall(
        reply,
        function(err)
            logger.ERROR(string.format("Error handling request: %s", err))
            send_internal_server_error(stream, err)
        end,
        stream
    )
end

local function onerror(myserver, context, op, err, errno) -- luacheck: ignore 212
    local msg = op .. " on " .. tostring(context) .. " failed"
    if err then
        msg = msg .. ": " .. tostring(err)
    end
    logger.ERROR(msg)
end

local onshutdown = function() return nil end

function app.start(config)
    config = config or {}
    local myserver = assert(http_server.listen {
        host = config.HOST or "0.0.0.0",
        port = config.PORT or 8800,
        onstream = onstream,
        onerror = onerror,
    })

    -- Manually call :listen() so that we are bound before calling :localname()
    local err, error_msj = pcall(myserver:listen())
    if err then
        logger.ERROR(error_msj)
        os.exit()
    end

    do
        local bound_port = select(3, myserver:localname())
        logger.INFO(string.format("Now listening on port %d", bound_port))
    end

    -- Handle a Ctrl-C interruption
    -- https://stackoverflow.com/questions/32337591/how-catch-ctrl-c-in-lua-when-ctrl-c-is-sent-via-the-command-line#34409274
    signal.signal(signal.SIGINT, function(signum)
        logger.INFO("Shuting down server")
        onshutdown()
        myserver:close()
        logger.INFO("Server shutdown")
        os.exit(128 + signum)
    end)

    assert(myserver:loop())
end

function app.shutdown_hook(func)
    assert(type(func) == "function", "parameter to shutdown_hook must be a function")
    onshutdown = func
end

return app
