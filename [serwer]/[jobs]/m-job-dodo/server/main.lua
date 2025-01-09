addEvent('jobs:finishJob')
addEvent('jobs:startJob')
addEvent('jobs:dodo:hitMarker')

local vehicles = {}

local blip = createBlip(settings.blipPosition, 40, 2, 255, 255, 255, 255, 0, 9999)
setElementData(blip, 'blip:hoverText', 'Praca dorywcza<br>Pilot L1')

addEventHandler('onVehicleStartEnter', resourceRoot, function(player, seat, jacked)
    local job = getElementData(source, 'vehicle:job')
    if not job then return end

    if job ~= player then
        cancelEvent()
        return
    end
end)

addEventHandler('onVehicleExit', resourceRoot, function(player, seat, jacked)
    local job = getElementData(source, 'vehicle:job')
    if not job then return end

    if job == player then
        exports['m-jobs']:leaveJob(player)
        triggerClientEvent(player, 'destroyJobTarget', resourceRoot)

        setTimer(function(plr)
            if isPedInVehicle(plr) then
                removePedFromVehicle(plr)
            end

            setElementPosition(plr, 1953.244, -2176.909, 13.547)
        end, 500, 1, player)
    end
end)

function getRandomMarker()
    local x, y = math.random(-3000, 3000), math.random(-3000, 3000)

    return x, y, math.random(550, 570)
end

function createNextMarker(hash, player, markerHash)
    local x, y, z = getRandomMarker()

    triggerClientEvent(player, 'destroyJobTarget', resourceRoot)

    if markerHash then
        exports['m-jobs']:destroyLobbyMarker(player, markerHash)

        triggerClientEvent(player, 'speedcam:playSound', root, player, x, y, z)

        local multiplier = exports['m-jobs']:getJobMultiplier('pilotl1')
        local upgrades = getElementData(player, "player:job-upgrades-cache") or {}

        if table.find(upgrades, 'biznesmen') then
            multiplier = multiplier + 0.05
        end

        local totalMoney = math.floor(math.random(unpack(settings.moneyPerPackage)) * multiplier)
        local upgradePoints = math.max(math.random(unpack(settings.upgradePointsPerPackage)), 0)
        local giveExp = math.random(0, 100) > 90

        exports['m-jobs']:giveMoney(player, totalMoney)
        
        if upgradePoints > 0 then
            exports['m-jobs']:giveUpgradePoints(player, upgradePoints)
        end

        if giveExp then
            exports['m-core']:givePlayerExp(player, 1)
        end

        exports['m-jobs']:giveTopPoints(player, 1)
        exports['m-notis']:addNotification(player, 'success', 'Pilot L1', ('Za wykonanie zdjęcia otrzymujesz %s.'):format(addCents(totalMoney), upgradePoints > 0 and (' oraz %s punktów umiejętności'):format(upgradePoints) or ''))    
    end

    triggerClientEvent(player, 'createJobTarget', resourceRoot, x, y, z)

    exports['m-jobs']:createLobbyMarker(hash, 'ring', x, y, z - 1, 5, 255, 55, 55, 200, {
        icon = 'work',
        title = ' ',
        desc = ' ',
        event = 'jobs:dodo:hitMarker',
        dimension = 0,
        interior = 0,
        blip = {
            icon = 41,
            visibleDistance = 99999,
        }
    })
end
addEventHandler('jobs:dodo:hitMarker', root, createNextMarker)

addEventHandler('jobs:startJob', root, function(job, hash, players)
    if job ~= 'pilotl1' then return end
    local client = players[1]
    local x, y, z, rx, ry, rz = unpack(settings.vehiclePosition)
    local dodo = createVehicle(593, x, y, z, rx, ry, rz)
    setElementData(dodo, 'vehicle:job', client)

    if vehicles[client] then
        destroyElement(vehicles[client])
    end

    vehicles[client] = dodo

    createNextMarker(hash, client)

    setTimer(function(player, dodo)
        warpPedIntoVehicle(player, dodo)
    end, 100, 1, client, vehicles[client])
    
    for i, player in ipairs(players) do
        setElementData(player, 'element:ghostmode', true)

        local upgrades = exports['m-jobs']:getPlayerJobUpgrades(player, 'pilotl1')
        setElementData(player, 'player:job-upgrades-cache', upgrades, false)
    end
end)

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'pilotl1' then return end

    setElementData(player, 'element:ghostmode', false)
    setPedAnimation(player)

    if vehicles[player] then
        destroyElement(vehicles[player])
    end

    triggerClientEvent(player, 'destroyJobTarget', resourceRoot)
end)


function addCents(amount)
    return '$' .. string.format('%0.2f', amount / 100)
end