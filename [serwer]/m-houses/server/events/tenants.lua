addEvent('houses:removeTenant')
addEventHandler('houses:removeTenant', root, function(hash, player, houseUid, tenantUid)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local data = houses[houseUid]
    if not data then return end

    local playerUid = getElementData(player, 'player:uid')
    if not playerUid then return end

    if data.owner ~= playerUid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś właścicielem tego domu.'})
        return
    end

    local tenantData = false
    for i, sharedPlayer in ipairs(data.sharedPlayerNames) do
        if sharedPlayer.uid == tenantUid then
            tenantData = sharedPlayer
            break
        end
    end

    if not tenantData then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Ten gracz nie jest lokatorem tego domu.'})
        return
    end
    
    data.sharedPlayers = table.filter(data.sharedPlayers, function(v) return v ~= tenantUid end)    
    data.sharedPlayerNames = table.filter(data.sharedPlayerNames, function(v) return v.uid ~= tenantUid end)

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wystąpił błąd podczas usuwania lokatora.'})
        return
    end

    local query = 'UPDATE `m-houses` SET `sharedPlayers` = ? WHERE `uid` = ?'
    dbExec(connection, query, table.concat(data.sharedPlayers, ','), houseUid)

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Usunięto lokatora z domu.'})
end)

addEvent('houses:addTenant')
addEventHandler('houses:addTenant', root, function(hash, player, houseUid, playerName)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local playerUid = getElementData(player, 'player:uid')
    if not playerUid then return end

    local data = houses[houseUid]
    if not data then return end

    local interiorData = houseInteriors[data.interior[1]]
    if not interiorData then return end

    -- print(interiorData.maxTenants)

    if #data.sharedPlayers >= interiorData.maxTenants then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Osiągnięto limit lokatorów w tym domu.'})
        return
    end

    if data.owner ~= playerUid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś właścicielem tego domu.'})
        return
    end

    local targetPlayer = exports['m-core']:getPlayerFromPartialName(playerName)
    if not targetPlayer then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono podanego gracza.'})
        return
    end

    if targetPlayer == player then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie możesz dodać siebie jako lokatora.'})
        return
    end

    local targetPlayerUid = getElementData(targetPlayer, 'player:uid')
    if not targetPlayerUid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Podany gracz nie jest zalogowany.'})
        return
    end

    local px, py, pz = getElementPosition(player)
    if getDistanceBetweenPoints3D(px, py, pz, getElementPosition(targetPlayer)) > 5 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Gracz jest zbyt daleko.'})
        return
    end

    if table.find(data.sharedPlayers, targetPlayerUid) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Ten gracz jest już lokatorem tego domu.'})
        return
    end

    table.insert(data.sharedPlayers, targetPlayerUid)
    table.insert(data.sharedPlayerNames, {uid = targetPlayerUid, name = getPlayerName(targetPlayer)})

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wystąpił błąd podczas dodawania lokatora.'})
        return
    end

    local query = 'UPDATE `m-houses` SET `sharedPlayers` = ? WHERE `uid` = ?'
    dbExec(connection, query, table.concat(data.sharedPlayers, ','), houseUid)

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Dodano lokatora do domu.', name = getPlayerName(targetPlayer), uid = targetPlayerUid})
end)