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
    else
        blip = createBlip(x, y, z, 57, 2, 255, 100, 0, 255, 0, 9999.0)
        setElementInterior(blip, data.interior or 0)
        setElementData(blip, 'blip:hoverText', data.name)
    end
end

shopList = {
    createStationShop('Idlewood', 1925.296, -1771.964, 13.577),
    createFishShop(154.176, -1942.934, 3.769),
    createFurnitureShop('toilet', 'Sypialnia', 2054.112, -1075.416, 126.458, 1),
    createFurnitureShop('toilet', 'Salon', 2053.505, -1081.298, 126.458, 1),
    createFurnitureShop('toilet', 'Kuchnia', 1910.776, -1743.806, 114.547, 1),
    createFurnitureShop('toilet', 'Biuro', 1911.373, -1738.374, 114.547, 1),
    createFurnitureShop('toilet', 'Bufet', 1911.586, -1749.421, 114.547, 1),
}

for i, shop in ipairs(shopList) do
    createShop(i, shop)
end