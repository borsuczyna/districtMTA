addEvent('houses:removeFurniture', true)

function getHouseRelativePosition(houseId, x, y, z, rx, ry, rz)
    local data = houses[houseId]
    if not data then
        return x, y, z, rx, ry, rz
    end

    local interiorId, ix, iy, iz, rotation = unpack(data.interior)
    local tempObject = createObject(1337, ix, iy, iz, 0, 0, rotation)
    local position = {getRelativeInteriorPosition(tempObject, x, y, z, rx, ry, rz)}
    destroyElement(tempObject)

    return unpack(position)
end

function convertPositionToHousePosition(houseId, x, y, z, rx, ry, rz)
    local data = houses[houseId]
    if not data then
        return x, y, z, rx, ry, rz
    end

    local interiorId, ix, iy, iz, rotation = unpack(data.interior)
    local ox, oy, oz = applyInverseRotation(x - ix, y - iy, z - iz, 0, 0, rotation)
    local orx, ory, orz = rx, ry, rz - rotation

    return ox, oy, oz, orx, ory, orz
end

function addHouseFurniture(houseId, owner, item, model, x, y, z, rx, ry, rz)
    local x, y, z, rx, ry, rz = convertPositionToHousePosition(houseId, x, y, z, rx, ry, rz)

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local position = table.concat({x, y, z, rx, ry, rz}, ',')
    local query = dbQuery(connection, 'INSERT INTO `m-furniture` (`houseId`, `owner`, `model`, `item`, `position`) VALUES (?, ?, ?, ?, ?)', houseId, owner, model, item, position)
    local result, num_affected_rows, last_insert_id = dbPoll(query, -1)
    if num_affected_rows == 0 then return end

    table.insert(houses[houseId].furniture, {
        uid = last_insert_id,
        houseId = houseId,
        owner = owner,
        model = model,
        item = item,
        position = position
    })

    return last_insert_id
end

function getHouseFurniture(houseId)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = dbQuery(connection, 'SELECT * FROM `m-furniture` WHERE `houseId` = ?', houseId)
    local result = dbPoll(query, -1)

    return result
end

function sendHouseFurnitureToPlayers(houseId, id)
    local players = getPlayersInHouse(houseId)
    if not players or #players == 0 then return end

    local houseData = houses[houseId]
    if not houseData then return end
    
    local furniture = table.findCallback(houseData.furniture, function(furniture)
        return furniture.uid == id
    end)
    if not furniture then return end

    triggerClientEvent(players, 'houses:updateFurniture', resourceRoot, furniture)
end

function removeHouseFurniture(id)
    if not client then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local houseId = getElementData(client, 'player:house')
    if not houseId then return end

    local houseData = houses[houseId]
    if not houseData then return end

    local furniture = table.findCallback(houseData.furniture, function(furniture)
        return furniture.uid == id
    end)
    if not furniture then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = dbQuery(connection, 'DELETE FROM `m-furniture` WHERE `uid` = ?', id)
    local result, num_affected_rows = dbPoll(query, -1)
    if num_affected_rows == 0 then return end

    table.remove(houseData.furniture, table.find(houseData.furniture, furniture))

    local players = getPlayersInHouse(houseId)
    if not players or #players == 0 then return end

    triggerClientEvent(players, 'houses:removeFurniture', resourceRoot, id)

    if furniture.owner == uid and furniture.item then
        exports['m-inventory']:addPlayerItem(client, furniture.item, 1)
        exports['m-notis']:addNotification(client, 'success', 'Edycja mebli', 'Mebel został usunięty z domu i dodany do twojego ekwipunku.')
    else
        exports['m-notis']:addNotification(client, 'success', 'Edycja mebli', 'Mebel został usunięty z domu.')
    end
end

addEventHandler('houses:removeFurniture', resourceRoot, removeHouseFurniture)