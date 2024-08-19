addEvent('houses:setTexture')
addEvent('houses:resetTextures')

addEventHandler('houses:setTexture', root, function(hash, player, houseUid, textureId, texture)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    local textureNames = getInteriorTextureNames(houseUid)
    if not textureNames[textureId + 1] then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Podana tekstura nie istnieje.'})
        return
    end

    if texture ~= -1 and not interiorTextures[texture + 1] then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Podana tekstura nie istnieje.'})
        return
    end

    local canEdit = house.owner == uid
    if not canEdit then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz dostępu do edycji mebli w tym domu.'})
        return
    end

    if texture ~= -1 then
        local query = 'INSERT `m-house-textures` SET `houseId` = ?, `textureId` = ?, `texture` = ? ON DUPLICATE KEY UPDATE `texture` = ?'
        exports['m-mysql']:execute(query, houseUid, textureId, texture, texture)
    else
        local query = 'DELETE FROM `m-house-textures` WHERE `houseId` = ? AND `textureId` = ?'
        exports['m-mysql']:execute(query, houseUid, textureId)
    end

    local textureData, index = table.findCallback(house.textures, function(v)
        return v.textureId == textureId
    end)

    if texture ~= -1 then
        if textureData then
            textureData.texture = texture
        else
            table.insert(house.textures, {textureId = textureId, texture = texture})
        end
    else
        if textureData then
            table.remove(house.textures, index)
        end
    end

    sendTextureChange(houseUid, textureId, texture)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zmieniono wystrój wnętrza.'})
end)

addEventHandler('houses:resetTextures', root, function(hash, player, houseUid)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    local canEdit = house.owner == uid
    if not canEdit then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz dostępu do edycji mebli w tym domu.'})
        return
    end

    local query = 'DELETE FROM `m-house-textures` WHERE `houseId` = ?'
    exports['m-mysql']:execute(query, houseUid)

    house.textures = {}

    sendResetTextures(houseUid)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zresetowano wystrój wnętrza.'})
end)

function sendTextureChange(houseUid, textureId, texture)
    local house = houses[houseUid]
    if not house then return end

    local players = getPlayersInHouse(houseUid)
    if not players or #players == 0 then return end

    triggerClientEvent(players, 'houses:textureChange', resourceRoot, textureId, texture)
end

function sendResetTextures(houseUid)
    local house = houses[houseUid]
    if not house then return end

    local players = getPlayersInHouse(houseUid)
    if not players or #players == 0 then return end

    triggerClientEvent(players, 'houses:resetTextures', resourceRoot)
end