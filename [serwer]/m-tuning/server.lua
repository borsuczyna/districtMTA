addEvent('tuning:installItem')
addEvent('tuning:uninstallItem')
addEvent('tuning:exitGarage', true)
addEvent('tuning:getCompatibleUpgrades', true)

local timeouts = {}
local tuningShops = {
    {987.882, -1261.095, 15.2},
}

local function isPlayerTimeout(player)
    if not timeouts[player] then
        timeouts[player] = getTickCount()
        return false
    end

    if getTickCount() - timeouts[player] < 5000 then
        timeouts[player] = getTickCount()
        return true
    end

    timeouts[player] = getTickCount()
    return false
end

local function removeVehiclePassengers(vehicle)
    for i = 1, 4 do
        local passenger = getVehicleOccupant(vehicle, i)
        if passenger then
            removePedFromVehicle(passenger)
        end
    end
end

local function movePlayerToTuningShop(player)
    local vehicle = getPedOccupiedVehicle(player)
    local uid = getElementData(player, 'player:uid')
    toggleAllControls(player, false)
    setElementFrozen(vehicle, true)
    triggerClientEvent(player, 'tuning:enterGarage', resourceRoot)

    setTimer(function()
        local x, y, z = getElementPosition(vehicle)
        local rx, ry, rz = getElementRotation(vehicle)

        setElementData(player, 'tuning:oldPosition', {x, y, z, rx, ry, rz}, false)

        removeVehiclePassengers(vehicle)
        setElementPosition(vehicle, 986.847, -1253, 47.412)
        setElementRotation(vehicle, 0, 0, 270)
        setElementDimension(vehicle, 11000 + uid)
    end, 500, 1)
end

addEventHandler('tuning:exitGarage', resourceRoot, function()
    local vehicle = getPedOccupiedVehicle(client)
    local oldPosition = getElementData(client, 'tuning:oldPosition')
    if not oldPosition then return end

    isPlayerTimeout(client)
    setElementPosition(vehicle, oldPosition[1], oldPosition[2], oldPosition[3])
    setElementRotation(vehicle, oldPosition[4], oldPosition[5], oldPosition[6])
    setElementDimension(vehicle, 0)
    setElementFrozen(vehicle, false)
    toggleAllControls(client, true)
    removeElementData(client, 'tuning:oldPosition')
end)

addEventHandler('tuning:getCompatibleUpgrades', resourceRoot, function()
    local vehicle = getPedOccupiedVehicle(client)
    if not vehicle then return end

    -- local upgrades = exports['m-upgrades']:getVehicleCompatibleUpgrades(vehicle, id)
    -- triggerClientEvent(client, 'tuning:returnCompatibleUpgrades', resourceRoot, upgrades)

    local compatible = {}
    
    for _,slot in pairs(exports['m-upgrades']:getUpgradeSlots()) do
        local upgrades = exports['m-upgrades']:getVehicleCompatibleUpgrades(vehicle, slot)
        compatible[slot] = upgrades
    end

    triggerClientEvent(client, 'tuning:returnCompatibleUpgrades', resourceRoot, compatible)
end)

local function hitTuningMarker(player, matchingDimension)
    if not matchingDimension or getElementType(player) ~= 'player' then return end
    if not isPedInVehicle(player) then return end
    if isPlayerTimeout(player) then return end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then return end

    local vehicleUid = getElementData(vehicle, 'vehicle:uid')
    if not vehicleUid then
        exports['m-notis']:addNotification(player, 'error', 'Warsztat tuningowy', 'Tuningować można tylko prywatne pojazdy.')
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local vehicleOwner = getElementData(vehicle, 'vehicle:owner')
    if vehicleOwner ~= uid then
        exports['m-notis']:addNotification(player, 'error', 'Warsztat tuningowy', 'Nie jesteś właścicielem tego pojazdu.')
        return
    end

    removeVehiclePassengers(vehicle)
    movePlayerToTuningShop(player)
end

local function leaveTuningMarker(player, matchingDimension)
    if not matchingDimension or getElementType(player) ~= 'player' then return end
    triggerClientEvent(player, 'tuning:hideTuningMenu', resourceRoot)
