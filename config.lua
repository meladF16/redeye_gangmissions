Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DEL'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

--- 
--- It use script progressbar, if you don't want use this, just change in client.lua (453 - 475)
--- 


Config = {}

Config.Core = "QB-Core" -- "ESX" / "QB-Core"
Config.CoreExport = function()
  --  return exports['es_extended']:getSharedObject()
    return exports['qb-core']:GetCoreObject()
end

--@Menu: "esx_menu_default" / "esx_context" / "qb-menu" / "ox_lib"
--@Menu: If you leave it empty, you will not be able to use the menu from this script, but you can then replace it with e.g. vms_npctalk
Config.Menu = "qb-menu"

--@PlayerLoaded: ESX: "esx:playerLoaded" | QBCore: "QBCore:Client:OnPlayerLoaded"
Config.PlayerLoaded = 'QBCore:Client:OnPlayerLoaded' -- its a trigger to load players tattoos

--@JobUpdated: ESX: "esx:setJob" | QBCore: "QBCore:Client:OnGangUpdate"
Config.JobUpdated = 'QBCore:Client:OnGangUpdate' -- its a trigger to check players job / gang

Config.Notification = function(message, time, type)
    if type == "success" then
     --   exports["vms_notify"]:Notification("CRIME MISSION", message, time, "#E10011", "fa-solid fa-star")
        -- TriggerEvent('esx:showNotification', message)
        TriggerEvent('QBCore:Notify', message, 'success', time)
    elseif type == "error" then
      --  exports["vms_notify"]:Notification("CRIME MISSION", message, time, "#E10011", "fa-solid fa-star")
        -- TriggerEvent('esx:showNotification', message)
       TriggerEvent('QBCore:Notify', message, 'error', time)
    end
end

Config.KeyAccess = "E"
Config.BossDistance = 1.65
Config.RewardMoneyType = "cash" -- "cash", "bank", "black_money"

Config.MinimumPolice = 0

Config.EnemiesPedsVisibleForAll = true -- Enemy peds that are respawned will be visible to every player

Config.Translate = {
    ["money_recieved"] = "You recieved <b>%s$</b>",
    ["must_wait"] = "You must wait %s:%s to begin this mission.",
    ["choose_mission"] = "[~y~%s~s~] Choose a mission",
    ["collect_money"] = "[~g~%s~w~] To collect money",

    ["return_to_boss"] = "Return for money!",
    ["return_vehicle"] = "Press [~g~E~s~] to return the vehicle",
    ["return_kidnapped"] = "Press [~g~E~s~] to return the kidnapped",
    
    ["go_for_money"] = "Go pick up the money",
    ["not_this_vehicle"] = "It's not that vehicle!",
    ["not_in_vehicle"] = "The kidnapped is not in your vehicle!",

    ["blip_go_to_boss"] = "Collect Money",
    
    ["menu.select_mission"] = "Select Mission",

    ["murder"] = "Kill one guy, after the task is done, come back for cash!",
    ["blip.murder"] = "Person To Kill",

    ["kidnap"] = "Kidnap someone for me and bring him here!",
    ["blip.kidnap"] = "Person To Be Kidnapped",

    ["drug_stealing"] = "Steal the drug truck for me and bring me this here!",
    ["blip.drug_stealing"] = "Drug Truck",

    ["car_stealing"] = "Steal the car with license plate <b>%s</b> for me, after the task is done, come here with it and claim the cash!",
    
    ["money_extortion"] = "Extort a money, after the task is done, go back for cash!",
    ["blip.money_extortion"] = "Money Extortion",
    ["steal_money"] = "[~r~E~s~] Steal money",
    ["stealing_money"] = "Stealing money...",

    ["too_few_cops"] = "There are too few police officers for you to start this mission",
}

