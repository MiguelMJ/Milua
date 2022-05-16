# Milua
Lua micro framework for web development

## Preview

`examples/handsome_server.lua`
```lua
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
```
You can run the example directly:
```bash
lua examples/handsome_server.lua
```
And test it with `curl`:
```output
$ curl localhost:8800/
<h1>Welcome to the handsome server!</h1> 

$ curl localhost:8800/user/foo
The user foo is very handsome

$ curl localhost:8800/user/foo?times=3
The user foo is very very very handsome
```

## Features
Milua is inspired by frameworks like Flask, so it just aims to be quick to install and simple to use, enough to prototype any idea you have in mind without needing to worry too much about third-party software.

Right now the `milua` module only offers two functions:

- `add_handler(method, path, handler)` to associate a method and a path to a handler.
    - The handler function must accept the following arguments:
        - `captures`: An array with the variables fields of the path, specified with `...`.
        - `query`: A table with the key-value pairs of the query in the URL.
        - `headers`: The headers of the HTTP request.
        - `body`: The body of the HTTP request.
    - and must return the following values:
        - The body of the repsonse.
        - (Optional) A table with the headers of the response.

- `start(config)` where `config` contains the `host` and the `port` to run the application.

## Build
You can install it from the root of the directory using `luarocks`.
```bash
git clone https://github.com/MiguelMJ/Milua
cd Milua
sudo luarocks make
```

## License
Milua is licensed under the [MIT license](LICENSE), a copy of which you can find in the repository.