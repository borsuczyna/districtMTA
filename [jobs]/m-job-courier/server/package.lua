addEvent('jobs:courier:packagePickup', true)
addEvent('jobs:courier:vehicleHit')

addEventHandler('jobs:courier:packagePickup', resourceRoot, function(objectHash)
    local object = exports['m-jobs']:getObjectByHash(client, objectHash)
    if not object then return end

    if isPedInVehicle(client) then
        exports['m-notis']:addNotification(client, 'error', 'Kurier', 'Nie możesz podnieść paczki będąc w pojeździe.')
        return
    end

    if isPlayerHoldingCart(client) then
        exports['m-notis']:addNotification(client, 'error', 'Kurier', 'Nie możesz podnieść paczki trzymając wózek.')
        return
    end

    if object.customData.state ~= 0 and object.customData.state ~= 2 then
        exports['m-notis']:addNotification(client, 'error', 'Kurier', 'Nie możesz podnieść tej paczki.')
        return
    end

    local playerPackage = getElementData(client, 'player:holdingPackage')
    if playerPackage then
        exports['m-notis']:addNotification(client, 'error', 'Kurier', 'Trzymasz już paczkę.')
        return
    end

    local cartObject = exports['m-jobs']:getLobbyData(client, 'cart:object')
    if not cartObject then
        exports['m-notis']:addNotification(client, 'error', 'Kurier', 'Nie posiadasz wózka.')
        return
    end

    exports['m-jobs']:setLobbyObjectCustomData(client, objectHash, 'state', 1)
    exports['m-jobs']:attachObjectToPlayer(client, objectHash, client, unpack(settings.packageAttach))
    exports['m-jobs']:detachObjectFromLobbyObject(client, objectHash, cartObject)
    exports['m-jobs']:detachObject(client, objectHash)
    setPedAnimation(client, "CARRY", "crry_prtial", 1, true, true, true, true)
    setElementData(client, 'player:holdingPackage', objectHash)
    toggleCartControls(client, false)
    exports['m-notis']:addNotification(client, 'info', 'Kurier', 'Podniosłeś paczkę.')

    local offset = exports['m-jobs']:getLobbyObjectCustomData(client, objectHash, 'offset')
    if offset then
        local success = freeCartOffset(client, offset)
        if success then
            changeLoadedPackages(client, -1)
        end
    end

    local offsetVehicle = exports['m-jobs']:getLobbyObjectCustomData(client, objectHash, 'offset-vehicle')
    if offsetVehicle then
        local success = freeCartOffset(client, offsetVehicle)
        if success then
            changeLoadedPackages(client, -1)
        end
        changeVehicleLoadedPackages(client, -1)
    end

    triggerClientEvent(client, 'jobs:courier:packagePickup', resourceRoot, objectHash)
end)

function leavePackage(player)
    local playerPackage = getElementData(player, 'player:holdingPackage')
    if not playerPackage then return end

    local cartObject = exports['m-jobs']:getLobbyData(player, 'cart:object')
    local offset, index, total = getFreeCartOffset(player)
    if not offset then
        exports['m-notis']:addNotification(player, 'error', 'Kurier', 'Wózek jest pełny.')
        return
    end

    exports['m-jobs']:detachObjectFromPlayer(player, playerPackage)
    exports['m-jobs']:attachObjectToLobbyObject(player, playerPackage, cartObject, unpack(offset))
    exports['m-jobs']:setLobbyObjectCustomData(player, playerPackage, 'state', 2)
    exports['m-jobs']:setLobbyObjectCustomData(player, playerPackage, 'offset', index)
    changeLoadedPackages(player, 1)
    setElementData(player, 'player:holdingPackage', nil)
    setPedAnimation(player, "CARRY", "crry_prtial", 2, true, false, false, false)
    toggleCartControls(player, true)
    triggerClientEvent(player, 'jobs:courier:packageDrop', resourceRoot, playerPackage)
end

