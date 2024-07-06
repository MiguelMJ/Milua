--- Utilities library from the milua project


--- to_data_dict, get a new table that contains all the data and no functions
-- @param tbl the table to process (table)
-- @return new_table (table)
-- @usage data = utilities.to_data_dict(tbl)
local function to_data_dict(tbl)
    local new_table = {}

    for key, value in pairs(tbl) do
        local value_type = type(value)
        if value_type ~= 'function' then
            if value_type == 'table' then new_table[key] = to_data_dict(value) end
            new_table[key] = value
        end
    end
    return new_table
end

--- is_empty, check if a variable is an empty value
-- if the value is a number then the empty value is 0
-- if the value is an string then the empty value is ""
-- if the value is a table then the empty value is {}
-- @param value the table to process (any)
-- @return bool (bool)
-- @usage if utilities.is_empty(variable) then
local function is_empty(value)
    assert(value)
    local defaults = {
        ["number"] = function() return value == 0 end,
        ["string"] = function() return value == "" end,
        ["table"] = function() return #value == 0 end
    }
    return defaults[type(value)]
end

--- dump_table, create an string that represents a table
-- @param tbl the table to process (table)
-- @return output (string)
-- @usage tbl_str = utilities.dump_table(tbl)
local function dump_table(tbl)
    -- parameters
    --  tbl: table
    -- return: string
    -- A quick and easy way to dump a complete table into an string
    -- this is really useful for logging
    local output = '{ '

    for key, value in pairs(tbl) do
        if type(value) ~= 'function' then
            if type(key) ~= 'number' then key = '"' .. key .. '"' end
            if type(value) == 'table' then value = dump_table(value) end
            output = output .. '[' .. key .. '] = ' .. value .. ','
        end
    end
    return output .. '} '
end

local utilities = {
    to_data_dict = to_data_dict,
    dump_table = dump_table,
    is_empty = is_empty
}

return utilities
