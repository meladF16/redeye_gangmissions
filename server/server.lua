if Config.Core == "ESX" then
    ESX = Config.CoreExport()

    ESX.RegisterServerCallback('redeye_gangmissions:server:checkTime', function(source, cb, missionType, selectedPed)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local missionTable = Config.Missions[missionType]
        local selectedMission = Config.Gangs[selectedPed] and Config.Gangs[selectedPed].LockedOrders
        local minimumPolices = Config.MinimumPolice >= 1 and (#ESX.GetExtendedPlayers('job', 'police') >= Config.MinimumPolice) or Config.MinimumPolice == 0 and true
        if minimumPolices then
            if not selectedMission[missionType] or (os.time() - missionTable.Timeout) > selectedMission[missionType] then
                selectedMission[missionType] = os.time()
                cb(true)
            else
                TriggerClientEvent("redeye_gangmissions:cl:notification", src, Config.Translate["must_wait"]:format(math.floor((missionTable.Timeout-(os.time()-selectedMission[missionType]))/60), math.fmod((missionTable.Timeout-(os.time()-selectedMission[missionType])), 60)), 4500, "error")
                cb(false)
            end
        else
            TriggerClientEvent("redeye_gangmissions:cl:notification", src, Config.Translate["too_few_cops"], 4500, "error")
            cb(false)
        end
    end)

elseif Config.Core == "QB-Core" then
    QBCore = Config.CoreExport()

    QBCore.Functions.CreateCallback('redeye_gangmissions:server:checkTime', function(source, cb, missionType, selectedPed)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local missionTable = Config.Missions[missionType]
        local selectedMission = Config.Gangs[selectedPed] and Config.Gangs[selectedPed].LockedOrders
        local onlinePolices = 0
        if Config.MinimumPolice >= 1 then
            for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
                if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
                    onlinePolices = onlinePolices + 1
                end
            end
        end
        if onlinePolices >= Config.MinimumPolice then
            if not selectedMission[missionType] or (os.time() - missionTable.Timeout) > selectedMission[missionType] then
                selectedMission[missionType] = os.time()
                cb(true)
            else
                TriggerClientEvent("redeye_gangmissions:cl:notification", src, Config.Translate["must_wait"]:format(math.floor((missionTable.Timeout-(os.time()-selectedMission[missionType]))/60), math.fmod((missionTable.Timeout-(os.time()-selectedMission[missionType])), 60)), 4500, "error")
                cb(false)
            end
        else
            TriggerClientEvent("redeye_gangmissions:cl:notification", src, Config.Translate["too_few_cops"], 4500, "error")
            cb(false)
        end
    end)
end

RegisterNetEvent("redeye_gangmissions:sv:payout", function(missionType, selectedPed)
    local src = source
    if Config.Core == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if Config.Gangs[selectedPed] then
            local money = Config.Missions[missionType].MoneyReward
            if Config.RewardMoneyType == "cash" then
                xPlayer.addMoney(money)
            else
                xPlayer.addAccountMoney(Config.RewardMoneyType, money)
            end
            TriggerClientEvent("redeye_gangmissions:cl:notification", src, Config.Translate["money_recieved"]:format(money), 4500, "success")
        end
    elseif Config.Core == "QB-Core" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Config.Gangs[selectedPed] then
            local money = Config.Missions[missionType].MoneyReward
            Player.Functions.AddMoney(Config.RewardMoneyType, money)
            TriggerClientEvent("redeye_gangmissions:cl:notification", src, Config.Translate["money_recieved"]:format(money), 4500, "success")
        end
    end
end)