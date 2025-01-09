addEvent('jobs:finishJob')
addEvent('jobs:startJob')
addEvent('jobs:finishJobLobby')

local blip = createBlip(settings.jobStart, 40, 2, 255, 255, 255, 255, 0, 9999)
setElementData(blip, 'blip:hoverText', 'Praca dorywcza<br>Wywóz śmieci')
local vehicles = {}
local timers = {}

defaultBlipData = {
    icon = 41,
    visibleDistance = 9999,
}

function setPlayerTimer(player, callback, time, ...)
    if timers[player] and isTimer(timers[player]) then
        killTimer(timers[player])
    end

    timers[player] = setTimer(callback, time, 1, ...)
end

addEventHandler('jobs:startJob', root, function(job, hash, players)
    if job ~= 'trash' then return end

    for k,v in pairs(players) do
        if not exports['m-core']:doesPlayerHaveLicense(v, 'C') then
            exports['m-notis']:addNotification(players, 'error', 'Brak licencji', ('Gracz %s nie posiada kat. C'):format(htmlEscape(getPlayerName(v))))
            cancelEvent()
            return
        end
    end

    local vehicle = createVehicle(408, settings.vehicleSpawn, settings.vehicleSpawnRot)
    setElementData(vehicle, 'vehicle:job', {players = players, hash = hash})
    setElementData(vehicle, 'element:ghostmode', true)

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

    exports['m-jobs']:createLobbyBlip(hash, 0, 0, 0, 43, 9999, {
        attach = {
            element = vehicle,
        }
    })

    exports['m-jobs']:createLobbyMarker(hash, 'cylinder', settings.trashDump.x, settings.trashDump.y, settings.trashDump.z, 7, 255, 200, 55, 0, {
        icon = 'work',
        title = 'Wywóz śmieci',
        desc = 'Oddawanie śmieci',
        event = 'jobs:trash:dumpTrash'
    })

    for k,v in pairs(trash) do
        local model, offset = getRandomTrashModel()
        exports['m-jobs']:createLobbyObject(hash, model, v[1], v[2], v[3] + offset, 0, 0, v[6] + 180, {
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

    for i, player in ipairs(players) do
        local upgrades = exports['m-jobs']:getPlayerJobUpgrades(player, 'trash')
        setElementData(player, 'player:job-upgrades-cache', upgrades, false)

        if i <= 2 then
            warpPedIntoVehicle(player, vehicle, i - 1)
        else
            exports['m-core']:enterAdditionalSeat(player, vehicle)
        end

        exports['m-core']:allowVehicleAttach(player, vehicle)
    end

    for k,v in pairs(players) do
        setElementData(v, 'player:jobVehicle', vehicle)
    end
end)

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'trash' then return end

    local carryBin = getElementData(player, 'player:carryBin')
    if carryBin then
        forcefullyPutBinBack(hash, carryBin)
    end

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

addEventHandler('onVehicleEnter', root, function(player, seat)
    local vehicle = source
    if seat ~= 0 then return end

    local jobData = getElementData(vehicle, 'vehicle:job')
    if not jobData then return end

    local job = getElementData(player, 'player:job')
    if job ~= 'trash' then return end

    local jobVehicle = exports['m-jobs']:getLobbyData(player, 'trashmaster')
    if jobVehicle ~= vehicle then return end

    local upgrades = getElementData(player, 'player:job-upgrades-cache') or {}
    local modelHandling = getModelHandling(getElementModel(vehicle))
    local multiplier = table.find(upgrades, 'kierowca') and 1.15 or 1

    setVehicleHandling(vehicle, 'maxVelocity', modelHandling['maxVelocity'] * multiplier)
    setVehicleHandling(vehicle, 'engineAcceleration', modelHandling['engineAcceleration'] * multiplier)
    setVehicleHandling(vehicle, 'steeringLock', modelHandling['steeringLock'] * multiplier)
end)

addEventHandler('onPlayerResourceStart', root, function(resource)
    if resource ~= getThisResource() then return end

    if getElementData(source, 'player:job') == 'trash' then
        triggerEvent('jobs:endJobI', root, false, source)
    end
end)