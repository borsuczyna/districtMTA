addEvent('jobs:finishJob', true)
addEvent('jobs:startJob', true)
addEvent('jobs:finishJobLobby', true)

local vehicles = {}

addEventHandler('jobs:startJob', root, function(job, hash, players)
    if job ~= 'trash' then return end

    local vehicle = createVehicle(408, settings.vehicleSpawn, settings.vehicleSpawnRot)
    setElementData(vehicle, 'vehicle:job', {players = players, hash = hash})

    for i, player in ipairs(players) do
        if i <= 2 then
            warpPedIntoVehicle(player, vehicle, i - 1)
        else
            exports['m-core']:enterAdditionalSeat(player, vehicle)
        end

        exports['m-core']:allowVehicleAttach(player, vehicle)
    end

    setVehicleEngineState(vehicle, true)
    setElementFrozen(vehicle, true)
    setVehicleOverrideLights(vehicle, 1)

    vehicles[hash] = vehicle

    for k,v in pairs(trash) do
        exports['m-jobs']:createLobbyObject(hash, 1337, v[1], v[2], v[3] - 0.4, 0, 0, v[6] + 180)
        exports['m-jobs']:createLobbyBlip(hash, v[1], v[2], v[3], 41, 500)
    end
end)

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'trash' then return end

    local vehicle = vehicles[hash]
    if vehicle and isElement(vehicle) then
        exports['m-core']:disAllowVehicleAttach(player)
    end
end)

addEventHandler('jobs:finishJobLobby', root, function(job, hash)
    if job ~= 'trash' then return end

    local vehicle = vehicles[hash]
    if vehicle and isElement(vehicle) then
        destroyElement(vehicle)
    end
end)

addEventHandler('onResourceStop', resourceRoot, function()
    for k,v in pairs(getElementsByType('player')) do
        if getElementData(v, 'player:job') == 'trash' then
            exports['m-jobs']:leaveJob(v)
        end
    end
end)