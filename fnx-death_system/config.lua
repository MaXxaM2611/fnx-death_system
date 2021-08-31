Config = {

    ESX = {
        Enable      = true,
        RespawnTime = 5 , --Minuti
        TempRespawn = true,
        TriggerPhone    = "esx_addons_gcphone:startCall",
        CallMessage     = "Aiuto sono ferito, Ecco la mia posizione",
        EventLoaded     = 'esx:playerLoaded',
        JobName         = "ambulance",
        Item = {
            {
                name = "medikit",
                healt = 200,
                revive = true,
                removeitem = true,
                forcejobusage = true,
                usenonearbyplayers = false,
                animation = {
                    enable = true,
                    lib = "anim@heists@narcotics@funding@gang_idle",
                    anim = "gang_chatting_idle01",
                }
            },
            {
                name = "bandage",
                healt = 75,
                revive = false,
                removeitem = true,
                forcejobusage = false,
                usenonearbyplayers = true,
                animation = {
                    enable = true,
                    lib = "anim@heists@narcotics@funding@gang_idle",
                    anim = "gang_chatting_idle01",
                }
            }
        }
    },

    Command = {
        ["_revive"] = {
            onlygroup = true,
            group = {
                ["admin"]       = true,
                ["superadmin"]  = true,
            },
            forcejobusage = true,
            job = {
                ["police"] = true,
                ["medici"] = true
            },
            revive = true
        },
        
        ["_armour"] = {
            onlygroup = false,
            group = {
                ["admin"]       = true,
                ["superadmin"]  = true,
            },
            forcejobusage = true,
            job = {
                ["police"] = true,
                ["medici"] = true
            },   
            action = function (ped)
                SetPedArmour(ped,200)
            end        
        },
    },


    identifier  = 'license:',

    CoordsRespawn = vector3(0,0,0),

    Using_fnx_killfeed = false,
    
    Using_mxm_kd_sistem = false,

    NotRpServer = {
        StartScreenEffect                    = true,
        SetPlayerHealthRechargeMultiplier    = true,
        TaskPlayAnimland_fall                = true,
        SetEntityCompletelyDisableCollision  = false,
        SetEntityVisible                     = false,
        SetEntityLocallyVisible              = false,
        SetEntityAlpha                       = false,
        SetBlockingOfNonTemporaryEvents      = false,
    },

}


Lang = {
    ["start_call"]                          = "Hai Chiamato i medici, Potrai richiamare i medici tra 5 minuti",
    ["no_start_call"]                       = "Hai Gia chiamato i medici aspetta prima di poter richiamare",
    ["press_E_or_R"]                        = " Premi ~g~[E]~w~ per rianimarti \nPremi ~r~[R]~w~ per Respawnare",
    ["press_Call_and_respawn_temp1"]        = " Premi ~g~[E]~w~ per chiamare i soccorsi,  \nPotrai respawnare tra ",
    ["press_Call_and_respawn_temp_second"]  = " secondi",
    ["press_Call_and_respawn_temp_min"]     = " minuti",
    ["press_E_to_respawn"]                  = " Premi ~r~[R]~w~ per Respawnare",
    ["no_player_nearby"]                    = "Nessun player vicino"
}