Config.SpawnGangPeds = true
Config.Gangs = {
    [1] = { -- if you set as a number, for example, [1], [2], [3] etc. then this ped will be public and anyone can use its mission.
        Ped = nil,
        PedCoords = vector4(-622.66, 312.33, 82.93, 201.06),
        PedModel = 'ig_ballasog',
        Animation = {"anim@heists@humane_labs@finale@strip_club", "ped_b_celebrate_loop"},
        CarDelivery = vector3(-627.72, 290.9, 80.76),
        LockedOrders = {}
    },
    ["ballas"] = { -- if you set as a string, e.g. ["ballas"], ["vagos"] etc. then this ped will only be available to that job/gang and only they can use its mission.
        Ped = nil,
        PedCoords = vector4(112.32, -1961.98, 19.95, 17.81),
        PedModel = 'ig_ballasog',
        Animation = {"anim@heists@humane_labs@finale@strip_club", "ped_b_celebrate_loop"},
        CarDelivery = vector3(103.13, -1957.23, 19.75),
        LockedOrders = {}
    },
    -- ["vagos"] = {
    --     Ped = nil,
    --     PedCoords = vec(-129.74, 1002.18, 234.73),
    --     PedModel = 'ig_vagspeak',
    --     Animation = {"anim@heists@humane_labs@finale@strip_club", "ped_b_celebrate_loop"},
    --     CarDelivery = vector4(-130.84, 1005.78, 234.73, 93.44),
    --     LockedOrders = {}
    -- },
}

