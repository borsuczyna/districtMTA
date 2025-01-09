addEvent('houses:getData', true)

local rateLimits = {}
houses = {}

function isPlayerRateLimited(player)
    if rateLimits[player] then
        if getTickCount() - rateLimits[player] < 1000 then
            return true, ('%.1f'):format((1000 - (getTickCount() - rateLimits[player])) / 1000)
        end
    end

    rateLimits[player] = getTickCount()
    return false
end

local function createHouseMarker(id)
    local data = houses[id]
    if not data then return end

    local color = (data.owner) and {255, 0, 0, 0} or {0, 255, 0, 0}
    local marker = createMarker(data.position[1], data.position[2], data.position[3] - 1, 'cylinder', 1, unpack(color))
    local blip = createBlipAttachedTo(marker, data.owner and 47 or 46, 2, 255, 255, 255, 255, 0, 9999)
    setElementData(marker, 'marker:title', 'Dom')
    setElementData(marker, 'marker:desc', data.name)
    setElementData(marker, 'marker:icon', 'house')
    setElementData(marker, 'marker:house', id)
    setElementData(blip, 'blip:hoverText', data.streetName)

    return marker, blip
end

function updateHouseRent(id)
    local data = houses[id]
    if not data then return end

    local wasRented = data.isRented
    local isRented = (not isPastDate(data.rentDate) and data.owner)
    data.isRented = isRented
    
    if not isRented then
        if wasRented and data.owner then
            exports['m-logs']:sendLog('houses', 'info', ('Dom %s wygasł (uid: %d) - właściciel: %s'):format(data.streetName, id, data.ownerName or 'brak'))
            removePlayersFromHouse(id)
            removeAllHouseFurniture(id)
            removeAllHouseTextures(id)

            local connection = exports['m-mysql']:getConnection()
            if not connection then return end

            local query = 'UPDATE `m-houses` SET `owner` = NULL, `sharedPlayers` = "" WHERE `uid` = ?'
            dbExec(connection, query, id)
            
            local player = exports['m-core']:getPlayerByUid(data.owner)
            if player then
                exports['m-notis']:addNotification(player, 'warning', 'Dom', ('Twój dom w %s wygasł.<br>Meble zostały ci zwrócone.'):format(data.streetName))
            end
        end
        
        data.owner = nil
        data.ownerName = nil
    end

    destroyElement(data.marker)
    destroyElement(data.blip)
    data.marker, data.blip = createHouseMarker(id)
end

local function loadHouse(data)
    local id = data.uid
    local position = map(split(data.position, ','), tonumber)
    local city = getZoneName(position[1], position[2], position[3], true)
    local street = getZoneName(position[1], position[2], position[3], false)
    local streetName = (city == street) and (city) or (city .. ', ' .. street)

    houses[id] = {
        uid = id,
        name = data.name,
        interior = map(split(data.interior, ','), tonumber),
        position = position,
        price = data.price,
        owner = data.owner,
        streetNumber = data.streetNumber,
        streetName = streetName .. ' ' .. data.streetNumber,
        sharedPlayers = map(split(data.sharedPlayers, ','), tonumber),
        sharedPlayerNames = data.sharedPlayerNames == false and {} or map(split(data.sharedPlayerNames, ';'), function(v)
            local split = split(v, ',')
            return {name = split[1], uid = tonumber(split[2])}
        end),
        rentDate = getRealTime(data.rentDateTimestamp),
        owner = data.owner,
        ownerName = data.ownerName,
        furnitured = data.furnitured == 1,
        locked = data.locked == 1,
        furniture = getHouseFurniture(id),
        textures = getHouseTextures(id),
        isRented = true
    }

    houses[id].marker, houses[id].blip = createHouseMarker(id)

    updateHouseRent(id)
end

local function buildGetHouseQuery(id)
    local query = [[
        SELECT
            `m-houses`.*,
            UNIX_TIMESTAMP(`rentDate`) AS `rentDateTimestamp`,
            `m-users`.`username` AS `ownerName`,
            GROUP_CONCAT(CONCAT(`sharedUsers`.`username`, ',', `sharedUsers`.`uid`) SEPARATOR ';') AS `sharedPlayerNames`
        FROM
            `m-houses`
        LEFT JOIN
            `m-users`
        ON
            `m-houses`.`owner` = `m-users`.`uid`
        LEFT JOIN 
            `m-users` AS `sharedUsers`
        ON
            FIND_IN_SET(`sharedUsers`.`uid`, `m-houses`.`sharedPlayers`) > 0
    ]]

    if id then
        query = query .. ' WHERE `m-houses`.`uid` = ' .. id
    end

    query = query .. ' GROUP BY `m-houses`.`uid`'

    return query
