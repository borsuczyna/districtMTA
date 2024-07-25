addEvent('jobs:finishJob')
addEvent('jobs:startJob')
addEvent('jobs:finishJobLobby')

local vehicles = {}
local timers = {}

defaultBlipData = {
    icon = 41,
    visibleDistance = 500,
}

function setPlayerTimer(player, callback, time, ...)
    if timers[player] and isTimer(timers[player]) then
        killTimer(timers[player])
    end

    timers[player] = setTimer(callback, time, 1, ...)
end

addEventHandler('jobs:startJob', root, function(job, hash, players)
    if job ~= 'trash' then return end

    local vehicle = createVehicle(408, settings.vehicleSpawn, settings.vehicleSpawnRot)
    setElementData(vehicle, 'vehicle:job', {players = players, hash = hash})

    local allUpgrades = {}
    for k,v in pairs(players) do
        local upgrades = exports['m-jobs']:getPlayerJobUpgrades(v, 'trash')
        for k,v in pairs(upgrades) do
            allUpgrades[v] = true
        end
    end

    if allUpgrades['kierowca'] then
        print('kierowca')
        local handling = getVehicleHandling(vehicle)
        setVehicleHandling(vehicle, 'maxVelocity', handling['maxVelocity'] * 1.15)
        setVehicleHandling(vehicle, 'engineAcceleration', handling['engineAcceleration'] * 1.15)
    end

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

    exports['m-jobs']:createLobbyMarker(hash, 'cylinder', 0, 0, 0, 1, 50, 140, 255, 0, {
        icon = 'work',
        title = 'Wywóz śmieci',
        desc = 'Tył śmieciarki',
        attach = {
            element = vehicle,
            position = {0, -4.9, -1.5},
        },
        event = 'jobs:trash:putTrash'
    })

    exports['m-jobs']:createLobbyMarker(hash, 'cylinder', settings.trashDump.x, settings.trashDump.y, settings.trashDump.z, 4, 50, 140, 255, 0, {
        icon = 'work',
        title = 'Wywóz śmieci',
        desc = 'Oddawanie śmieci',
        event = 'jobs:trash:dumpTrash'
    })

    for k,v in pairs(trash) do
        local model, offset = getRandomTrashModel()
        local object = exports['m-jobs']:createLobbyObject(hash, model, v[1], v[2], v[3] + offset, 0, 0, v[6] + 180, {
            noTrigger = true,
            colshape = {
                size = 1,
                event = 'jobs:trash:trashHit'
            },
            blip = defaultBlipData,
            frozen = true,
            ghost = true
        })
    end

    exports['m-jobs']:updateLobbyObjects(hash)
    exports['m-jobs']:setLobbyData(hash, 'trashLevel', 0)
    exports['m-jobs']:setLobbyData(hash, 'trashmaster', vehicle)

    for k,v in pairs(players) do
        setElementData(v, 'player:jobVehicle', vehicle)
    end
end)

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'trash' then return end

    removeElementData(player, 'player:animation')
    removeElementData(player, 'player:carryBin')
    toggleAllControls(player, true)

    if not hash then return end -- jobs system restart
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

addCommandHandler('testattach', function(plr)
    local object = createObject(1265, 0, 0, 0)
    exports['m-pattach']:attach(object, plr, 24, 0.2, 0, -0.1, 0, -90, 0)
end)