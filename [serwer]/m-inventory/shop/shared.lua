local serverSide = not localPlayer

local function hitShopMarker(hitElement, matchingDimension)
    local markerInterior = getElementInterior(source)
    local myInterior = getElementInterior(localPlayer)
    if hitElement ~= localPlayer or not matchingDimension or markerInterior ~= myInterior then return end
    if getPedOccupiedVehicle(localPlayer) then return end

    local title = getElementData(source, 'marker:title')
    local desc = getElementData(source, 'marker:desc')
    local index = getElementData(source, 'shop:index')
    if not title or not desc or not index then return end

    toggleShopUI(true, {
        title = title,
        description = desc,
        index = index,
        items = shopList[index].items
    })
end

local function leaveShopMarker(leaveElement, matchingDimension)
    if leaveElement ~= localPlayer or not matchingDimension then return end
    local index = getElementData(source, 'shop:index')
    if not index then return end

    toggleShopUI(false)
end

function createShop(index, data)
    local x, y, z = unpack(data.position)
    local marker, blip = nil, nil
    
    if not serverSide then
        marker = createMarker(x, y, z - 1, 'cylinder', 1, 100, 0, 255, 150)
        setElementData(marker, 'marker:title', data.name)
        setElementData(marker, 'marker:desc', data.description)
        setElementData(marker, 'marker:icon', 'cart')
        setElementData(marker, 'shop:index', index)
        setElementInterior(marker, data.interior or 0)
        addEventHandler('onClientMarkerHit', marker, hitShopMarker)
        addEventHandler('onClientMarkerLeave', marker, leaveShopMarker)
    elseif not data.noBlip then
        blip = createBlip(x, y, z, 57, 2, 255, 100, 0, 255, 0, 9999.0)
        setElementInterior(blip, data.interior or 0)
        setElementData(blip, 'blip:hoverText', data.name)
    end
end

shopList = {
    createFoodCart('Idlewood', 2039.889, -1823.895, 13.547, 180),
    createFoodCart('Market', 979.467, -1444.648, 13.586, -90),
    createFoodCart('Market', 831.180, -1335.514, 13.547, 90),
    createFoodCart('Market', 998.031, -1267.614, 15.187, 180),
    createFoodCart('Glen Park', 2005.898, -1180.841, 19.733, 240),
    createFoodCart('Jefferson', 2087.410, -1292.812, 23.973, -90),
    createFoodCart('Łowisko', 2987.419, -1983.5, 11.109, 90),

    createStationShop('Idlewood', 1925.296, -1771.964, 13.577, 0),
    createStationShop('Glen Park', 2.211, -28.779, 1003.549, 10),
    createStationShop('Blueberry', 251.520, -56.787, 1.570, 0),
    createFishShop(2998.540, -1961.980, 11.109),

    createFurnitureShop('salon', 'Salon', 2022.815, -1318.151, 124.991, 1),
    createFurnitureShop('kitchen', 'Kuchnia', 2030.227, -1311.097, 124.991, 1),
    createFurnitureShop('bathroom', 'Łazienka', 2029.594, -1317.517, 124.991, 1),
    createFurnitureShop('bedroom', 'Sypialnia', 2022.797, -1312.786, 124.991, 1),

    createBlankCardShop('Playa del seville', 2869.743, -2125.309, 5.096, 0),
}

for i, shop in ipairs(shopList) do
    createShop(i, shop)
end