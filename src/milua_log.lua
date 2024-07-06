local utilities = require("milua_utils")
local config = require("milua_config")

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

--- format, create an string that represents any variable
-- @param ... any amount of variables (any)
-- @return msg (string)
-- @usage str = format(variable_a, variable_b, variable_c)
local function format(...)
    local msg = ''
    for _, value in pairs({ ... }) do
        if (type(value) == 'table') then
            msg = msg .. utilities.dump_table(value) .. ' '
        else
            msg = msg .. tostring(value) .. ' '
        end
    end
    return msg
end

--- default_formatter, defalut function to format the log output
-- @param lvl the log lvl to use (string)
-- @param ... any amount of variables (any)
-- @return msg (string)
-- @usage str = default_formatter('INFO', variable_a, variable_b, variable_c)
local function default_formatter(lvl, ...)
    return string.format("[%s] %s: %s\n", lvl, os.date("%c"), format(...))
end

--- default_logger, get a logger with the default configs
-- @param lvl the log lvl to use (string)
-- @return function(msg) (function(string))
-- @usage logger = default_logger('INFO'); logger('this is a pretty good message')
local function default_logger(lvl)
    local std_out = config.STDOUT
    local std_err = config.STDERR
    local stream

    if lvl == "ERROR" then
        stream = std_err
    else
        stream = std_out
    end
    return function(msg)
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
    DEBUG = default_logger("DEBUG"),
    INFO = default_logger("INFO"),
    ERROR = default_logger("ERROR"),
    format = format,
}

--- logger:add_logger, add a custom logger function to the logger table
-- @param lvl the log lvl to use (string)
-- @param logger_fn the logger function (function)
-- @usage logger:add_logger("INFO", function(...)
--     print("THIS IS A CUSTOM LOGGER ", logger.format(...))
-- end
function logger:add_logger(lvl, logger_fn)
    assert(self[lvl])
    self[lvl] = logger_fn
end

return logger
