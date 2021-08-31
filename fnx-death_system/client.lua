if Config.ESX.Enable then
    ESX = exports.es_extended:getSharedObject()
end

AddEventHandler("onClientMapStart", function()
	exports.spawnmanager:spawnPlayer()
	Wait(1500)
	exports.spawnmanager:setAutoSpawn(false)
end)


local Local = {
    Death           = false,
    total_time      = Config.ESX.RespawnTime *60,
    Text            = "",
    StartDeathTimer = false,
    Press_Respawn   = false,
    Press_StartCall = false,
    Press_Revive    = false,
    Controll        = true,
    InAction        = false
}




Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsPlayerActive(PlayerId()) then
            TriggerServerEvent("fnx-death_system:spawnPed")
			break
		end
	end
end)


AddEventHandler('gameEventTriggered',function(name,data)   
    --[[
        if GetGameBuildNumber() >= 2189  then 
            CEventNetworkEntityDamage : Evento che viene triggerato quando un entità prende danno
                Argomenti = {
        
                    [1] = vittima,
                    [2] = killer,
                    [6] = se il danno è fatale,
                    [7] = causa,
                    [10] = se è stato ucciso con il melee,
                    [11] = tipo di melee,

                }
        end

    ]]
    if GetGameBuildNumber() >= 2189  then 
        if name == "CEventNetworkEntityDamage" then
            if Local.Controll then
                if tonumber(data[1]) ~= nil and tonumber(data[1]) == PlayerPedId() then
                    if tonumber(data[6]) ~= nil and tonumber(data[6]) == 1 then     
                        TriggerServerEvent("fnx-death_system:updatedeath",true)
                        if tonumber(data[2])  ~= nil then
                            if tonumber(data[2]) == -1  then
                                TriggerServerEvent("fnx-death_system:deathinfo",{
                                    type = "suicide",
                                })
                            elseif IsEntityAPed(tonumber(data[2])) then 
                                if GetPlayerServerId(NetworkGetPlayerIndexFromPed(tonumber(data[2]))) then
                                    if NetworkIsPlayerActive(NetworkGetPlayerIndexFromPed(tonumber(data[2]))) then 
                                        TriggerServerEvent("fnx-death_system:deathinfo",{
                                            type = "killed_by_player",
                                            victim = tonumber(data[1]), 
                                            killerid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(tonumber(data[2]))), 
                                            deathcause = tonumber(data[7]),
                                            deathbymeele = tonumber(data[12])
                                        })
                                    else
                                        TriggerServerEvent("fnx-death_system:deathinfo",{
                                            type = "killed_by_ped",
                                            victim = tonumber(data[1]), 
                                            killerid = tonumber(data[2]), 
                                            deathcause = tonumber(data[7]),
                                            deathbymeele = tonumber(data[12])
                                        })
                                    end
                                end
                            end
                        end
                    end
                end 
            end
        end 
    else
        while true do
            print("[ERROR] Stai usando le build: "..GetGameBuildNumber().." Per utilizzare questo script configurare le tue build ad una versione uguale o maggiore [2189]. Grazie!")
            Wait(1000)
        end
    end
end)




local ResetAllTable = function ()    
    Local.Death           = false
    Local.total_time      = Config.ESX.RespawnTime*60
    Local.Text            = ""
    Local.StartDeathTimer = false
    Local.Press_Respawn   = false
    Local.Press_StartCall = false
    Local.Press_Revive    = false   
end



local Notify = function (msg)
    SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end


local RequestanimDict = function (animazione)
    if not HasAnimDictLoaded(animazione) then
		RequestAnimDict(animazione)
		while not HasAnimDictLoaded(animazione) do
			Wait(1)
		end
	end
end