end

local function createTuningShop(position)
    local marker = createMarker(position[1], position[2], position[3] - 1, 'cylinder', 3.5, 255, 100, 0, 0)
    setElementData(marker, 'marker:icon', 'mechanic')
    setElementData(marker, 'marker:title', 'Brama wjazdowa')
    setElementData(marker, 'marker:desc', 'Warsztat tuningowy')
    local blip = createBlipAttachedTo(marker, 7, 2, 255, 255, 255, 255, 0, 9999)
    setElementData(blip, 'blip:hoverText', 'Warsztat tuningowy')

    addEventHandler('onMarkerHit', marker, hitTuningMarker)
end

addEventHandler('onResourceStart', resourceRoot, function()
    for i, v in ipairs(tuningShops) do
        createTuningShop(v)
    end
end)

addEventHandler('tuning:installItem', root, function(hash, player, key, index)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end
    
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then return end

    local vehicleUid = getElementData(vehicle, 'vehicle:uid')
    if not vehicleUid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Tuningować można tylko prywatne pojazdy.'})
        return
    end

    if getVehicleController(vehicle) ~= player then return end

    vehicleTuningCategories = getVehicleUpgradeCategories(vehicle)

    local data = table.findCallback(vehicleTuningCategories, function(v, k)
        return v.key == key
    end)

    if not data then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono takiego tuningu. (1)'})
        return
    end
    
    data = data.items[index + 1]
    if not data then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono takiego tuningu. (2)'})
        return
    end

    if data.installed then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Ten tuning jest już zamontowany w tym pojeździe.'})
        return
    end
    
    local canInstall, reason = data.canInstall(vehicle)
    if not canInstall then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = reason})
        return
    end

    if getPlayerMoney(player) < data.price * 100 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz wystarczającej ilości gotówki.'})
        return
    end
    
    exports['m-core']:givePlayerMoney(player, 'tuning', ('Kupno tuningu %s do pojazdu (%d) %s'):format(data.name, vehicleUid, exports['m-models']:getVehicleName(vehicle)), -data.price * 100)
    data.install(player, vehicle)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zamontowano tuning.'})
    triggerClientEvent(player, 'tuning:updateOriginalTuning', resourceRoot)
end)

addEventHandler('tuning:uninstallItem', root, function(hash, player, key, index)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end
    
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then return end

    local vehicleUid = getElementData(vehicle, 'vehicle:uid')
    if not vehicleUid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Tuningować można tylko prywatne pojazdy.'})
        return
    end

    if getVehicleController(vehicle) ~= player then return end

    vehicleTuningCategories = getVehicleUpgradeCategories(vehicle)

    local data = table.findCallback(vehicleTuningCategories, function(v, k)
        return v.key == key
    end)

    if not data then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono takiego tuningu.'})
        return
    end
    
    data = data.items[index + 1]
    if not data then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono takiego tuningu.'})
        return
    end

    -- check if vehicle has this tuning
    if not data.installed then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Ten tuning nie jest zamontowany w tym pojeździe.'})
        return
    end
    
    exports['m-core']:givePlayerMoney(player, 'tuning', ('Demontaż tuningu %s z pojazdu (%d) %s'):format(data.name, vehicleUid, exports['m-models']:getVehicleName(vehicle)), data.price)
    data.uninstall(player, vehicle)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Odmontowano tuning.'})
    triggerClientEvent(player, 'tuning:updateOriginalTuning', resourceRoot)
end)

-- when player quits game when in car with eldata tuning:oldPosition, restore it
addEventHandler('onPlayerQuit', root, function()
    local vehicle = getPedOccupiedVehicle(source)
    if not vehicle then return end

    local oldPosition = getElementData(source, 'tuning:oldPosition')
    if not oldPosition then return end

    setElementPosition(vehicle, oldPosition[1], oldPosition[2], oldPosition[3])
    setElementRotation(vehicle, oldPosition[4], oldPosition[5], oldPosition[6])
    setElementDimension(vehicle, 0)
    setElementFrozen(vehicle, false)
end)