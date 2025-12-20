local app = require("milua")

-- Basic example
app.get(
    "/",
    function()
        return "<h1>Welcome to the <i>handsome</i> server!</h1>\n", {
            ["Content-Type"] = "text/html"
        }
    end
)

-- Example capturing a path variable
app.get(
    "/user/{username}/tell",
    function(path_params, query)
        local times = query.times or 1
        return "The user " .. path_params.username .. " is" .. (" very"):rep(times) .. " handsome\n"
    end
)

-- More complex example
app.get(
    "/user/{username}/tell/{target}",
    function(path_params, query)
        local response = path_params.username .. " tells " .. path_params.target .. " that \n"
        for key, value in pairs(query) do
            response = response .. key .. " is " .. value .. "\n"
        end
        return response
    end
)

-- Example returning no data and status
app.delete(
    "/user",
    function()
        return nil, { [":status"] = "204" }
    end
)

local config = {
    HOST = "0.0.0.0",
    PORT = "8080",
}

app.start(config)
