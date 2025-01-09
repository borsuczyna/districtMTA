addEvent('factions:removeMember')
addEvent('factions:addMember')
addEvent('factions:editMember')
addEvent('factions:addRank')
addEvent('factions:removeRank')
addEvent('factions:editRank')

local timeouts = {}
local fullNames = {
    SAPD = 'San Andreas Police Department',
    ERS = 'Emergency Rescue Service',
}

function isPlayerTimedOut(player)
    if not timeouts[player] then
        timeouts[player] = getTickCount()
        return false
    end

    if getTickCount() - timeouts[player] < 1000 then
        return true
    end

    timeouts[player] = getTickCount()
    return false
end

local function onMarkerHit(hitElement, matchingDimension)
    if not matchingDimension or getElementType(hitElement) ~= 'player' then return end
    local player = hitElement

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local faction = getElementData(source, 'marker:manage-faction')
    if not faction or not player then return end

    if not doesPlayerHaveAnyFactionPermission(player, faction, {'panel', 'manageFaction'}) then
        return exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie posiadasz uprawnień do zarządzania tą frakcją.')
    end

    triggerClientEvent(player, 'factions:openManagePanel', resourceRoot, {
        faction = faction,
        fullName = fullNames[faction] or faction,
        permissions = getPlayerPermissions(player, faction),
        members = getPlayersDutyTime(faction),
        ranks = getFactionRanks(faction),
        allPermissions = permissions,
        payPerMinute = payPerMinute or 0,
        uid = uid
    })
end

local function onMarkerLeave(leaveElement, matchingDimension)
    if not matchingDimension or getElementType(leaveElement) ~= 'player' then return end

    local player = leaveElement
    if not player then return end

    triggerClientEvent(player, 'factions:closeManagePanel', resourceRoot)
end

function createManagePanel(faction, position)
    local marker = createMarker(position[1], position[2], position[3] - 0.95, 'cylinder', 1, 255, 0, 0, 150)
    setElementData(marker, 'marker:manage-faction', faction)
    setElementData(marker, 'marker:title', faction)
    setElementData(marker, 'marker:desc', 'Zarządzanie frakcją')
    addDestroyOnRestartElement(marker, sourceResource)

    addEventHandler('onMarkerHit', marker, onMarkerHit)
    addEventHandler('onMarkerLeave', marker, onMarkerLeave)
end

addEventHandler('factions:removeMember', root, function(hash, player, faction, uid)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local success, message = removePlayerFromFaction(player, faction, tonumber(uid))
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = message})
        return
    end

    local foundPlayer = exports['m-core']:getPlayerByUid(tonumber(uid))
    if foundPlayer then
        exports['m-notis']:addNotification(foundPlayer, 'info', ('Frakcja %s'):format(faction), 'Zostałeś usunięty z frakcji.')
    end
    
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Usunięto gracza z frakcji.', members = getPlayersDutyTime(faction)})
end)

addEventHandler('factions:addMember', root, function(hash, player, faction, playerToFind, rank)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono gracza o podanej nazwie.'})
        return
    end

    local uid = getElementData(foundPlayer, 'player:uid')
    if not uid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Gracz nie jest zalogowany.'})
        return
    end

    local success, message = addPlayerToFaction(player, faction, tonumber(uid), tonumber(rank))
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = message})
        return
    end

    exports['m-notis']:addNotification(foundPlayer, 'info', ('Frakcja %s'):format(faction), 'Zostałeś dodany do frakcji.')
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Dodano gracza do frakcji.', members = getPlayersDutyTime(faction)})
end)

addEventHandler('factions:editMember', root, function(hash, player, faction, uid, rank)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local success, message = editPlayerInFaction(player, faction, tonumber(uid), tonumber(rank))
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = message})
        return
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zmieniono rangę gracza.', members = getPlayersDutyTime(faction)})
end)

addEventHandler('factions:addRank', root, function(hash, player, faction, name)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local success, message = addFactionRank(player, faction, name, '')
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = message})
        return
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Dodano rangę.', ranks = getFactionRanks(faction), members = getPlayersDutyTime(faction)})
end)

addEventHandler('factions:removeRank', root, function(hash, player, faction, rank)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local success, message = removeFactionRank(player, faction, tonumber(rank))
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = message})
        return
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Usunięto rangę.', ranks = message, members = getPlayersDutyTime(faction)})
end)

addEventHandler('factions:editRank', root, function(hash, player, faction, rank, name, permissions)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local success, message = editFactionRank(player, faction, tonumber(rank), name, permissions)
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = message})
        return
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zmieniono rangę.', ranks = getFactionRanks(faction), permissions = getPlayerPermissions(player, faction)})
end)