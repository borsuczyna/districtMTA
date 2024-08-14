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
    setElementData(marker, 'marker:title', 'Dom')
    setElementData(marker, 'marker:desc', data.name)
    setElementData(marker, 'marker:house', id)

    return marker
end

function updateHouseRent(id)
    local data = houses[id]
    if not data then return end

    local isRented = (not isPastDate(data.rentDate) and data.owner)
    data.isRented = isRented
    
    if not isRented then
        data.owner = nil
        data.ownerName = nil
    end

    destroyElement(data.marker)
    data.marker = createHouseMarker(id)
end

local function loadHouse(data)
    local id = data.uid
    local position = map(split(data.position, ','), tonumber)
    local city = getZoneName(position[1], position[2], position[3], true)
    local street = getZoneName(position[1], position[2], position[3], false)
    local streetName = (city == street) and (city) or (city .. ', ' .. street)

    houses[id] = {
        uid = id,
        marker = marker,
        name = data.name,
        interior = map(split(data.interior, ','), tonumber),
        position = position,
        price = data.price,
        owner = data.owner,
        streetNumber = data.streetNumber,
        streetName = streetName .. ' ' .. data.streetNumber,
        sharedPlayers = map(split(data.sharedPlayers, ','), tonumber),
        rentDate = getRealTime(data.rentDateTimestamp),
        owner = data.owner,
        ownerName = data.ownerName,
        furnitured = data.furnitured == 1,
        locked = data.locked == 1,
    }

    houses[id].marker = createHouseMarker(id)

    updateHouseRent(id)
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

    local query = [[
        SELECT
            `m-houses`.*,
            UNIX_TIMESTAMP(`rentDate`) AS `rentDateTimestamp`,
            `m-users`.`username` AS `ownerName`
        FROM
            `m-houses`
        LEFT JOIN
            `m-users`
        ON
            `m-houses`.`owner` = `m-users`.`uid`
    ]]
    dbQuery(loadHousesResult, connection, query)
end

addEventHandler('onResourceStart', resourceRoot, loadHouses)

addEventHandler('houses:getData', resourceRoot, function(uid)
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
        rentDate = data.rentDate,
        isRented = data.isRented,
        furnitured = data.furnitured,
        locked = data.locked,
    })
end)

setTimer(function()
    for id, data in pairs(houses) do
        updateHouseRent(id)
    end
end, 60000, 0)