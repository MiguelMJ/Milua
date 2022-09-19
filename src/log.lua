-- Logging support for milua

STDOUT_LOG_CONFIG = "MILUA_STDOUT"
STDERR_LOG_CONFIG = "MILUA_STDERR"

-- Local functions

local logger = {}

local outputs = {
    -- Dispatch table to write to the stderr or stdout
    ["stderr"] = function(msg)
        io.stderr:write(msg)
    end,
    ["stdout"] = function(msg)
        io.stdout:write(msg)
    end
}

local function dump_table(tbl)
    -- parameters
    --  tbl: table
    -- return: string
    -- A quick and easy way to dump a complete table into an string
    -- this is really useful for logging
    local output = '{ '
    for key, value in pairs(tbl) do
        print(key,value)
        if type(key) ~= 'number' then key = '"'..key..'"' end
        if type(value) == 'table' then value = dump_table(value) end
        output = output .. '['..key..'] = ' .. value .. ','
    end
    return output .. '} '
end

local function errors_stream()
    return os.getenv(STDERR_LOG_CONFIG) or "stderr"
end

local function output_stream()
    return os.getenv(STDOUT_LOG_CONFIG) or "stdout"
end

local function format(...)
    -- paramenetrs
    --   ANY
    -- returns: string
    -- Format all the arguments passed to the function into a valid
    -- strig
    local msg = ''
    for _, value in pairs({...}) do
        if (type(value) == 'table') then
            msg = msg..dump_table(value)..' '
        else
            msg = msg..tostring(value)..' '
        end
    end
    return msg
end

local function default_formatter(lvl, ...)
    return string.format("[%s] %s: %s\n", lvl, os.date("%c"), format(...))
end

local function default_logger(lvl)
    local std_out = output_stream()
    local std_err = errors_stream()
    local stream

    if lvl == "ERROR" then
        stream = std_err
    else
        stream = std_out
    end
    return function (msg)
        if (outputs[stream]) then
            outputs[stream](default_formatter(lvl, msg))
            return
        end

        local file = io.open(stream, "a")
        assert(file)
        file:write(default_formatter(lvl, msg))
        file:close()
    end
end

-- LOGGER

logger = {
    DEBUG = default_logger("DEBUG");
    INFO = default_logger("INFO");
    ERROR = default_logger("ERROR");
    format = format;
}

function logger:add_logger(lvl, logger_fn)
    assert(self[lvl])
    self[lvl] = logger_fn
end

return logger

