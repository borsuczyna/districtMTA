local serverSide = not localPlayer

local function hitShopMarker(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end
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
        setElementData(marker, 'marker:icon', 'work')
        setElementData(marker, 'shop:index', index)
        addEventHandler('onClientMarkerHit', marker, hitShopMarker)
        addEventHandler('onClientMarkerLeave', marker, leaveShopMarker)
    else
        blip = createBlip(x, y, z, 57, 2, 255, 100, 0, 255, 0, 9999.0)
        setElementData(blip, 'blip:hoverText', data.name)
    end
end

shopList = {
    createFishShop(823.530, -1920.196, 12.867),
    createFurnitureShop('toilet', 'Toalety', 2071.926, -1735.802, 13.547),
}

for i, shop in ipairs(shopList) do
    createShop(i, shop)
end