end

local function loadHouseFromDatabase(id)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = buildGetHouseQuery(id)
    dbQuery(function(queryHandle)
        local result = dbPoll(queryHandle, 0)
        if not result then return end

        for i, data in ipairs(result) do
            loadHouse(data)
        end
    end, connection, query, id)
end

local function loadHousesResult(queryHandle)
    local result = dbPoll(queryHandle, 0)
    if not result then return end

    for i, data in ipairs(result) do
        loadHouse(data)
    end
end

local function loadHouses()
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = buildGetHouseQuery()
    dbQuery(loadHousesResult, connection, query)
end

addEventHandler('onResourceStart', resourceRoot, loadHouses)

addEventHandler('houses:getData', resourceRoot, function(uid)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `houses:getData` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end
    
    if not client then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    local data = houses[uid]
    if not data then return end

    local playerUid = getElementData(client, 'player:uid')
    if not playerUid then return end

    local canEnter = data.owner == playerUid or table.find(data.sharedPlayers, playerUid)
    local isInside = getElementDimension(client, 'player:house')

    triggerClientEvent(client, 'houses:getData', resourceRoot, {
        uid = uid,
        name = data.name,
        interior = data.interior,
        position = data.position,
        streetName = data.streetName,
        price = data.price,
        owner = data.owner,
        ownerName = data.ownerName,
        isYou = data.owner == playerUid,
        canEnter = canEnter,
        isInside = isInside,
        garages = 0, -- @TODO garages
        sharedPlayers = data.sharedPlayers,
        sharedPlayerNames = data.sharedPlayerNames,
        rentDate = data.rentDate,
        isRented = data.isRented,
        furnitured = data.furnitured,
        locked = data.locked,
        furniture = data.furniture,
        textures = data.textures,
        possibleTextures = interiorTextures
    })
end)

function updateHouseRents()
    for id, data in pairs(houses) do
        updateHouseRent(id)
    end
end

function getPlayerHouses(player)
    local playerUid = getElementData(player, 'player:uid')
    if not playerUid then return end

    local playerHouses = {}
    for id, data in pairs(houses) do
        if data.owner == playerUid or table.find(data.sharedPlayers, playerUid) then
            table.insert(playerHouses, data)
        end
    end

    return playerHouses
end

function getPlayerOwnedHouses(player)
    local playerUid = getElementData(player, 'player:uid')
    if not playerUid then return end

    local playerHouses = {}
    for id, data in pairs(houses) do
        if data.owner == playerUid then
            table.insert(playerHouses, data)
        end
    end

    return playerHouses
end

setTimer(updateHouseRents, 60000, 0)

addEventHandler('onResourceStart', resourceRoot, function()
    for i, player in ipairs(getElementsByType('player')) do
        removeElementData(player, 'player:house')
    end
end)

addEvent('house:create', true)
addEventHandler('house:create', root, function(data)
    data = fromJSON(data)
    -- {"name":"test","interior":"2","enter":"1197.16, -2068.30, 69.01","interiorPos":"1197.16, -2068.30, 69.01, 0.00","furnitured":false,"price":"45","number":"5"}

    -- dont do any security checks here, they are done in the client side
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = [[
        INSERT INTO
            `m-houses`
        SET
            `name` = ?,
            `interior` = ?,
            `position` = ?,
            `price` = ?,
            `streetNumber` = ?,
            `furnitured` = ?,
            `locked` = 0
    ]]

    local x, y, z = unpack(map(split(data.enter, ','), tonumber))
    local position = table.concat({x, y, z}, ',')
    local interior = data.interior .. ',' .. table.concat(map(split(data.interiorPos, ','), tonumber), ',')
    local query = dbQuery(connection, query, data.name, interior, position, data.price, data.number, data.furnitured and 1 or 0)
    local result, numAffectedRows, lastInsertId = dbPoll(query, -1)
    if not result then return end

    loadHouseFromDatabase(lastInsertId)
end)