local Text = function (txt)
	SetTextFont(4)
	SetTextScale(0.0, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(txt)
    DrawText(0.5, 0.8)
end

--[[
local isDead = exports["fnx-death_system"]:getDeath()
exports["fnx-death_system"]:setControlDeath(true/false)
]]

exports('getDeath',function(c)
    return Local.Death
end)
    




exports('setControlDeath',function(bool)
    Local.Controll = bool
end)


RegisterNetEvent("fnx-death_system:updatedeath")
AddEventHandler("fnx-death_system:updatedeath", function(bool)
    Local.Death = bool
    if Local.Death then
        StartDeathFunction()
    else
        ResetAllTable()
    end
end)



RegisterNetEvent("fnx-death_system:useItem")
AddEventHandler("fnx-death_system:useItem", function(data)
    if Config.ESX.Enable then
        local pl, ds = ESX.Game.GetClosestPlayer()
        local playerPed = PlayerPedId()
        if pl ~= -1 and ds < 1.0 then
            if not Local.InAction then
                Local.InAction = true
                if data.animation.enable then
                    ESX.Streaming.RequestAnimDict( data.animation.lib, function()
                        TaskPlayAnim(playerPed,data.animation.lib,data.animation.anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                        Wait(50)
                        while IsEntityPlayingAnim(playerPed,data.animation.lib,data.animation.anim, 3) do
                            Wait(0)
                            DisableAllControlActions(0)
                        end
                        ClearPedTasks(PlayerPedId())
                    end)
                end
                TriggerServerEvent('fnx-death_system:setHeal',data,GetPlayerServerId(pl))
                Local.InAction = false
            end
        else
            if data.usenonearbyplayers then
                if not Local.InAction then
                    Local.InAction = true
                    if data.animation.enable then
                        ESX.Streaming.RequestAnimDict( data.animation.lib, function()
                            TaskPlayAnim(playerPed,data.animation.lib,data.animation.anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                            Wait(50)
                            while IsEntityPlayingAnim(playerPed,data.animation.lib,data.animation.anim, 3) do
                                Wait(0)
                                DisableAllControlActions(0)
                            end
                            ClearPedTasks(PlayerPedId())
                        end)
                    end
                    TriggerServerEvent('fnx-death_system:setHeal',data)
                    Local.InAction = false
                end
            else
                Notify(Lang["no_player_nearby"])
            end
        end
    end
end)



RegisterNetEvent("fnx-death_system:setHeal")
AddEventHandler("fnx-death_system:setHeal", function(data)
    if type(data) == "boolean" then
        Revive(data)
    else
        if tonumber(data) then
            local ped = PlayerPedId()
            local a = GetEntityHealth(ped)
            local b = 0
            if a + tonumber(data) > GetEntityMaxHealth(ped) then
                b = GetEntityMaxHealth(ped) 
            else
                b = a + tonumber(data)
            end
            SetEntityHealth(ped,b)    
        end
    end
end)

StartDeathFunction = function ()
    RequestanimDict('missarmenian2')
    RequestanimDict('get_up@directional@movement@from_knees@action')
    RequestanimDict('dead')
    RequestanimDict('move_fall')
    local playerPed = PlayerPedId()
    while Local.Death do
            ClearPedTasksImmediately(playerPed)
            if not Config.NotRpServer.SetEntityCompletelyDisableCollision then 
                SetEntityCompletelyDisableCollision(playerPed,true,true)   
            end
            if  Config.NotRpServer.SetEntityVisible then  
                SetEntityVisible(playerPed, false, false) 
            end
            if  Config.NotRpServer.SetEntityLocallyVisible then  
                SetEntityLocallyVisible(playerPed) 
            end
            if  Config.NotRpServer.SetEntityAlpha then  
                SetEntityAlpha(playerPed, 100, false) 
            end
            if  Config.NotRpServer.SetBlockingOfNonTemporaryEvents then  
                SetBlockingOfNonTemporaryEvents(playerPed, true) 
            end

        DeathAnimation()
        Wait(100)
    end
    return
end


DeathAnimation = function ()
        ClearPedTasks(PlayerPedId())
        RequestanimDict('missarmenian2')
        RequestanimDict('get_up@directional@movement@from_knees@action')
        RequestanimDict('dead')
        RequestanimDict('move_fall')
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local Ncoords = {x = (math.floor((coords.x * 10^1) + 0.5) / (10^1)),y = (math.floor((coords.y * 10^1) + 0.5) / (10^1)),z = (math.floor((coords.z * 10^1) + 0.5) / (10^1)), h = (math.floor((heading * 10^1) + 0.5) / (10^1))}
        ClearPedTasks(ped)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        ClearPedTasksImmediately(ped)
        if  Config.NotRpServer.StartScreenEffect then    
            StartScreenEffect('DeathFailOut', 0, true)        
        end
        if  Config.NotRpServer.SetPlayerHealthRechargeMultiplier then    
            SetPlayerHealthRechargeMultiplier(ped, 0.0)    
        end
        SetEntityCoordsNoOffset(ped, Ncoords.x, Ncoords.y, Ncoords.z, false, false, false, true)
        NetworkResurrectLocalPlayer(Ncoords.x, Ncoords.y, Ncoords.z, Ncoords.h, false, false)
        if  Config.NotRpServer.TaskPlayAnimland_fall then    
            TaskPlayAnim(ped, 'move_fall', 'land_fall', 8.0, -8.0, -1, 1, 0, 0, 0, 0)
        end
        Wait(1000)
        TaskPlayAnim(ped, 'missarmenian2', 'corpse_search_exit_ped', 8.0, -8.0, -1, 0, 0, 0, 0, 0)
	while Local.Death do
            if not IsEntityPlayingAnim(ped, 'missarmenian2', 'corpse_search_exit_ped', 3) then
                SetEntityInvincible(ped, true)
                ClearPedTasks(ped)
                TaskPlayAnim(ped, 'missarmenian2', 'corpse_search_exit_ped', 8.0, -8.0, -1, 0, 0, 0, 0, 0)
                SetEntityHealth(ped, GetEntityMaxHealth(ped))    
            end
            if not Config.ESX.TempRespawn then
                Local.Text = Lang["press_E_or_R"]  
                if IsControlJustPressed(0, 51) then
                    Revive()
                elseif IsControlJustPressed(0, 45)  then
                    Respawn()
                end
                Text(Local.Text)
            else
                if not Local.StartDeathTimer  then
                    Local.StartDeathTimer = true
                    StartDeathTimer()
                end
            end
        Wait(0)
	end
    return
end


local function ReturnCorretTime(time)
    if time > 60 then
		return math.floor((time/60) + 0.5)..Lang["press_Call_and_respawn_temp_min"] 
    else
        return math.floor(time + 0.5)..Lang["press_Call_and_respawn_temp_second"] 
    end
end

StartDeathTimer = function ()
	Citizen.CreateThread(function()
		while Local.total_time > 0  do
            if Local.Death then
                    Wait(1000)
                if Local.total_time > 0 then
                    Local.total_time =  Local.total_time - 1
                end
            else
                return
            end
		end
        return
    end)
    Citizen.CreateThread(function()
        while Local.Death do
                if Local.total_time > 0  then
                    Local.Text = Lang["press_Call_and_respawn_temp1"]..(ReturnCorretTime(Local.total_time) or 0)
                    if IsControlJustPressed(0, 51) then
                        if not Local.Press_StartCall  then
                            Local.Press_StartCall = true
                            StartCall()
                            Citizen.SetTimeout(60000,function ()
                                Local.Press_StartCall = false
                            end)
                        else
                            Notify(Lang["no_start_call"])
                        end
                    end
                elseif Local.total_time == 0  then    
                    Local.Text = Lang["press_E_to_respawn"] 
                    if IsControlJustPressed(0, 45)  then
                        Respawn()
                    end
                end
                Text(Local.Text)
            Wait(0)
        end
        return
    end)
end


Respawn = function ()
    if not Local.Press_Respawn then
        Local.Press_Respawn = true
        local ped =  PlayerPedId()
        if  Config.NotRpServer.SetEntityVisible then  
            SetEntityVisible(ped, true, true) 
        end
        if  Config.NotRpServer.SetEntityAlpha then  
            SetEntityAlpha(ped, 255, false) 
        end
        if  Config.NotRpServer.SetBlockingOfNonTemporaryEvents then  
            SetBlockingOfNonTemporaryEvents(ped, false) 
        end
        if  Config.NotRpServer.StartScreenEffect then    
            StopScreenEffect('DeathFailOut')
        end
        TriggerServerEvent("fnx-death_system:updatedeath",false)
        DoScreenFadeOut(800)
        while not IsScreenFadedOut() do
            Wait(10)
        end
        NetworkResurrectLocalPlayer(Config.CoordsRespawn, true, true, false)
        SetPlayerInvincible(ped, false)
        ClearPedBloodDamage(ped)
        DoScreenFadeIn(800)
    end
end

StartCall = function ()
    if Config.ESX.Enable then
        Notify(Lang["start_call"])
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        TriggerServerEvent(Config.ESX.TriggerPhone,Config.ESX.JobName,Config.ESX.CallMessage,coords,coords)
    end
end

Revive = function (data)
    if not Local.Press_Revive then
        if data == nil then Local.Press_Revive = true end
        local ped =  PlayerPedId()
        if  Config.NotRpServer.SetEntityVisible then  
            SetEntityVisible(ped, true, true) 
        end
        if  Config.NotRpServer.SetEntityAlpha then  
            SetEntityAlpha(ped, 255, false) 
        end
        if  Config.NotRpServer.SetBlockingOfNonTemporaryEvents then  
            SetBlockingOfNonTemporaryEvents(ped, false) 
        end
        if  Config.NotRpServer.StartScreenEffect then    
            StopScreenEffect('DeathFailOut')
        end
        TriggerServerEvent("fnx-death_system:updatedeath",false)
        DoScreenFadeOut(800)
        while not IsScreenFadedOut() do
            Wait(10)
        end
        NetworkResurrectLocalPlayer(GetEntityCoords(ped, true), true, true, false)
        SetPlayerInvincible(ped, false)
        ClearPedBloodDamage(ped)
        DoScreenFadeIn(800)
    end
end
