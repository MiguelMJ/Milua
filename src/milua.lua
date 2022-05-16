--[[
milua: Lua micro framework for web development

This is a heavily modified version of the server example in https://github.com/duarnimator/lua-http

]]

local os = require "os"
local url = require "net.url"
local signal = require "posix.signal"
local http_server = require "http.server"
local http_headers = require "http.headers"

local app = {}

local path_handlers = {
    GET = {},
    HEAD = {},
    POST = {},
    PUT = {},
    DELETE = {},
    CONNECT = {},
    OPTIONS = {},
    TRACE = {},
    PATCH = {},

}

-- A handler is a function(captures, query, headers, body) -> res_body, res_headers
function app.add_handler(method, url_pattern, handler)
    local processed_pattern = "^"..url_pattern:gsub("[.][.][.]", "([^/?]+)").."$"
    assert(path_handlers[method])
    path_handlers[method][processed_pattern] =  handler
    print("Handler added for: "..method.." "..url_pattern)
end

-- Reply function for the requests receievd by the server
local function reply(myserver, stream) -- luacheck: ignore 212
	-- Read in headers
	local req_headers = assert(stream:get_headers())
	local req_method = req_headers:get ":method"

    -- Get path
    path = req_headers:get(":path") or ""

	-- Log request to stdout
	assert(io.stdout:write(string.format('[%s] "%s %s HTTP/%g"  "%s" "%s"\n',
		os.date("%d/%b/%Y:%H:%M:%S %z"),
		req_method or "",
		path,
		stream.connection.version,
		req_headers:get("referer") or "-",
		req_headers:get("user-agent") or "-"
	)))

    assert(path_handlers[req_method])
    
    -- Default headers
    local res_headers = http_headers.new()
    res_headers:append(":status", "200")
    res_headers:append("content-type", "text/plain")
    
    -- Look for a pattern that matches the path
    path_wo_query = path:gsub("?.*", "")
    for pattern, handler in pairs(path_handlers[req_method]) do

        captures = {path_wo_query:match(pattern)}
        
        -- The pattern matches
        if #captures > 0 then
            -- Build headers table
            req_headers_table = {}
            for key, value in req_headers:each() do
                req_headers_table[key] = value
            end

            -- Call handler
            res_body, ret_res_headers = handler(
                captures, 
                url.parse(path).query,
                req_headers_table,
                stream:get_body_as_string()
            )

            -- Merge headers with defaults
            for key,value in pairs(ret_res_headers or {}) do
                res_headers:apend(key, value)
            end

            -- Send answer
            assert(stream:write_headers(res_headers, false))
            assert(stream:write_body_from_string(res_body))
            
            -- RETURN
            return
        end
        
    end
    -- If the loop ends it means that no pattern matched
    -- RETURN 404
    res_headers:append(":status", 400)
    assert(stream:write_headers(res_headers, false))
    assert(stream:write_body_from_string("Not found"))
end

function app.start(config)
    config = config or {}
    
    local myserver = assert(http_server.listen {
        host = config.host or "localhost";
        port = config.port or 8800;
        onstream = reply;
        onerror = function(myserver, context, op, err, errno) -- luacheck: ignore 212
            local msg = op .. " on " .. tostring(context) .. " failed"
            if err then
                msg = msg .. ": " .. tostring(err)
            end
            assert(io.stderr:write(msg, "\n"))
        end;
    })

    -- Manually call :listen() so that we are bound before calling :localname()
    assert(myserver:listen())
    do
        local bound_port = select(3, myserver:localname())
        assert(io.stderr:write(string.format("Now listening on port %d\n", bound_port)))
    end
    
    -- Handle a Ctrl-C interruption
    -- https://stackoverflow.com/questions/32337591/how-catch-ctrl-c-in-lua-when-ctrl-c-is-sent-via-the-command-line#34409274
    signal.signal(signal.SIGINT, function(signum)
        print("\nShuting down server")
        myserver:close()
        print("Bye")
        os.exit(128 + signum)
    end)

    -- Start the main server loop
    assert(myserver:loop())
end

return app