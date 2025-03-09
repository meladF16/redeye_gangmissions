local selectedPed = nil
local missionComplete = false
local selectedMission = nil
local isDelivery = false
local currentVehicle, currentPed = nil, nil
local PlayerData = {}

Citizen.CreateThread(function()
    Citizen.Wait(250)
    if Config.Menu == "ox_lib" then
        local import = LoadResourceFile('ox_lib', 'init.lua')
        local chunk = assert(load(import, '@@ox_lib/init.lua'))
        chunk()
    end
end)

if Config.Core == "ESX" then
    ESX = Config.CoreExport()

    RegisterNetEvent(Config.PlayerLoaded)
    AddEventHandler(Config.PlayerLoaded, function(xPlayer)
        PlayerData = xPlayer
    end)
    
    RegisterNetEvent(Config.JobUpdated)
    AddEventHandler(Config.JobUpdated, function(job)
        PlayerData.job = job 
    end)

elseif Config.Core == "QB-Core" then
    QBCore = Config.CoreExport()

    RegisterNetEvent(Config.PlayerLoaded, function()
        CreateThread(function()
            PlayerData = QBCore.Functions.GetPlayerData()
        end)
    end)

    RegisterNetEvent(Config.JobUpdated, function(GangInfo)
        PlayerData.gang = GangInfo
    end)
end

RegisterNetEvent("redeye_gangmissions:cl:notification", function(msg, time, type)
	Config.Notification(msg, time, type)
end)

RegisterNetEvent("redeye_gangmissions:start", function(missionNumber)
	if missionNumber then
        if Config.Core == "ESX" then
            ESX.TriggerServerCallback("redeye_gangmissions:server:checkTime", function(canStart)
                if canStart then
                    startMission(missionNumber)
                end
            end, missionNumber, selectedPed)
        elseif Config.Core == "QB-Core" then
            QBCore.Functions.TriggerCallback('redeye_gangmissions:server:checkTime', function(canStart)
                if canStart then
                    startMission(missionNumber)
                end
            end, missionNumber, selectedPed)
        end
	end
end)

