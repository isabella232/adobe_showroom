fx_version "bodacious"
dependency "vrp"

ui_page "nui/index.html"

client_scripts{ 
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "client.lua",
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  '@mysql-async/lib/MySQL.lua',
  "server.lua"
}

shared_script 'config.lua'

files{
  "nui/index.html",
  "nui/index.css",
  "nui/img/*",
  "nui/img/icon/*",
  "nui/showroom.js"
}