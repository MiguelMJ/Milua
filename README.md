<p align="center"><img align="center" src="doc/logo.svg" height="200px"></p>
<h1 align="center">Milua</h2>
<h3 align="center">Lua micro framework for web development</h3>
<p align="center">
<img src="https://img.shields.io/badge/Lua-5.4-2C2D72?style=flat-square&logo=lua">
<a href="https://luarocks.org/modules/miguelmj/milua"><img src="https://img.shields.io/luarocks/v/MiguelMJ/milua?style=flat-square"/></a>
<a href="https://hub.docker.com/r/miguelmj/milua-alpine"><img src="https://img.shields.io/badge/-dockerhub-2C2D72?style=flat-square&logo=docker"></a>
<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational?style=flat-square"/></a>
</p>

Milua is inspired by frameworks like Flask or Express, so it just aims to be quick to install and simple to use, enough to prototype any idea you have in mind without needing to worry too much about third-party software.

- [Preview](#preview)
- [Features](#features)
- [Installation](#installation)
  - [Troubleshooting](#troubleshooting)
- [Contributors](#contributors)
- [Alternatives](#alternatives)
- [License](#license)


## Preview

Here's a minimal example of how to use Milua:

```lua
local app = require("milua")

app.get(
    "/",
    function()
        return "<h1>Welcome to the <i>handsome</i> server!</h1>", {
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

app.start()
```

You can run an extended version of this example directly:
```bash
lua doc/examples/handsome_server.lua
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

- `get(path, callback)`. Associates a `path` to a `callback` when called with the HTTP verb GET.
    - The callback function must accept the following arguments:
        - `captures`: A table with the path parameters, that appear appear brackets in the path: `{param}`.
        - `query`: A table with the key-value pairs of the query in the URL.
        - `headers`: The headers of the HTTP request.
        - `body`: The body of the HTTP request.
    - and must return the following values:
        - The body of the repsonse.
        - (Optional) A table with the headers of the response.
- Equivalent functions for all other HTTP verbs: `post`, `put`, `patch`, `delete`, etc.

- `shutdown_hook(func)` where `func` is a function which will be called before closing the server.

- `start(config)` where `config` contains the `host` and the `port` to run the application.
- `logger` table with support for `INFO`, `DEBUG`, and `ERROR` logging levels
    - usage:
        - `logger:INFO("this is an info message")`
        - `logger:ERROR("this is an error message")`
        - `logger:DEBUG("this is a debug message")`
    - How to custom logger levels:
        - `logger:add_logger("INFO", function(...) print("THIS A TEMPLATE", logger.format(...)) end)`
- `config` table with support for getting configuration values from environment variables as well as .env files
    - This also lets you extend the config table with a new table where if you define an empty value for a key it will try to get it from a `.env` file or the os environment
    - example: 
        ```lua
        local config = require("milua_config")

        config:extend({
            DB_NAME="name",
            DB_PASS="pass",
            DB_HOST="host",
            HOST="localhost",
            STDOUT="localhost",
            MY_SECRET_KEY=""
        })
        
        config.add_config("NEW_KEY", "NEW_VALUE")
        
        app.start(config)
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

### Troubleshooting

You may want to install Milua as with the `--local` flag via Luarocks. In that case you will need to install `luaossl` as a local dependency too. 
In Debian (derived) system this is solved easily with the installation of `libssl-dev`. 
But, on Arch (derived) systems, the installation of OpenSSL variants/versions (which include headers files) will not solve the installation problem. Because `luaossl` is a prerequisite for Milua, Arch base systems will not finish successfully the installation of Milua complaining about not being able to compile a `ssl.o` file. 
And most of the documentation online will suggest to provide manually the `OPENSSL_INCDIR` path pointing to the `include/ssl.h` file, which will not fix the issue.

The solution is to install previously the `luaossl` library with a proper flag, like this: 

```bash
CFLAGS="-Wno-error=incompatible-pointer-types" luarocks install --local luaossl
```
After that you can install `Milua` with the `--local` flag as usual.

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MiguelMJ"><img src="https://avatars.githubusercontent.com/u/37369782?v=4?s=100" width="100px;" alt="MiguelMJ"/><br /><sub><b>MiguelMJ</b></sub></a><br /><a href="#creator-MiguelMJ" title="Creator">☕</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/wmb1207"><img src="https://avatars.githubusercontent.com/u/89983571?v=4?s=100" width="100px;" alt="wmb1207"/><br /><sub><b>wmb1207</b></sub></a><br /><a href="https://github.com/MiguelMJ/Milua/commits?author=wmb1207" title="Code">💻</a> <a href="https://github.com/MiguelMJ/Milua/commits?author=wmb1207" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rdleal"><img src="https://avatars.githubusercontent.com/u/54686430?v=4?s=100" width="100px;" alt="rdleal"/><br /><sub><b>rdleal</b></sub></a><br /><a href="https://github.com/MiguelMJ/Milua/commits?author=rdleal" title="Code">💻</a> <a href="https://github.com/MiguelMJ/Milua/commits?author=rdleal" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dhhyi"><img src="https://avatars.githubusercontent.com/u/23452927?v=4?s=100" width="100px;" alt="Danilo Hoffmann"/><br /><sub><b>Danilo Hoffmann</b></sub></a><br /><a href="https://github.com/MiguelMJ/Milua/commits?author=dhhyi" title="Code">💻</a> <a href="#example-dhhyi" title="Examples">💡</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://mutabit.com"><img src="https://avatars.githubusercontent.com/u/5748170?v=4?s=100" width="100px;" alt="Offray Vladimir Luna Cárdenas"/><br /><sub><b>Offray Vladimir Luna Cárdenas</b></sub></a><br /><a href="https://github.com/MiguelMJ/Milua/commits?author=offray" title="Documentation">📖</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## Alternatives
There are great frameworks and libraries also written in Lua. I personally find that none satisfies at the same time the requirements I had when creating Milua, but maybe you'll find one better suited for your needs.

- [Lapis](https://github.com/leafo/lapis)
- [Pegasus.lua](https://github.com/EvandroLG/pegasus.lua)

## License
Milua is licensed under the [MIT license](LICENSE), a copy of which you can find in the repository.
