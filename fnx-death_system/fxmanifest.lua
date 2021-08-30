fx_version 'cerulean'

game 'gta5'

description 'Fnx Death System'

author 'MaXxaM#0511'

version '1.0'

client_script {
    "config.lua",
    "client.lua"
}
  
server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server.lua"
}