package = "kong-plugin-upstream-basic-auth-encrypted" 
version = "0.3.0-1"  

local pluginName = package:match("^kong%-plugin%-(.+)$")

supported_platforms = {"linux", "macosx"}
source = {
  url = "https://github.com/svenwal/kong-plugin-upstream-basic-auth-encrypted",
  tag = "0.3.0"
}

description = {
  summary = "A Kong plugin providing the ability to authenticate against an upstream backend using basic with the password being stored encrypted in the database",
  homepage = "https://github.com/svenwal/kong-plugin-upstream-basic-auth-encrypted",
  license = "Apache 2.0"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
  }
}