Config.Missions = {
    [1] = {
        MissionLabel = "Murder",
        Timeout = 5000,
        MoneyReward = math.random(1000, 5000),
        Mission = {
            [1] = {
                coords = vector4(1374.11, -580.0, 73.85, 89.98),
                ped = 'ig_fbisuit_01',
            },
            [2] = {
                coords = vector4(230.8, -1535.95, 28.74, 307.87),
                ped = 'ig_fbisuit_01',
            },
            [3] = {
                coords = vector4(-1320.34, -458.11, 32.79, 40.74),
                ped = 'ig_fbisuit_01',
            },
            [4] = {
                coords = vector4(354.73, 2627.72, 44.0, 29.79),
                ped = 'ig_fbisuit_01',
            },
        }
    },
    [2] = {
        MissionLabel = "Kidnap",
        Timeout = 5000,
        MoneyReward = math.random(1000, 5000),
        Mission = {
            [1] = {
                coords = vector4(1374.11, -580.0, 73.85, 89.98),
                ped = 'cs_barry',
            },
            [2] = {
                coords = vector4(230.8, -1535.95, 28.74, 307.87),
                ped = 'ig_bestmen',
            },
            [3] = {
                coords = vector4(-1320.34, -458.11, 32.79, 40.74),
                ped = 'a_m_m_business_01',
            },
            [4] = {
                coords = vector4(354.73, 2627.72, 44.0, 29.79),
                ped = 's_m_y_devinsec_01',
            },
        }
    },
    [3] = {
        MissionLabel = "Steal Drug Truck",
        Timeout = 5000,
        MoneyReward = math.random(1000, 5000),
        Mission = {
            [1] = {
                coords = vector4(1731.08, 3312.0, 40.46, 175.57),
                vehicleModel = 'mule2',
                peds = {
                    {coords = vector4(1734.08, 3312.99, 40.22, 202.5), weapon = "weapon_assaultrifle", model = "a_m_m_og_boss_01", ped},
                    {coords = vector4(1743.39, 3311.83, 40.22, 101.2), weapon = "weapon_microsmg", model = "u_m_y_proldriver_01", ped},
                    {coords = vector4(1739.58, 3325.33, 40.22, 160.67), weapon = "weapon_microsmg", model = "ig_ramp_mex", ped},
                    {coords = vector4(1716.19, 3316.08, 40.22, 219.18), weapon = "weapon_microsmg", model = "g_m_y_salvaboss_01", ped},
                    {coords = vector4(1717.38, 3311.64, 40.22, 196.91), weapon = "weapon_microsmg", model = "ig_terry", ped},
                    {coords = vector4(1723.11, 3293.85, 40.22, 287.83), weapon = "weapon_microsmg", model = "ig_hunter", ped},
                    {coords = vector4(1720.59, 3291.25, 40.21, 262.07), weapon = "weapon_microsmg", model = "s_m_y_dealer_01", ped},
                    {coords = vector4(1731.05, 3312.29, 43.91, 167.52), weapon = "weapon_microsmg", model = "a_m_m_hillbilly_02", ped},
                },
            },
            [2] = {
                coords = vector4(1514.54, -2145.85, 76.38, 95.95),
                vehicleModel = 'mule3',
                peds = {
                    {coords = vector4(1517.79, -2147.56, 76.27, 279.83), weapon = "weapon_assaultrifle", model = "ig_joeminuteman", ped},
                    {coords = vector4(1523.48, -2151.26, 76.47, 353.55), weapon = "weapon_microsmg", model = "g_m_m_chicold_01", ped},
                    {coords = vector4(1515.49, -2145.47, 79.83, 271.59), weapon = "weapon_microsmg", model = "s_m_y_dealer_01", ped},
                    {coords = vector4(1500.19, -2131.43, 75.19, 235.81), weapon = "weapon_microsmg", model = "ig_g", ped},
                    {coords = vector4(1500.6, -2153.8, 78.04, 312.33), weapon = "weapon_microsmg", model = "a_m_m_hillbilly_02", ped},
                    {coords = vector4(1496.04, -2145.99, 75.88, 308.49), weapon = "weapon_microsmg", model = "ig_hao", ped},
                    {coords = vector4(1512.95, -2135.97, 78.79, 232.65), weapon = "weapon_microsmg", model = "ig_chengsr", ped},
                    {coords = vector4(1524.32, -2140.76, 76.05, 215.46), weapon = "weapon_microsmg", model = "csb_imran", ped},
                    {coords = vector4(1544.24, -2141.98, 76.81, 91.01), weapon = "weapon_microsmg", model = "a_m_y_hiker_01", ped},
                    {coords = vector4(1544.32, -2135.49, 76.82, 124.76), weapon = "weapon_microsmg", model = "mp_m_exarmy_01", ped},
                },
            },
        },
    },
    [4] = {
        MissionLabel = "Car Stealing",
        Timeout = 5000,
        MoneyReward = math.random(1000, 5000),
        RandomPlate = "VMS "..math.random(1000, 9999),
        Mission = {
            [1] = {         
                blipCircle = vector3(1056.22, -482.96, 62.83),
                blipRadius = 170.0,
                coords = vector4(1056.22, -482.96, 62.83, 80.13),
                vehicleModel = 'rhinehart',
            },
            [2] = {         
                blipCircle = vector3(855.4, -518.73, 56.3),
                blipRadius = 180.0,
                coords = vector4(855.4, -518.73, 56.3, 43.94),
                vehicleModel  = 'vigero2',
            },
            [3] = {
                blipCircle = vector3(-603.23, 190.6, 69.52),
                blipRadius = 195.0,
                coords = vector4(-603.23, 190.6, 69.52, 340.5),
                vehicleModel  = 'postlude',
            },
            [4] = {
                blipCircle = vector3(-470.81, 74.88, 57.66),
                blipRadius = 195.0,
                coords = vector4(-470.81, 74.88, 57.66, 318.1),
                vehicleModel  = 'baller7',
            },
            [5] = {
                blipCircle = vector3(-1531.66, -287.94, 47.84),
                blipRadius = 195.0,
                coords = vector4(-1531.66, -287.94, 47.84, 140.72),
                vehicleModel  = 'deity',
            },
            [6] = {
                blipCircle = vector3(109.77, 316.31, 111.12),
                blipRadius = 195.0,
                coords = vector4(109.77, 316.31, 111.12, 157.57),
                vehicleModel  = 'buffalo4',
            },
        }
    },
    [5] = {
        MissionLabel = "Money Extortion",
        Timeout = 5000,
        MoneyReward = math.random(1000, 5000),
        Mission = {
            [1] = {
                coords = vector4(11.61, -1605.32, 28.39, 178.55),
                ped = {coords = vector4(11.61, -1605.32, 28.39, 178.55), weapon = "weapon_microsmg", model = "g_m_y_famca_01", ped}
            }
        },
    },
}