addEvent('parking:getVehicles')
addEvent('parking:getVehicle')

local parkings = {
    {
        putBack = Vector3(1362.043, -1651.249, 12.383),
        take = Vector3(1359.125, -1647.297, 13.492-1),
        takeOut = Vector3(1362.422, -1643.260, 13.383),
        takeRotation = Vector3(0, 0, -90)
    },
    {
        putBack = Vector3(1909.975, -1859.318, 12.562),
        take = Vector3(1907.508, -1867.116, 13.565-1),
        takeOut = Vector3(1910.553, -1875.750, 13.527),
        takeRotation = Vector3(0, 0, -90)
    },
    {
        putBack = Vector3(2654.966, -2348.321, 13.633-1),
        take = Vector3(2653.490, -2355.822, 13.633-1),
        takeOut = Vector3(2661.730, -2348.471, 13.258),
        takeRotation = Vector3(0, 0, -90)
    },
}

function hidePrivateVehicle(hitElement)
    if getElementType(hitElement) ~= 'vehicle' then return end
    local driver = getVehicleOccupant(hitElement, 0)
    if not driver then return end

    local owner = getElementData(hitElement, 'vehicle:owner')
    if not owner then
        exports['m-notis']:addNotification(driver, 'error', 'Przechowalnia', 'Nie możesz schować tego pojazdu')
        return
    end

    local success, message = exports['m-core']:putVehicleIntoParking(hitElement)
    if success then
        exports['m-notis']:addNotification(driver, 'info', 'Przechowalnia', 'Twój pojazd został schowany')
    else
        exports['m-notis']:addNotification(driver, 'error', 'Przechowalnia', message)
    end
end

function loadParking(index, parking)
    parking.putBackMarker = createMarker(parking.putBack, 'cylinder', 3.5, 255, 0, 0, 0)
    setElementData(parking.putBackMarker, 'marker:title', 'Przechowalnia')
    setElementData(parking.putBackMarker, 'marker:desc', '0ddawanie pojazdu')
    addEventHandler('onMarkerHit', parking.putBackMarker, hidePrivateVehicle)
    local blip = createBlipAttachedTo(parking.putBackMarker, 44, 2, 255, 255, 255, 255, 0, 9999)
    setElementData(blip, 'blip:hoverText', 'Przechowalnia pojazdów')

    parking.takeMarker = createMarker(parking.take, 'cylinder', 1, 0, 255, 0, 0)
    setElementData(parking.takeMarker, 'marker:title', 'Przechowalnia')
    setElementData(parking.takeMarker, 'marker:desc', 'Odbiór pojazdu')
    setElementData(parking.takeMarker, 'parking:take', index)
end

addEventHandler('onResourceStart', resourceRoot, function()
    for i, parking in ipairs(parkings) do
        loadParking(i, parking)
    end
end)

addEventHandler('parking:getVehicles', root, function(hash, player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    exports['m-core']:getPlayerVehicles(player, hash, true, true, true)
end)

addEventHandler('parking:getVehicle', root, function(hash, player, parkingId, vehicleId)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local parking = parkings[parkingId]
    if not parking then return end

    local vehicle = exports['m-core']:getVehicleFromParking(player, hash, vehicleId, parking.takeOut, parking.takeRotation)
end)