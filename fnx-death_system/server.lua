if Config.ESX.Enable then ESX = exports.es_extended:getSharedObject() end

local Death = {}

local GetIdentifier = function (src)
    for k,v in ipairs(GetPlayerIdentifiers(src)) do
        if string.match(v, Config.identifier) then
            if Config.identifier == 'license:' then
                return string.gsub(v, 'license:', '')
            end
            return  v
        end
    end
end



if Config.ESX.Enable then
    AddEventHandler(Config.ESX.EventLoaded,function (src,xPlayer)
        local identifier = GetIdentifier(src)
        if Death[identifier] == nil then
            MySQL.Async.fetchAll('SELECT isdead FROM users WHERE identifier = @identifier', {
                ['@identifier'] = identifier
            }, function(result) 
                if result ~= nil then
                    if result[1].isdead > 0 or result[1].isdead then
                        Death[identifier] = true
                    else
                        Death[identifier] = false
                    end
                    TriggerClientEvent("fnx-death_system:updatedeath",src,Death[identifier])        
                end
            end)
        else
            TriggerClientEvent("fnx-death_system:updatedeath",src,Death[identifier])        
        end
    end) 

    for x, data in pairs(Config.ESX.Item) do
        ESX.RegisterUsableItem(data.name, function(source)
            local xPlayer = ESX.GetPlayerFromId(source)
            if data.forcejobusage then
                if xPlayer.job.name ~= Config.ESX.JobName then
                    return
                end
            end
            TriggerClientEvent('fnx-death_system:useItem', source, data)
        end)
    end

    RegisterServerEvent("fnx-death_system:setHeal")
    AddEventHandler("fnx-death_system:setHeal",function (data,target)
        local src = source
        if data.removeitem then
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer.getInventoryItem(data.name) and xPlayer.getInventoryItem(data.name).count > 0 then
                xPlayer.removeInventoryItem(data.name, 1)
            else
                return
            end 
        end
        if target == nil then target = src end
        if data.revive then
            TriggerClientEvent("fnx-death_system:setHeal",target,true)
        else
            TriggerClientEvent("fnx-death_system:setHeal",target,data.healt)
        end
    end)
 
else
    RegisterServerEvent("fnx-death_system:spawnPed")
    AddEventHandler("fnx-death_system:spawnPed",function ()
        local src = source
        local identifier = GetIdentifier(src)
        if Death[identifier] == nil then
            Death[identifier] = false
        end
        Wait(2500)
        TriggerClientEvent("fnx-death_system:updatedeath",src,Death[identifier])
    end)
end   


for name, data in pairs(Config.Command) do
    RegisterCommand(name,function (src,args)
        local group = false
        if src ~= 0 then
            if data.forcejobusage then
                if Config.ESX.Enable then
                    local xPlayer = ESX.GetPlayerFromId(src)
                    if data.onlygroup then
                        if data.group[xPlayer.getGroup()] == nil then
                            return
                        else
                            group = true
                        end
                    end
                    if data.job[xPlayer.job.name] or group then
                        if data.revive then
                            if #args > 0 and tonumber(args[1]) then
                                TriggerClientEvent("fnx-death_system:setHeal",tonumber(args[1]),true)
                            else
                                TriggerClientEvent("fnx-death_system:setHeal",src,true)
                            end
                        else
                            if #args > 0 and tonumber(args[1]) then
                                data.action(GetPlayerPed(tonumber(args[1]))) 
                            else
                                data.action(GetPlayerPed(src)) 
                            end
                        end
                    end
                end
            else
                if data.revive then
                    if #args > 0 and tonumber(args[1]) then
                        TriggerClientEvent("fnx-death_system:setHeal",tonumber(args[1]),true)
                    else
                        TriggerClientEvent("fnx-death_system:setHeal",src,true)
                    end
                else
                    if #args > 0 and tonumber(args[1]) then
                        data.action(GetPlayerPed(tonumber(args[1]))) 
                    else
                        data.action(GetPlayerPed(src)) 
                    end
                end
            end
        end
    end)
end





RegisterServerEvent("fnx-death_system:deathinfo")
AddEventHandler("fnx-death_system:deathinfo",function (table)
    local src = source
    if Config.Using_mxm_kd_sistem then
        if table.type == "killed_by_player" then
            TriggerEvent("fnx-kd_system:UpdateKD","kill",false,table.killerid)
            TriggerEvent("fnx-kd_system:UpdateKD","morte",false,src) 
        end
    end
    if Config.Using_fnx_killfeed then
        local victimname = GetPlayerName(src)
        local killername = GetPlayerName((table.killerid or src))
        local death = (table.deathcause or "suicide")
        if table.type == "suicide" then death = "suicide" end
        TriggerClientEvent("fnx-killfeed:addKill",-1,{
            killer =  killername,
            victim =  victimname,
            weapon =  death
        })
    end
end)


RegisterServerEvent("fnx-death_system:updatedeath")
AddEventHandler("fnx-death_system:updatedeath",function (bool)
    local src = source 
    local identifier = GetIdentifier(src)
    if Death[identifier] ~= bool then Death[identifier] = bool else return end
    TriggerClientEvent("fnx-death_system:updatedeath",src,Death[identifier])
end)






AddEventHandler('playerDropped', function()
	local src = source
    if Config.ESX.Enable then
        local identifier = GetIdentifier(src)
        if identifier then
            if Death[identifier] ~= nil then
                MySQL.Async.execute('UPDATE users SET isdead = @isdead WHERE identifier = @identifier', {
                    ['@isdead'] = Death[identifier], 
                    ["@identifier"] = identifier
                }, function(c2)
                end)
            end 
        end
    end
end)


























