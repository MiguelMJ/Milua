--- Base Config model for milua
-- .env file > environment variables
-- This will let you define a complete table based on all the environment variables that start with MILUA_
-- Or with the valuas from a .env file.
-- You can setup the name of the env file based on the enviroment variable MILUA_ENV_FILE
local utils = require("milua_utils")

PORT_CONFIG = "MILUA_PORT"
HOST_CONFIG = "MILUA_HOST"
ENV_CMD = "env | grep MILUA_"
ENV_FILE = ".env"

local Config = {
    PORT=8800,
    HOST="localhost",
    STDOUT="stdout",
    STDERR="stderr"
}

--- get_key_value_env, get the key, value from an environment variable starting with MILUA_
-- The '_' Is really important don't forget about it.
-- @param str_env environment variable (string)
-- @return key, value (stirng, string)
-- @usage env_key, env_value = get_key_value_env("MILUA_DB=supersecretdatabasename")
local function get_key_value_env(str_env)
    local value = string.gsub(str_env, "^(.*)=", '')
    local key = string.gsub(str_env, "=(.*)", '')
    return key, value
end

--- Config:from_env, get the config values from the environment variables 
-- @return self (Config)
-- @usage Config:from_env()
function Config:from_env()
    self.PORT = os.getenv(PORT_CONFIG) or self.PORT
    self.HOST = os.getenv(HOST_CONFIG) or self.HOST

    local env_result = io.popen(ENV_CMD, "r")
    assert(env_result)
    local env_as_string = env_result:read('*a')

    for line in env_as_string:gmatch("([^\n]*)\n?") do
        local env_var = string.gsub(line, "MILUA_", '')
        local key, value = get_key_value_env(env_var)
        if (self[key] ~= nil and utils.is_empty(self[key])) then self[key] = value end
    end
    return self
end

--- Config:from_env_file, get the config values from the .env file
-- @return self (Config)
-- @usage Config:from_env_file()
function Config:from_env_file()
    local env_file = Config.ENV_FILE or ENV_FILE
    local opened_env_file = io.open(env_file, "r")
    if not(opened_env_file) then return Config end
    opened_env_file:close() -- We just tested that the file exists
    for line in io.lines(env_file) do
        local key, value = get_key_value_env(line)
        if (Config[key] ~= nil and utils.is_empty(Config[key])) then Config[key] = value end
    end
    return Config
end

--- Config:add_config, Append a new key value pair to the Config table
-- @return self (Config)
-- @usage Config:add_config("CONFIG_KEY", "CONFIG_VALUE")
function Config:add_config(key, value)
    assert(key)
    assert(value)
    self[key] = value
    return self
end

--- Config:extend, Extend the config table based on a new table 
-- If you pass a key value pair where the value is empty ("", 0, {})
-- It will get it from the env_file or the env
-- @return self (Config)
-- @usage Config:extend(
--    DB_NAME="name",
--    DB_PASS="pass",
--    DB_HOST="host",
--    HOST="",
--    STDOUT="",
-- )
function Config:extend(cnf)
    assert(cnf)
    assert(type(cnf) == 'table')

    for key, value in pairs(cnf) do self[key] = value end
    self:from_env_file()
    self:from_env()
    return self
end

Config:from_env_file()
Config:from_env()

return Config
