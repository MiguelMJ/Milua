local app = require "milua"

-- Basic example
app.add_handler(
    "GET",
    "/",
    function()
        return "<h1>Welcome to the handsome server!</h1>"
    end
)

-- Example capturing a path variable
app.add_handler(
    "GET",
    "/user/...", 
    function (captures, query, headers)

        local username = captures[1]
        local times = query.times or 1
        return "The user " .. username .. " is" .. (" very"):rep(times) .. " handsome"
    
    end
)

app.start()