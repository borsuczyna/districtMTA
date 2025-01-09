addEvent('houses:getData', true)
addEvent('houses:refetchHouseData')
addEvent('houses:hideInterface')

local currentHouseId = nil

addEventHandler('onClientMarkerHit', root, function(element, matchingDimension)
    if not source then return end
    if element ~= localPlayer or not matchingDimension or getPedOccupiedVehicle(localPlayer) then return end

    local houseId = getElementData(source, 'marker:house')
    if not houseId then return end

    currentHouseId = houseId
    triggerServerEvent('houses:getData', resourceRoot, houseId)
end)

addEventHandler('onClientMarkerLeave', root, function(element, matchingDimension)
    if element ~= localPlayer or not matchingDimension or getPedOccupiedVehicle(localPlayer) then return end

    local houseId = getElementData(source, 'marker:house')
    if not houseId then return end

    setHousesUIVisible(false)
end)

addEventHandler('houses:getData', resourceRoot, function(data)
    if not data then return end

    local interiorData = houseInteriors[data.interior[1]]
    if not interiorData then return end

    data.interiorData = interiorData
    data.furnitureData = exports['m-inventory']:getFurnitures()
    data.furnitureShops = exports['m-furniture-shop']:getShops()
    setHousesUIVisible(true, data)
end)

addEventHandler('houses:refetchHouseData', root, function()
    if not currentHouseId then return end

    setHousesUIVisible(false)
    triggerServerEvent('houses:getData', resourceRoot, currentHouseId)
end)

addEventHandler('houses:hideInterface', root, function()
    setHousesUIVisible(false)
end)