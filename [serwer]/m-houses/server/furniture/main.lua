local furnitureObjects = {}

function destroyPlayerFurnitureObject(player)
    if furnitureObjects[player] and isElement(furnitureObjects[player]) then
        destroyElement(furnitureObjects[player])
    end
end

function placeFurniture(player, key, state)
    if key ~= 'mouse1' or state ~= 'down' then return end
    if isCursorShowing(player) then return end

    local itemHash = getElementData(player, 'player:holdingFurniture')
    if not itemHash then return end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    -- local model = getElementModel(furnitureObjects[player])
    local model = getElementData(furnitureObjects[player], 'element:model') or getElementModel(furnitureObjects[player])
    stopFurniture(player, true)

    local houseId = getElementData(player, 'player:house')
    if not houseId then
        exports['m-notis']:addNotification(player, 'error', 'Edycja mebli', 'Nie jesteś w domu.')
        return
    end

    local itemData = exports['m-inventory']:getPlayerItem(player, itemHash)
    if not itemData then
        exports['m-notis']:addNotification(player, 'error', 'Edycja mebli', 'Nie posiadasz już tego mebla.')
        return
    end

    local x, y, z = getPositionFromElementOffset(player, 0, 0.8, 0)
    local rx, ry, rz = getElementRotation(player)

    local id = addHouseFurniture(houseId, uid, itemData.item, model, x, y, z - 1, rx, ry, rz)
    if not id then
        exports['m-notis']:addNotification(player, 'error', 'Edycja mebli', 'Nie udało się położyć mebla.')
        return
    end

    exports['m-inventory']:removePlayerItemByHash(player, itemHash, 1)
    sendHouseFurnitureToPlayers(houseId, id)
    setPlayerFurnitureEditMode(player, true, id)
end

function stopFurniture(player, noNotification)
    local holdingFurniture = getElementData(player, 'player:holdingFurniture')
    if not holdingFurniture then return end

    removeElementData(player, 'player:holdingFurniture')
    removeElementData(player, 'player:animation')
    destroyPlayerFurnitureObject(player)
    unbindKey(player, 'mouse1', 'down', placeFurniture)
    exports['m-inventory']:setItemMetadata(player, holdingFurniture, 'equipped', false)
    
    if not noNotification then
        exports['m-notis']:addNotification(player, 'info', 'Edycja mebli', 'Schowano mebel do ekwipunku.')
    end
end

function startFurniture(player, itemHash, furniture)
    setElementData(player, 'player:holdingFurniture', itemHash, false)
    exports['m-notis']:addNotification(player, 'info', 'Edycja mebli', 'Wyciągnięto mebel z ekwipunku, naciśnij <kbd class="keycap keycap-sm">LPM</kbd> aby go położyć i rozpocząć edycje.')

    destroyPlayerFurnitureObject(player)
    local isNumber = type(furniture.model) == 'number' or tonumber(furniture.model)
    local object = createObject(isNumber and tonumber(furniture.model) or 1337, 0, 0, 0)
    if not isNumber then
        setElementData(object, 'element:model', furniture.model)
    end

    setElementDoubleSided(object, true)
    exports['m-pattach']:attach(object, player, unpack(getFurnitureHoldPosition(furniture.item)))
    setElementData(player, 'player:animation', 'carry')

    furnitureObjects[player] = object
    bindKey(player, 'mouse1', 'down', placeFurniture)
end

function useFurniture(player, itemHash, furniture)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-notis']:addNotification(player, 'error', 'Edycja mebli', ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time))
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local isInside = getElementData(player, 'player:house')
    if not isInside then
        exports['m-notis']:addNotification(player, 'error', 'Edycja mebli', 'Nie jesteś w domu.')
        return
    end

    local houseData = houses[isInside]
    if not houseData then return end

    if houseData.owner ~= uid then
        exports['m-notis']:addNotification(player, 'error', 'Edycja mebli', 'Nie jesteś właścicielem tego domu.')
        return
    end

    local item = exports['m-inventory']:getPlayerItem(player, itemHash)

    local holdingFurniture = getElementData(player, 'player:holdingFurniture')
    if holdingFurniture then
        if holdingFurniture == itemHash then
            stopFurniture(player)
            return
        end

        exports['m-notis']:addNotification(player, 'error', 'Edycja mebli', 'Trzymasz już inny mebel w rękach.')
        return
    end

    exports['m-inventory']:setItemMetadata(player, itemHash, 'equipped', not equipped)
    startFurniture(player, itemHash, furniture)
end

addEventHandler('onPlayerQuit', root, function()
    destroyPlayerFurnitureObject(source)
end)