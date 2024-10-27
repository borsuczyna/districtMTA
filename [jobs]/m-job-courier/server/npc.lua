addEvent('jobs:courier:deliver', true)
addEvent('jobs:courier:pedLeave')

function vehicleLoaded(player, amount)
    local positions = getRandomNpcPositions(amount)
    local players = exports['m-jobs']:getLobbyPlayers(player)
    
    for _, position in ipairs(positions) do
        local x, y, z, rx, ry, rz = unpack(position)
        local npc = exports['m-jobs']:createLobbyPed(player, math.random(0, 200), x, y, z, rx, ry, rz, {
            noTrigger = true,
            frozen = true,
            invincible = true,
            blip = {
                icon = 41,
                visibleDistance = 99999,
            }
        })

        local mx, my = getPointFromDistanceRotation(x, y, 1, -rz)
        local marker = exports['m-jobs']:createLobbyMarker(player, 'cylinder', mx, my, z - 1, 1, 255, 100, 0, 0, {
            noTrigger = true,
            event = 'jobs:courier:deliver',
            customData = {
                npc = npc,
            }
        })
    end

    exports['m-jobs']:updateLobbyPeds(player)
    exports['m-jobs']:updateLobbyMarkers(player)
    exports['m-notis']:addNotification(players, 'success', 'Kurier', 'Załadunek zakończony, udaj się do punktów dostawy.')
end

function giveJobReward(players)
    local totalMoney = math.random(unpack(settings.moneyPerPackage))
    local multiplier = exports['m-jobs']:getJobMultiplier('courier')
    local perPlayerMoney = math.floor(totalMoney / #players)
    local upgradePoints = math.max(math.random(unpack(settings.upgradePointsPerPackage)), 0)
    local giveExp = math.random(0, 100) > 75

    for _,player in pairs(players) do
        exports['m-jobs']:giveMoney(player, perPlayerMoney)
        if upgradePoints > 0 then
            exports['m-jobs']:giveUpgradePoints(player, upgradePoints)
        end
        if giveExp then
            exports['m-core']:givePlayerExp(player, 1)
        end
        exports['m-jobs']:giveTopPoints(player, 1)
        setElementData(player, 'player:deliveredCourierPackages', (getElementData(player, 'player:deliveredCourierPackages') or 0) + 1)
    end

    if upgradePoints > 0 then
        exports['m-notis']:addNotification(players, 'success', 'Kurier', ('Za dostarczoną paczke otrzymujesz $%.2f + %d punktów ulepszeń (razem $%.2f)'):format(perPlayerMoney/100, upgradePoints, totalMoney/100))
    else
        exports['m-notis']:addNotification(players, 'success', 'Kurier', ('Za dostarczoną paczke otrzymujesz $%.2f (razem $%.2f)'):format(perPlayerMoney/100, totalMoney/100))
    end
end

addEventHandler('jobs:courier:deliver', root, function(hash, player, markerHash)
    if isPedInVehicle(player) then
        exports['m-notis']:addNotification(client, 'error', 'Kurier', 'Nie możesz podnieść paczki będąc w pojeździe.')
        return
    end

    local npc = exports['m-jobs']:getLobbyMarkerCustomData(player, markerHash, 'npc')
    if not npc then return end

    if not isPlayerHoldingPackage(player) then
        exports['m-notis']:addNotification(player, 'error', 'Kurier', 'Nie masz paczki w rękach.')
        return
    end

    local players = exports['m-jobs']:getLobbyPlayers(player)

    exports['m-jobs']:makePedGoAway(player, npc)
    exports['m-jobs']:setLobbyTimer(player, 'jobs:courier:pedLeave', 400, npc)
    exports['m-jobs']:destroyLobbyMarker(player, markerHash)
    destroyHoldingPackage(player)
    giveJobReward(players)

    local delivered = changeDeliveredPackages(player, 1)
    local total = exports['m-jobs']:getLobbyData(player, 'vehicle:packages')

    if delivered == total then
        exports['m-notis']:addNotification(players, 'success', 'Kurier', 'Wszystkie paczki zostały dostarczone, wróć do bazy po kolejny załadunek.')
        reloadLobbyPackages(player)
    end
end)

addEventHandler('jobs:courier:pedLeave', resourceRoot, function(lobby, hash)
    if client then
        if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Trigger hack (**jobs:courier:pedLeave**)')
    end

    exports['m-jobs']:destroyLobbyPed(lobby, hash)
end)

function changeDeliveredPackages(player, amount)
    local delivered = exports['m-jobs']:getLobbyData(player, 'vehicle:deliveredPackages')
    exports['m-jobs']:setLobbyData(hash, 'vehicle:deliveredPackages', delivered + amount)

    return delivered + amount
end