Citizen.CreateThread(function()
    if Config.SpawnGangPeds then
        for k, v in pairs(Config.Gangs) do
            requestModel(v.PedModel)
		    v.Ped =  CreatePed(4, v.PedModel, v.PedCoords.x, v.PedCoords.y, v.PedCoords.z, v.PedCoords.w, false, true)
		    SetEntityHeading(v.Ped, v.PedCoords.w)
		    FreezeEntityPosition(v.Ped, true)
		    SetEntityInvincible(v.Ped, true)
		    SetBlockingOfNonTemporaryEvents(v.Ped, true)
		    if v.Animation then
                startAnim(v.Ped, v.Animation[1], v.Animation[2], -1, 1)
		    end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = true
        local myPed = PlayerPedId()
		local myCoords = GetEntityCoords(myPed)
        for k, v in pairs(Config.Gangs) do
            if tonumber(k) or Config.Core == "ESX" and (PlayerData.job and k == PlayerData.job.name) or Config.Core == "QB-Core" and (PlayerData.gang and k == PlayerData.gang.name) then
                if isDelivery then
                    local distanceDelivery = #(myCoords - v.CarDelivery)
                    if distanceDelivery < 7.5 then
                        sleep = false
                        DrawText3D(v.CarDelivery.x, v.CarDelivery.y, v.CarDelivery.z + 1.0, Config.Translate[currentVehicle and "return_vehicle" or currentPed and "return_kidnapped"]:format(Config.KeyAccess))
                        DrawMarker(0, v.CarDelivery, 0, 0, 0, 0, 0, 0, 1.85, 1.85, 1.85, 205, 25, 0, 125, false, false, false, false, false, false, false)
                        if IsControlJustPressed(0, Keys[Config.KeyAccess]) then
                            local myVehicle = GetVehiclePedIsIn(myPed, false)
                            if currentVehicle then
                                if myVehicle == currentVehicle then
                                    isDelivery = false
                                    DeleteVehicle(myVehicle)
                                    currentVehicle = nil
                                    Config.Notification(Config.Translate["go_for_money"], 4500, "success")
                                else
                                    Config.Notification(Config.Translate["not_this_vehicle"], 4500, "error")
                                end
                            elseif currentPed then
                                if IsPedInVehicle(currentPed, myVehicle, true) then
                                    isDelivery = false
                                    DeletePed(currentPed)
                                    currentPed = nil
                                    Config.Notification(Config.Translate["go_for_money"], 4500, "success")
                                else
                                    Config.Notification(Config.Translate["not_in_vehicle"], 4500, "error")
                                end
                            end
                        end
                    end
                else
                    local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(v.PedCoords.x, v.PedCoords.y, v.PedCoords.z))
                    if distance < 25.0 then
                        sleep = false
                        if distance < Config.BossDistance then
                            if missionComplete and selectedMission then
                                if not isDelivery then
                                    DrawText3D(v.PedCoords.x, v.PedCoords.y, v.PedCoords.z + 1.0, Config.Translate["collect_money"]:format(Config.KeyAccess))
                                    if IsControlJustPressed(0, Keys[Config.KeyAccess]) then
                                        TriggerServerEvent("redeye_gangmissions:sv:payout", selectedMission, selectedPed)
                                        selectedPed = nil
                                        selectedMission = nil
                                        missionComplete = false
                                        RemoveBlip(bossBlip)
                                    end
                                end
                            elseif Config.Menu ~= "" and not selectedMission then
                                if not selectingMissionMenu then
                                    DrawText3D(v.PedCoords.x, v.PedCoords.y, v.PedCoords.z + 1.0, Config.Translate["choose_mission"]:format(Config.KeyAccess))
                                    if IsControlJustPressed(0, Keys[Config.KeyAccess]) then
                                        selectingMissionMenu = true
                                        if Config.Core == "ESX" and Config.Menu == "esx_menu_default" then
                                            local elements = {}
                                            for _k, _v in pairs(Config.Missions) do
                                                elements[#elements+1] = {label = _v.MissionLabel, value = _k}
                                            end
                                            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mission_selector', {
                                                title =  Config.Translate["menu.select_mission"],
                                                elements = elements,
                                                align = 'left',
                                            }, function(data, menu)
                                                if data.current.value then
                                                    selectedPed = k
                                                    TriggerEvent('redeye_gangmissions:start', data.current.value)
                                                end
                                                selectingMissionMenu = false
                                                menu.close()
                                            end, function(data, menu)
                                                menu.close()
                                                selectingMissionMenu = false
                                            end)
                                        elseif Config.Core == "ESX" and Config.Menu == "esx_context" then
                                            local elements = {
                                                {unselectable = true, title = Config.Translate["menu.select_mission"]},
                                            }
                                            for _k, _v in pairs(Config.Missions) do
                                                elements[#elements+1] = {title = _v.MissionLabel, value = _k}
                                            end
                                            ESX.OpenContext('left', elements, function(menu, element)
                                                ESX.CloseContext()
                                                selectedPed = k
                                                TriggerEvent('redeye_gangmissions:start', element.value)
                                                selectingMissionMenu = false
                                            end)
                                        elseif Config.Core == "QB-Core" and Config.Menu == "qb-menu" then
                                            local elements = {
                                                {
                                                    header = Config.Translate["menu.select_mission"],
                                                    isMenuHeader = true,
                                                },
                                            }
                                            for _k, _v in pairs(Config.Missions) do
                                                elements[#elements+1] = {
                                                    header = _v.MissionLabel,
                                                    params = {
                                                        isAction = true,
                                                        event = function()
                                                            selectedPed = k
                                                            TriggerEvent('redeye_gangmissions:start', _k)
                                                            selectingMissionMenu = false
                                                        end,
                                                    }
                                                }
                                            end
                                            exports['qb-menu']:openMenu(elements)
                                        elseif Config.Menu == "ox_lib" then
                                            local elements = {}
                                            for _k, _v in pairs(Config.Missions) do
                                                elements[#elements + 1] = {
                                                    title = _v.MissionLabel, 
                                                    onSelect = function()
                                                        selectedPed = k
                                                        TriggerEvent('redeye_gangmissions:start', _k)
                                                        selectingMissionMenu = false
                                                    end
                                                }
                                            end
                                            lib.registerContext({
                                                id = "redeye_gangmissions",
                                                title = Config.Translate["menu.select_mission"],
                                                options = elements
                                            })
                                            lib.showContext('redeye_gangmissions')
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if selectingMissionMenu then
                        selectingMissionMenu = false
                    end
                end
            end
        end
        Citizen.Wait(sleep and 1000 or 1)
    end
end)

