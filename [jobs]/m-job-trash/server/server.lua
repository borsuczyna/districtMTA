addEvent('jobs:finishJob', true)
addEvent('jobs:startJob', true)
addEvent('jobs:finishJobLobby', true)
addEvent('jobs:trash:trashHit')

local vehicles = {}
local timers = {}

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

    local marker = exports['m-jobs']:createLobbyMarker(hash, 'cylinder', 0, 0, 0, 1, 50, 140, 255, 0, {
        icon = 'work',
        title = 'Wywóz śmieci',
        desc = 'Tył śmieciarki',
        attach = {
            element = vehicle,
            position = {0, -4.5, -1.5},
        }
    })

    for k,v in pairs(trash) do
        local object = exports['m-jobs']:createLobbyObject(hash, 1337, v[1], v[2], v[3] - 0.4, 0, 0, v[6] + 180, {
            noTrigger = true,
            colshape = {
                size = 1,
                event = 'jobs:trash:trashHit'
            },
            blip = {
                icon = 41,
                visibleDistance = 500
            }
        })
    end

    exports['m-jobs']:updateLobbyObjects(hash)
    exports['m-jobs']:setLobbyData(hash, 'trashLevel', 0)

    for k,v in pairs(players) do
        setElementData(v, 'player:jobVehicle', vehicle)
    end
end)

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'trash' then return end

    removeElementData(player, 'player:animation')
    removeElementData(player, 'player:carryBin')
    toggleAllControls(player, true)

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

local function pickUpTrash(player, hash, objectHash)
    setElementFrozen(player, false)
    setPedAnimation(player)
    setElementData(player, 'player:animation', 'carry')
    setElementData(player, 'player:carryBin', objectHash)
    toggleAllControls(player, true)
    toggleControl(player, 'crouch', false)
    toggleControl(player, 'jump', false)
    toggleControl(player, 'sprint', true) -- TODO add sprint upgrade

    exports['m-jobs']:attachObjectToPlayer(hash, objectHash, player, 23, 0.44, 0, 0.45, 0, 220, 90)
end

addEventHandler('jobs:trash:trashHit', root, function(hash, player, objectHash)
    if getElementData(player, 'player:carryBin') then return end

    exports['m-jobs']:setLobbyObjectOption(hash, objectHash, 'colshape', false)
    exports['m-jobs']:setLobbyObjectOption(hash, objectHash, 'blip', false)
    
    setElementFrozen(player, true)
    toggleAllControls(player, false)
    setPedAnimation(player, "CARRY", "putdwn", -1, false)

    setPlayerTimer(player, pickUpTrash, 1000, player, hash, objectHash)

    -- exports['m-jobs']:attachObjectToPlayer(hash, objectHash, player, 'head', 0.1, -0.05, 0, 0, 90, 0)
end)