addEventHandler('jobs:courier:vehicleHit', resourceRoot, function(hash, player, objectHash)
    if not isElement(player) or getElementType(player) ~= 'player' then return end

    if isPedInVehicle(player) then
        exports['m-notis']:addNotification(client, 'error', 'Kurier', 'Nie możesz podnieść paczki będąc w pojeździe.')
        return
    end

    if isPlayerHoldingCart(player) then return end

    local playerPackage = getElementData(player, 'player:holdingPackage')
    if not playerPackage then return end

    local vehicle = getJobVehicle(player)
    if not vehicle then return end

    local loaded, max = getLoadedVehiclePackages(player)
    if loaded >= max then
        exports['m-notis']:addNotification(player, 'error', 'Kurier', 'Pojazd jest pełny.')
        return
    end

    local offset, index = getFreeVehicleOffset(player)
    if not offset then
        exports['m-notis']:addNotification(player, 'error', 'Kurier', 'Pojazd jest pełny.')
        return
    end

    exports['m-jobs']:detachObjectFromPlayer(player, playerPackage)
    exports['m-jobs']:attachObject(player, playerPackage, vehicle, unpack(offset))
    exports['m-jobs']:setLobbyObjectCustomData(player, playerPackage, 'state', 2)
    exports['m-jobs']:setLobbyObjectCustomData(player, playerPackage, 'offset-vehicle', index)
    setElementData(player, 'player:holdingPackage', nil)
    setPedAnimation(player, "CARRY", "crry_prtial", 2, true, false, false, false)
    toggleCartControls(player, true)
    triggerClientEvent(player, 'jobs:courier:packageDrop', resourceRoot, playerPackage)
    changeVehicleLoadedPackages(player, 1)
end)

function isPlayerHoldingPackage(player)
    return getElementData(player, 'player:holdingPackage')
end

function destroyHoldingPackage(player)
    local playerPackage = getElementData(player, 'player:holdingPackage')
    if not playerPackage then return end

    exports['m-jobs']:destroyLobbyObject(player, playerPackage)
    setElementData(player, 'player:holdingPackage', nil)
    triggerClientEvent(player, 'jobs:courier:packageDrop', resourceRoot, playerPackage)
    setPedAnimation(player, "CARRY", "crry_prtial", 2, true, false, false, false)
    toggleCartControls(player, true)
end

function getFreeCartOffset(player)
    local usedOffsets = exports['m-jobs']:getLobbyData(player, 'cart:offsets') or {}
    local total = 0
    for i = 1, #usedOffsets do
        if usedOffsets[i] then
            total = total + 1
        end
    end

    for i = 1, #settings.cartOffsets do
        if not usedOffsets[i] then
            usedOffsets[i] = true
            exports['m-jobs']:setLobbyData(player, 'cart:offsets', usedOffsets)
            return settings.cartOffsets[i], i, total
        end
    end

    return false
end

function freeCartOffset(player, index)
    local usedOffsets = exports['m-jobs']:getLobbyData(player, 'cart:offsets') or {}
    local inUse = usedOffsets[index]
    usedOffsets[index] = false
    exports['m-jobs']:setLobbyData(player, 'cart:offsets', usedOffsets)
    return inUse
end

function getFreeVehicleOffset(player)
    local usedOffsets = exports['m-jobs']:getLobbyData(player, 'vehicle:offsets') or {}

    for i = 1, #settings.carOffsets do
        if not usedOffsets[i] then
            usedOffsets[i] = true
            exports['m-jobs']:setLobbyData(player, 'vehicle:offsets', usedOffsets)
            return settings.carOffsets[i], i
        end
    end

    return false
end

function freeVehicleOffset(player, index)
    local usedOffsets = exports['m-jobs']:getLobbyData(player, 'vehicle:offsets') or {}
    local inUse = usedOffsets[index]
    usedOffsets[index] = false
    exports['m-jobs']:setLobbyData(player, 'vehicle:offsets', usedOffsets)
    return inUse
end

function changeLoadedPackages(player, amount)
    local loaded, max = getLoadedPackages(player)
    if loaded + amount == max then
        local players = exports['m-jobs']:getLobbyPlayers(player)
        exports['m-notis']:addNotification(players, 'info', 'Kurier', 'Załadowano wystarczającą ilość paczek do wózka, odłóż je do pojazdu.')
    end

    exports['m-jobs']:setLobbyData(player, 'cart:loadedPackages', loaded + amount)
end

function changeVehicleLoadedPackages(player, amount)
    local loaded, max = getLoadedVehiclePackages(player)
    if loaded + amount == max and not exports['m-jobs']:getLobbyData(player, 'vehicle:loaded') then
        exports['m-jobs']:setLobbyData(player, 'vehicle:loaded', true)
        vehicleLoaded(player, loaded + amount)
    end

    exports['m-jobs']:setLobbyData(player, 'vehicle:loadedPackages', loaded + amount)
end

function getLoadedPackages(player)
    return exports['m-jobs']:getLobbyData(player, 'cart:loadedPackages'), exports['m-jobs']:getLobbyData(player, 'vehicle:packages')
end

function getLoadedVehiclePackages(player)
    return exports['m-jobs']:getLobbyData(player, 'vehicle:loadedPackages'), exports['m-jobs']:getLobbyData(player, 'vehicle:packages')
end