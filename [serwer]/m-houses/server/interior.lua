function getInteriorDefaultFurniture(houseId)
    local houseData = houses[houseId]
    if not houseData then return end

    if not houseData.furnitured then
        return {}
    end

    local interiorData = houseInteriors[houseData.interior[1]]
    local defaultFurniture = {}

    for k,v in pairs(interiorData.defaultFurniture) do
        table.insert(defaultFurniture, {
            model = v.model,
            position = table.concat(v.position, ','),
        })
    end

    return defaultFurniture
end

function getInteriorTextureNames(houseId)
    local houseData = houses[houseId]
    if not houseData then return end

    local interiorData = houseInteriors[houseData.interior[1]]
    return interiorData.textureNames
end

function sendPlayerInterior(player, houseData)
    if not isElement(player) then return end

    triggerClientEvent(player, 'houses:loadInterior', resourceRoot, {
        dimension = houseData.uid,
        interior = houseData.interior,
        furniture = houseData.owner and houseData.furniture or getInteriorDefaultFurniture(houseData.uid),
        textures = houseData.textures,
    })

    setElementDimension(player, houseData.uid)
    setElementData(player, 'player:house', houseData.uid, false)
end

function leaveHouse(player, houseData)
    if not isElement(player) then return end

    local houseId = houseData.uid
    local houseData = houses[houseId]
    if not houseData then return end

    local x, y, z = unpack(houseData.position)
    setElementDimension(player, 0)
    removeElementData(player, 'player:house')
    setElementPosition(player, x, y, z)
    setPlayerFurnitureEditMode(player, false)
    triggerClientEvent(player, 'houses:unloadInterior', resourceRoot)
end

function enterHouse(player, houseUid)
    local houseData = houses[houseUid]
    if not houseData then return end

    local isInside = getElementData(player, 'player:house')

    if isInside then
        exports['m-loading']:setLoadingVisible(player, true, 'Wczytywanie...', 1000)
        setTimer(leaveHouse, 600, 1, player, houseData)
        stopFurniture(player)
    else
        exports['m-loading']:setLoadingVisible(player, true, 'Wczytywanie interioru...', 1000)
        setTimer(sendPlayerInterior, 600, 1, player, houseData)
    end
end

function getPlayersInHouse(houseId)
    local players = {}
    for k,v in pairs(getElementsByType('player')) do
        if getElementData(v, 'player:house') == houseId then
            table.insert(players, v)
        end
    end
    return players
end

function removePlayersFromHouse(houseId, ignoredPlayer)
    local allPlayers = getPlayersInHouse(houseId)
    local players = {}

    if ignoredPlayer then
        for k,v in pairs(allPlayers) do
            if v ~= ignoredPlayer then
                table.insert(players, v)
            end
        end
    else
        players = allPlayers
    end

    exports['m-notis']:addNotification(players, 'warning', 'Dom', 'Zostałeś wyrzucony z domu.')

    for k,v in pairs(players) do
        exports['m-loading']:setLoadingVisible(v, true, 'Wczytywanie...', 1000)
        setTimer(leaveHouse, 600, 1, v, houses[houseId])
    end
end