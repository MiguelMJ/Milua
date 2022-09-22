<p align="center"><img align="center" src="doc/logo.svg" height="200px"></p>
<h1 align="center">Milua</h2>
<h3 align="center">Lua micro framework for web development</h3>
<p align="center">
<img src="https://img.shields.io/badge/Lua-5.4-2C2D72?style=flat-square&logo=lua">
<img src="https://img.shields.io/luarocks/v/MiguelMJ/milua?style=flat-square"/>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational?style=flat-square"/></a>
</p>

Milua is inspired by frameworks like Flask or Express, so it just aims to be quick to install and simple to use, enough to prototype any idea you have in mind without needing to worry too much about third-party software.

- [Preview](#preview)
- [Features](#features)
- [Installation](#installation)
- [Alternatives](#alternatives)
- [License](#license)


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

Right now the `milua` module only offers:

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
- `logger` table with support for INFO, DEBUG, and ERROR logging levels
    - usage:
        - `logger:INFO("this is an info message")`
        - `logger:ERROR("this is an error message")`
        - `logger:DEBUG("this is a debug message")`
    - How to custom logger levels:
        - `logger:add_logger("INFO", function(...) print("THIS A TEMPLATE", logger.format(...)) end)`
- `config` table with support for getting configuration values from environment variables as well as .env files
    - This also let's you extend the config table with a new table where if you define an emty value for a key it will try to get it from a .env file or the os environment
    - example: 
        ```lua
        local Config = require("milua_config")

        Config:extend({
            DB_NAME="name",
            DB_PASS="pass",
            DB_HOST="host",
            HOST="localhost",
            STDOUT="localhost",
            WOLOLOLO=""
        })
        
        Config.add_config("NEW_KEY", "NEW_VALUE")
        
        app.start(Config)
        ```

## Installation
You can install it directly from luarocks:
```bash
luarocks install milua
```
Alternatively, install it from the root of the directory of the repository.
```bash
git clone https://github.com/MiguelMJ/Milua
cd Milua
sudo luarocks make
```

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## Alternatives
There are great frameworks and libraries also written in Lua. I personally find that none satisfies at the same time the requirements I had when creating Milua, but maybe you'll find one better suited for your needs.

- [Lapis](https://github.com/leafo/lapis)
- [Pegasus.lua](https://github.com/EvandroLG/pegasus.lua)

## License
Milua is licensed under the [MIT license](LICENSE), a copy of which you can find in the repository.
