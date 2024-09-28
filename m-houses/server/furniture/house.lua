addEvent('houses:removeFurniture', true) -- args: id
addEvent('houses:changeFurnitureTexture', true) -- args: id
addEvent('houses:saveFurniture', true) -- args: id, x, y, z, rx, ry, rz

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
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `houses:removeFurniture` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if not client then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local limited, time = isPlayerRateLimited(client)
    if limited then
        exports['m-notis']:addNotification(client, 'error', 'Edycja mebli', ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time))
        return
    end

    local houseId = getElementData(client, 'player:house')
    if not houseId then return end

    local houseData = houses[houseId]
    if not houseData then return end

    if houseData.owner ~= uid then
        exports['m-notis']:addNotification(client, 'error', 'Edycja mebli', 'Nie jesteś właścicielem tego domu.')
        return
    end

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

function changeHouseFurnitureTexture(id)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `houses:changeFurnitureTexture` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if not client then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local limited, time = isPlayerRateLimited(client)
    if limited then
        exports['m-notis']:addNotification(client, 'error', 'Edycja mebli', ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time))
        return
    end

    local houseId = getElementData(client, 'player:house')
    if not houseId then return end

    local houseData = houses[houseId]
    if not houseData then return end

    if houseData.owner ~= uid then
        exports['m-notis']:addNotification(client, 'error', 'Edycja mebli', 'Nie jesteś właścicielem tego domu.')
        return
    end

    local furniture = table.findCallback(houseData.furniture, function(furniture)
        return furniture.uid == id
    end)
    if not furniture then return end

    local furnitureData = exports['m-inventory']:getFurnitureByModel(furniture.model)
    if not furnitureData or not furnitureData.textures then return end

    furniture.texture = furniture.texture or 1
    furniture.texture = furniture.texture + 1

    if furniture.texture > #furnitureData.textures then
        furniture.texture = 1
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = dbQuery(connection, 'UPDATE `m-furniture` SET `texture` = ? WHERE `uid` = ?', furniture.texture, id)
    local result, num_affected_rows = dbPoll(query, -1)
    if num_affected_rows == 0 then return end

    local players = getPlayersInHouse(houseId)
    if not players or #players == 0 then return end

    triggerClientEvent(players, 'houses:updateFurniture', resourceRoot, furniture)
end

function saveHouseFurniture(id, x, y, z, rx, ry, rz)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `houses:saveFurniture` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if not client then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local limited, time = isPlayerRateLimited(client)
    if limited then
        exports['m-notis']:addNotification(client, 'error', 'Edycja mebli', ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time))
        return
    end

    local houseId = getElementData(client, 'player:house')
    if not houseId then return end

    local houseData = houses[houseId]
    if not houseData then return end

    if houseData.owner ~= uid then
        exports['m-notis']:addNotification(client, 'error', 'Edycja mebli', 'Nie jesteś właścicielem tego domu.')
        return
    end

    local furniture = table.findCallback(houseData.furniture, function(furniture)
        return furniture.uid == id
    end)
    if not furniture then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local position = table.concat({convertPositionToHousePosition(houseId, x, y, z, rx, ry, rz)}, ',')
    local query = dbQuery(connection, 'UPDATE `m-furniture` SET `position` = ? WHERE `uid` = ?', position, id)
    local result, num_affected_rows = dbPoll(query, -1)
    if num_affected_rows == 0 then return end

    furniture.position = position

    local players = getPlayersInHouse(houseId)
    if not players or #players == 0 then return end

    triggerClientEvent(players, 'houses:updateFurniture', resourceRoot, furniture)
end

function removeAllHouseFurniture(houseId)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local itemsToGive = {}
    for _, furniture in ipairs(houses[houseId].furniture) do
        if furniture.owner and furniture.item then
            if not itemsToGive[furniture.owner] then
                itemsToGive[furniture.owner] = {}
            end

            table.insert(itemsToGive[furniture.owner], furniture.item)
        end
    end

    for owner, items in pairs(itemsToGive) do
        exports['m-inventory']:addPlayerItemsOffline(owner, items)
        
        local items = '`' .. table.concat(items, '`, `') .. '`'
        exports['m-logs']:sendLog('houses', 'info', ('Meble z domu %d zostały zwrócone do gracza %d: %s'):format(houseId, owner, items))
    end

    local query = dbQuery(connection, 'DELETE FROM `m-furniture` WHERE `houseId` = ?', houseId)
    local result, num_affected_rows = dbPoll(query, -1)
    if num_affected_rows == 0 then return end

    houses[houseId].furniture = {}
end

function addDefaultHouseFurniture(uid)
    local furniture = getInteriorDefaultFurniture(uid)
    if not furniture or #furniture == 0 then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end
    
    for _, data in ipairs(furniture) do
        local query = 'INSERT INTO `m-furniture` (`houseId`, `model`, `position`) VALUES (?, ?, ?)'
        dbExec(connection, query, uid, data.model, data.position)
    end

    local houseData = houses[uid]
    if not houseData then return end

    local query = dbQuery(connection, 'SELECT * FROM `m-furniture` WHERE `houseId` = ?', uid)
    local result = dbPoll(query, -1)

    houseData.furniture = result
end

addEventHandler('houses:removeFurniture', resourceRoot, removeHouseFurniture)
addEventHandler('houses:changeFurnitureTexture', resourceRoot, changeHouseFurnitureTexture)
addEventHandler('houses:saveFurniture', resourceRoot, saveHouseFurniture)

addCommandHandler('hgp', function(plr)
    local houseId = getElementData(plr, 'player:house')
    if not houseId then return end

    local x, y, z = getElementPosition(plr)
    local rx, ry, rz = getElementRotation(plr)
    x, y, z, rx, ry, rz = convertPositionToHousePosition(houseId, x, y, z, rx, ry, rz)

    local code = ('{%.2f, %.2f, %.2f, %.2f, %.2f, %.2f}'):format(x, y, z, rx, ry, rz)
    outputChatBox(code, plr)
    triggerClientEvent(plr, 'interface:setClipboard', root, code)
end)