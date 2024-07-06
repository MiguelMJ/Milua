local app = require("milua")

-- Basic example
app.add_handler(
    "GET",
    "/",
    function()
        return "<h1>Welcome to the <i>handsome</i> server!</h1>", {
            ["Content-Type"] = "text/html"
        }
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

-- Example returning no data and status
app.add_handler(
    "DELETE",
    "/user",
    function ()
        return nil, { [":status"] = "204" }
    end
)

app.start()
