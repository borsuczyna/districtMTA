function sendPlayerInterior(player, houseData)
    if not isElement(player) then return end

    triggerClientEvent(player, 'houses:loadInterior', resourceRoot, {
        dimension = houseData.uid,
        interior = houseData.interior,
        furniture = houseData.furniture,
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

for k,v in pairs(getElementsByType('player')) do
    setElementDimension(v, 0)
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