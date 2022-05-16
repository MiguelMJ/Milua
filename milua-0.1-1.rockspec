package = "milua"
version = "0.1-1"
source = {
   url = "git+https://github.com/MiguelMJ/Milua",
   tag = "v0.1"
}
description = {
   summary = "Micro framework for web applications",
   homepage = "https://github.com/MiguelMJ/Milua",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.4",
   "http ~> 0.4",
   "net-url ~> 1.1-1",
   "luaposix ~> 35.1-1"
}
build = {
   type = "builtin",
   modules = {
      milua = "src/milua.lua"
   }
}