function startMission(missionNumber)
	selectedMission = missionNumber
    local randomMission = math.random(1, #Config.Missions[missionNumber].Mission)
    local thisMission = Config.Missions[missionNumber].Mission[randomMission]
    if missionNumber == 1 then
        Config.Notification(Config.Translate["murder"], 4500, "success")
        local missionBlip = AddBlipForCoord(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z)	
		SetBlipSprite(missionBlip, 84)
		SetBlipDisplay(missionBlip, 4)
		SetBlipScale(missionBlip, 1.5)
		SetBlipColour(missionBlip, 1)
		SetBlipAsShortRange(missionBlip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.Translate['blip.murder'])
		EndTextCommandSetBlipName(missionBlip)
        Citizen.CreateThread(function()
            while true do
                local myPed = PlayerPedId()
			    local myCoords = GetEntityCoords(myPed)
                local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z))
                if distance < 100.0 then
                    local pedModel = thisMission.ped
                    requestModel(pedModel)
                    RemoveBlip(missionBlip)
                    missionPed = CreatePed(1, pedModel, thisMission.coords.x, thisMission.coords.y, thisMission.coords.z + 1.0, 0.0, Config.EnemiesPedsVisibleForAll, true)
                    SetBlockingOfNonTemporaryEvents(missionPed, true)
                    TaskWanderInArea(missionPed, thisMission.coords.x, thisMission.coords.y, thisMission.coords.z, 100.0, 5, 1.0)
                    missionBlip = AddBlipForEntity(missionPed)
                    SetBlipSprite(missionBlip, 84)
		            SetBlipDisplay(missionBlip, 4)
		            SetBlipScale(missionBlip, 1.5)
		            SetBlipColour(missionBlip, 1)
		            SetBlipAsShortRange(missionBlip, true)
		            BeginTextCommandSetBlipName("STRING")
		            AddTextComponentString(Config.Translate['blip.murder'])
		            EndTextCommandSetBlipName(missionBlip)
                    while true do
                        local myPed = PlayerPedId()
			            local myCoords = GetEntityCoords(myPed)
                        local npcCoords = GetEntityCoords(missionPed)
                        local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(npcCoords.x, npcCoords.y, npcCoords.z))
                        if IsPedDeadOrDying(missionPed, 1) then
                            Config.Notification(Config.Translate["return_to_boss"], 4500, "success")
                            RemoveBlip(missionBlip)
                            Citizen.Wait(3000)
                            DeletePed(missionPed)
                            missionComplete = true
                            CreateBossBlip()
                            break
                        end
                        if distance > 150.0 then
                            RemoveBlip(missionBlip)
                            DeletePed(missionPed)
                            missionComplete = false
                            selectedMission = nil
                            break
                        end
                        Citizen.Wait(5)
                    end
                    break
                end
                Citizen.Wait(500)
            end
        end)
    elseif missionNumber == 2 then
        Config.Notification(Config.Translate["kidnap"], 4500, "success")
        local missionBlip = AddBlipForCoord(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z)	
		SetBlipSprite(missionBlip, 84)
		SetBlipDisplay(missionBlip, 4)
		SetBlipScale(missionBlip, 1.5)
		SetBlipColour(missionBlip, 1)
		SetBlipAsShortRange(missionBlip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.Translate['blip.kidnap'])
		EndTextCommandSetBlipName(missionBlip)
        Citizen.CreateThread(function()
            while true do
                local myPed = PlayerPedId()
			    local myCoords = GetEntityCoords(myPed)
                local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z))
                if distance < 100.0 then
                    local pedModel = thisMission.ped
                    requestModel(pedModel)
                    missionPed = CreatePed(1, pedModel, thisMission.coords.x, thisMission.coords.y, thisMission.coords.z + 1.0, 0.0, Config.EnemiesPedsVisibleForAll, true)
                    SetPedDiesWhenInjured(missionPed, true)
                    SetBlockingOfNonTemporaryEvents(missionPed, true)
                    SetEntityInvincible(missionPed, true)
                    while true do
                        local myPed = PlayerPedId()
			            local myCoords = GetEntityCoords(myPed)
                        local npcCoords = GetEntityCoords(missionPed)
                        local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(npcCoords.x, npcCoords.y, npcCoords.z))
                        local aiming, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                        if aiming then
                            if target == missionPed and not IsEntityPlayingAnim(missionPed, 'missminuteman_1ig_2', 'handsup_enter', 1) then
                                startAnim(missionPed, 'missminuteman_1ig_2', 'handsup_enter', -1, 50)
                                TaskTurnPedToFaceEntity(missionPed, myPed, 1000)
                            end
                            if GetEntityType(target) == 2 and IsEntityPlayingAnim(missionPed, 'missminuteman_1ig_2', 'handsup_enter', 1) then
                                TaskEnterVehicle(missionPed, target, -1, 0, 2.0, 1)
                                RemoveBlip(missionBlip)
						        currentPed = missionPed
                                missionComplete = true
                                CreateBossBlip(true)
                                break
                            end
                        end
                        if IsPedDeadOrDying(missionPed, 1) or distance > 150.0 then
                            RemoveBlip(missionBlip)
                            DeletePed(missionPed)
                            missionComplete = false
                            selectedMission = nil
                            break
                        end
                        Citizen.Wait(5)
                    end
                    break
                end
                Citizen.Wait(500)
            end
        end) 
    elseif missionNumber == 3 then
        Config.Notification(Config.Translate["drug_stealing"], 15000, "success")
        local missionBlip = AddBlipForCoord(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z)	
        SetBlipSprite(missionBlip, 635)
		SetBlipDisplay(missionBlip, 4)
		SetBlipScale(missionBlip, 1.5)
		SetBlipColour(missionBlip, 1)
		SetBlipAsShortRange(missionBlip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.Translate['blip.drug_stealing'])
		EndTextCommandSetBlipName(missionBlip)
        Citizen.CreateThread(function()
            while true do
                local sleep = true
                local myPed = PlayerPedId()
                local myCoords = GetEntityCoords(myPed)
                local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z))
                if distance < 100.0 then
                    sleep = false
                    if not currentVehicle then
                        if Config.Core == "ESX" then
                            ESX.Game.SpawnVehicle(thisMission.vehicleModel, vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z), thisMission.coords.w, function(vehicle)
                                currentVehicle = vehicle
                                SetVehicleNumberPlateText(vehicle, "")
                                AddRelationshipGroup('MISSION_NPC')
                                SetPedRelationshipGroupHash(myPed, GetHashKey("MYPED"))
                                for k, v in pairs(thisMission.peds) do
                                    requestModel(v.model)
                                    v.ped = CreatePed(1, v.model, v.coords.x, v.coords.y, v.coords.z + 0.5, v.coords.w, Config.EnemiesPedsVisibleForAll, true)
                                    SetPedCombatMovement(v.ped, 2)
                                    SetPedCombatRange(v.ped, 2)
                                    GiveWeaponToPed(v.ped, GetHashKey(v.weapon), 250, false, true)
                                    SetPedDropsWeaponsWhenDead(v.ped, false)
                                    SetPedRelationshipGroupHash(v.ped, GetHashKey("MISSION_NPC"))
                                end
                                SetRelationshipBetweenGroups(0, GetHashKey("MYPED"), GetHashKey("MISSION_NPC"))
                                SetRelationshipBetweenGroups(0, GetHashKey("MISSION_NPC"), GetHashKey("MYPED"))
                            end)
                        elseif Config.Core == "QB-Core" then
                            QBCore.Functions.SpawnVehicle(thisMission.vehicleModel, function(vehicle)
                                currentVehicle = vehicle
                                SetVehicleNumberPlateText(vehicle, "")
                                AddRelationshipGroup('MISSION_NPC')
                                SetPedRelationshipGroupHash(myPed, GetHashKey("MYPED"))
                                SetEntityHeading(vehicle, thisMission.coords.w)
                                for k, v in pairs(thisMission.peds) do
                                    requestModel(v.model)
                                    v.ped = CreatePed(1, v.model, v.coords.x, v.coords.y, v.coords.z + 0.5, v.coords.w, Config.EnemiesPedsVisibleForAll, true)
                                    SetPedCombatMovement(v.ped, 2)
                                    SetPedCombatRange(v.ped, 2)
                                    GiveWeaponToPed(v.ped, GetHashKey(v.weapon), 250, false, true)
                                    SetPedDropsWeaponsWhenDead(v.ped, false)
                                    SetPedRelationshipGroupHash(v.ped, GetHashKey("MISSION_NPC"))
                                end
                                SetRelationshipBetweenGroups(0, GetHashKey("MYPED"), GetHashKey("MISSION_NPC"))
                                SetRelationshipBetweenGroups(0, GetHashKey("MISSION_NPC"), GetHashKey("MYPED"))
                            end, vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z), true, false)
                        end
                    end
                    while distance > 35.0 do
                        local myCoords = GetEntityCoords(myPed)
                        distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z))
                        Citizen.Wait(25)
                    end
                    for k, v in pairs(thisMission.peds) do
                        TaskCombatPed(v.ped, myPed, 0, 16)
                    end
                    while true do
                        local myPed = PlayerPedId()
                        if IsPedSittingInVehicle(myPed, currentVehicle) then
                            RemoveBlip(missionBlip)
                            missionComplete = true
                            CreateBossBlip(true)
                            break
                        end
                        Citizen.Wait(1)
                    end
                    break
                end	
                Citizen.Wait(sleep and 1000 or 2)
            end
        end)
    elseif missionNumber == 4 then
        local randomizedPlate = Config.Missions[missionNumber].RandomPlate
        Config.Notification((Config.Translate["car_stealing"]):format(randomizedPlate), 15000, "success")
        local missionBlip = AddBlipForRadius(thisMission.blipCircle, thisMission.blipRadius)
        SetBlipHighDetail(missionBlip, true)
        SetBlipColour(missionBlip, 5)
        SetBlipAlpha(missionBlip, 150)
        SetBlipAsShortRange(missionBlip, true)
        Citizen.CreateThread(function()
			while true do
                local sleep = true
				local myPed = PlayerPedId()
				local myCoords = GetEntityCoords(myPed)
                local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z))
				if distance < 100.0 then
                    sleep = false
                    if Config.Core == "ESX" then
                        ESX.Game.SpawnVehicle(thisMission.vehicleModel, vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z), thisMission.coords.w, function(vehicle)
                            currentVehicle = vehicle
                            SetVehicleNumberPlateText(vehicle, randomizedPlate)
                        end)
                    else
                        QBCore.Functions.SpawnVehicle(thisMission.vehicleModel, function(vehicle)
                            currentVehicle = vehicle
                            SetVehicleNumberPlateText(vehicle, randomizedPlate)
                            SetEntityHeading(vehicle, thisMission.coords.w)
                        end, vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z), true, false)
                    end
                    while true do
                        local myPed = PlayerPedId()
                        if IsPedSittingInVehicle(myPed, currentVehicle) then
                            RemoveBlip(missionBlip)
                            missionComplete = true
                            CreateBossBlip(true)
                            break
                        end
                        Citizen.Wait(1)
                    end
					break
                end	
				Citizen.Wait(sleep and 1000 or 2)
			end
		end)
    elseif missionNumber == 5 then
        Config.Notification(Config.Translate["money_extortion"], 4500, "success")
        missionBlip = AddBlipForCoord(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z)	
		SetBlipSprite(missionBlip, 685)
		SetBlipDisplay(missionBlip, 4)
		SetBlipScale(missionBlip, 1.5)
		SetBlipColour(missionBlip, 1)
		SetBlipAsShortRange(missionBlip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(Config.Translate["blip.money_extortion"])
		EndTextCommandSetBlipName(missionBlip)
        Citizen.CreateThread(function()
            local randomAction = math.random(1, 2)
            while true do
                local myPed = PlayerPedId()
			    local myCoords = GetEntityCoords(myPed)
                local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(thisMission.coords.x, thisMission.coords.y, thisMission.coords.z))
                if distance < 100.0 then
                    requestModel(thisMission.ped.model)
                    thisMission.ped.ped = CreatePed(1, thisMission.ped.model, thisMission.ped.coords.x, thisMission.ped.coords.y, thisMission.ped.coords.z, thisMission.ped.coords.w, Config.EnemiesPedsVisibleForAll, true)
                    if randomAction == 1 then
                        SetPedCombatMovement(thisMission.ped.ped, 2)
                        SetPedCombatRange(thisMission.ped.ped, 2)
                        GiveWeaponToPed(thisMission.ped.ped, GetHashKey(thisMission.ped.weapon), 250, false, true)
                        SetPedDropsWeaponsWhenDead(thisMission.ped.ped, false)
                    end
                    while true do
                        local myPed = PlayerPedId()
			            local myCoords = GetEntityCoords(myPed)
                        local npcCoords = GetEntityCoords(thisMission.ped.ped)
                        local distance = #(vec(myCoords.x, myCoords.y, myCoords.z) - vec(npcCoords.x, npcCoords.y, npcCoords.z))
                        local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
                        if aiming and not IsPedAPlayer(targetPed) then
                            if randomAction == 1 and targetPed == thisMission.ped.ped then
                                TaskCombatPed(thisMission.ped.ped, myPed, 0, 16)
                            elseif randomAction == 2 and targetPed == thisMission.ped.ped then
                                if not thisMission.ped.isPlayingAnim then
                                    TaskSetBlockingOfNonTemporaryEvents(thisMission.ped.ped, true)
                                    SetPedFleeAttributes(thisMission.ped.ped, 0, 0)
                                    SetPedCombatAttributes(thisMission.ped.ped, 17, 1)
                                    SetPedSeeingRange(thisMission.ped.ped, 0.0)
                                    SetPedHearingRange(thisMission.ped.ped, 0.0)
                                    SetPedAlertness(thisMission.ped.ped, 0)
                                    SetPedKeepTask(thisMission.ped.ped, true)
                                    startAnim(thisMission.ped.ped, 'missminuteman_1ig_2' , 'handsup_base', -1, 50)
                                    thisMission.ped.isPlayingAnim = true
                                end
                            end
                        end
                        if randomAction == 1 and IsPedDeadOrDying(thisMission.ped.ped, 1) then
                            randomAction = 2
                        elseif randomAction == 2 then
                            local pedCoords = GetEntityCoords(thisMission.ped.ped)
                            if #(myCoords - pedCoords) < 2.5 then
                                DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z+1.0, Config.Translate['steal_money'])
                                if IsControlJustPressed(0, 38) then
                                    startAnim(myPed, 'anim@gangops@facility@servers@bodysearch@', 'player_search', -1, 56)
                                    exports['progressbar']:Progress({
                                        name = "unique_action_name",
                                        duration = 4250,
                                        label = Config.Translate['stealing_money'],
                                        useWhileDead = false,
                                        canCancel = false,
                                        controlDisables = {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                    }, function(status)
                                        if not status then
                                            ClearPedTasks(myPed)
                                            RemoveBlip(missionBlip)
                                            missionComplete = true
                                            CreateBossBlip()
                                            Citizen.Wait(5000)
                                            thisMission.ped.isPlayingAnim = false
                                            DeletePed(thisMission.ped.ped)
                                        end
                                    end)
                                    break
                                end
                            end
                        end
                        if distance > 150.0 then
                            RemoveBlip(missionBlip)
                            DeletePed(thisMission.ped.ped)
                            thisMission.ped.isPlayingAnim = false
                            missionComplete = false
                            selectedMission = nil
                            break
                        end
                        Citizen.Wait(2)
                    end
                    break
                end
                Citizen.Wait(500)
            end
        end)
    end
end

function CreateBossBlip(deliveryBlip)
    local myBoss = Config.Gangs[selectedPed].PedCoords
    bossBlip = AddBlipForCoord(myBoss.x, myBoss.y, myBoss.z)	
	SetBlipSprite(bossBlip, 500)
	SetBlipDisplay(bossBlip, 4)
	SetBlipScale(bossBlip, 1.0)
	SetBlipColour(bossBlip, 2)
	SetBlipAsShortRange(bossBlip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Config.Translate["blip_go_to_boss"])
	EndTextCommandSetBlipName(bossBlip)
    SetBlipRoute(bossBlip, true)
    SetBlipRouteColour(bossBlip, 2)
    if deliveryBlip then
        isDelivery = true
    end
end

function requestModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(1)
    end
end

function startAnim(ped, animDict, anim, duration, flag)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(0)
	end
	TaskPlayAnim(ped, animDict, anim, 8.0, -8.0, duration, flag, 0, false, false, false)
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextDropShadow()
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end