local function findIndexByPassword(table, target_password)
    for k, v in pairs(table) do
        if type(v) == "table" and v.password == target_password then
            return tonumber(k)
        end
    end
    return nil
end

RegisterNetEvent('ybn_racesystem:startrace', function (password, maxplayers, checkpointsAmount, checkpointsCoords, startpointsCoords, startpointsHeading)

    local resourceName = GetCurrentResourceName()
    local data = json.decode(LoadResourceFile(resourceName, "server/races.json"))
    local id = 0
    if not data then
      SaveResourceFile(resourceName, 'server/races.json', "{}", -1)
    end

    data = json.decode(LoadResourceFile(resourceName, "server/races.json"))
    for k, v in pairs(data) do
        id = id + 1
    end

    local playersJoined = {}

    data[id] = {
        password = password,
        maxplayers = maxplayers,
        checkpointsAmount = checkpointsAmount,
        checkpointsCoords = checkpointsCoords,
        startpointsCoords = startpointsCoords,
        startpointsHeading = startpointsHeading,
        raceCreator = source,
        playersJoined = playersJoined,
        routingBucket = source,
        IsStarted = false
    }

    SaveResourceFile(resourceName, 'server/races.json', json.encode(data), -1)
end)

RegisterNetEvent('ybn_racesystem:check', function (passToCheck)

    local playerId = source
    local resourceName = GetCurrentResourceName()
    local data = json.decode(LoadResourceFile(resourceName, "server/races.json"))
    if not data then
        return
    end

    for k, v in pairs(data) do
        local passwords = v["password"]

        if passToCheck == passwords then
            local isStarted = v["IsStarted"]
            
            if isStarted == false then
                TriggerClientEvent('chat:addMessage', playerId, {
                    args = {'^1Uniendote a la carrera...'}
                })
    
                local passToGetInfo = passToCheck
    
    
                local index = findIndexByPassword(data, passToGetInfo)
                local values = data[tostring(index)]
    
                if index then
                        if values.startpointsCoords[1] == nil then
                            TriggerClientEvent('chat:addMessage', playerId, {
                                args = {'^1Esa partida esta llena!'}
                            })
                        elseif values.startpointsCoords[1] then
    
                            local newPlayer = { playerId = playerId}
                            table.insert(data[tostring(index)]["playersJoined"], newPlayer)
                        
                            local newPlayerData = json.encode(data)
    
                            SaveResourceFile(resourceName, 'server/races.json', newPlayerData, -1)
    
                            local coordsToTp = values.startpointsCoords[1]
                            local headingToSet = values.startpointsHeading[1]

                            local veh = GetVehiclePedIsIn(GetPlayerPed(playerId), false)
    
                            SetEntityCoords(veh, coordsToTp.x, coordsToTp.y, coordsToTp.z, false, false, true)
                            SetEntityCoords(source, coordsToTp.x, coordsToTp.y, coordsToTp.z, false, false, true)
                            SetEntityHeading(veh, headingToSet)
                            SetEntityHeading(source, headingToSet)
                            SetPedIntoVehicle(GetPlayerPed(playerId), veh, -1)
    
                            table.remove(data[tostring(index)]["startpointsCoords"], 1)
                            table.remove(data[tostring(index)]["startpointsHeading"], 1)
                            
                            local deleteStartPointData = json.encode(data)
    
                            SaveResourceFile(resourceName, "server/races.json", deleteStartPointData, -1)
    
                            TriggerClientEvent('ybn_racesystem:joinrace', playerId, values.maxplayers, values.playersJoined)
    
                            SetRoutingBucketPopulationEnabled(values.routingBucket, false)
                            SetPlayerRoutingBucket(playerId, values.routingBucket)
    
                            SetEntityRoutingBucket(veh, values.routingBucket)
                        end
                end
            else
                TriggerClientEvent('chat:addMessage', playerId, {
                    args = {'^1Esa partida ya ha empezado!'}
                })
            end
        end
    end
end)

RegisterNetEvent('ybn_racesystem:victory', function ()

    local resourceName = GetCurrentResourceName()
    local data = json.decode(LoadResourceFile(resourceName, "server/races.json"))
    if not data then
        return
    end

    local index = findIndexByPassword(data)
    local values = data[tostring(index)]
end)

RegisterCommand('ic', function (source, args)

    local passToCheck = args[1]
    local playerId = source
    local resourceName = GetCurrentResourceName()
    local data = json.decode(LoadResourceFile(resourceName, "server/races.json"))
    if not data then
        return
      end

    local index = findIndexByPassword(data, passToCheck)
    local values = data[tostring(index)]

    for k, v in pairs(data) do
        local passwords = v["password"]
        if passToCheck == passwords then
            local playerIdToCheck = source
            if playerIdToCheck == values.raceCreator then
                if values.IsStarted == false then
                    TriggerClientEvent('chat:addMessage', playerId, {
                        args = {'^1Iniciando carrera...'}
                    })
                    local checkpointsAmount = values.checkpointsAmount
                    local checkpointsCoords = values.checkpointsCoords
                    local playersId = values.playersJoined
    
                    for i = 1, #playersId do
                        local playerIdToStartRace = playersId[i].playerId
                        TriggerClientEvent('ybn_racesystem:startrace', playerIdToStartRace, checkpointsCoords, checkpointsAmount, passToCheck)
                    end
    
                    data[tostring(index)]["IsStarted"] = true
    
                    local isStartedNewState = json.encode(data)
                
                    SaveResourceFile(resourceName, "server/races.json", isStartedNewState, -1)
                else
                    TriggerClientEvent('chat:addMessage', playerId, {
                        args = {'^1Esa carrera ya esta iniciada!'}
                    })
                end
            end
        end
    end
end, false)

RegisterNetEvent('ybn_racesystem:loseevent', function(password)
    local resourceName = GetCurrentResourceName()
    local data = json.decode(LoadResourceFile(resourceName, "server/races.json"))

    local index = findIndexByPassword(data, password)
    local values = data[tostring(index)]

    local playersJoined = values.playersJoined

    for i=1, #playersJoined do
        if playersJoined[i].playerId ~= source then
            TriggerClientEvent('ybn_racesystem:losescreen', playersJoined[i].playerId)
        end
    end
end)

RegisterNetEvent('ybn_racesystem:leaverace', function (password)

    local playerId = source
    local resourceName = GetCurrentResourceName()
    local data = json.decode(LoadResourceFile(resourceName, "server/races.json"))

    local index = findIndexByPassword(data, password)
    local values = data[tostring(index)]

    local playersJoined = values.playersJoined

    for i=1, #playersJoined do
        local playersId = playersJoined[i].playerId
        local veh = GetVehiclePedIsIn(GetPlayerPed(playersId), false)
        SetVehicleDoorsLocked(veh, 0)
        SetPlayerRoutingBucket(playersId, bucket)
        SetEntityCoords(playersId, values.checkpointsCoords[1].x, values.checkpointsCoords[1].y, values.checkpointsCoords[1].z, false, false , true)
    end

    data[tostring(index)] = nil

    local deleteRaceData = json.encode(data)

    SaveResourceFile(resourceName, "server/races.json", deleteRaceData, -1)
end)

RegisterNetEvent('ybn_racesystem:leaveracebycommand', function(password)
    local playerId = source
    local resourceName = GetCurrentResourceName()
    local data = json.decode(LoadResourceFile(resourceName, "server/races.json"))

    local index = findIndexByPassword(data, password)
    local values = data[tostring(index)]

    local playersJoined = values.playersJoined

    if values.IsStarted == false then
        for i=1, #playersJoined do
            if source == playersJoined[i].playerId then
                SetEntityCoords(source, values.startpointsCoords[1])
                SetPlayerRoutingBucket(player, 1)
                table.remove(playersJoined, i)
            end
        end
    else 
        for i=1, #playersJoined do
            if source == playersJoined[i].playerId then
                table.remove(playersJoined, i)
                TriggerClientEvent('ybn_racesystem:leaveracebycmd')
            end
        end
    end

    local newChanges = json.encode(data)
    SaveResourceFile(resourceName, "server/races.json", newChanges, -1)
end)
