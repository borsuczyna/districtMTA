addEvent('houses:loadInterior', true)

local interior = false

local function destroyHouseInterior()
    if not interior then return end

    destroyElement(interior.mainObject)
    destroyElement(interior.marker)

    interior = false
end

local function loadInterior(data)
    destroyHouseInterior()

    local interiorId, x, y, z, rotation = unpack(data.interior)
    local interiorData = houseInteriors[interiorId]
    if not interiorData then return end

    local mainObject = createObject(1337, x, y, z, 0, 0, rotation)
    setElementDimension(mainObject, data.dimension)
    setElementData(mainObject, 'element:model', interiorData.model)

    interior = {
        mainObject = mainObject,
    }

    local spawn = {getRelativeInteriorPosition(mainObject, interiorData.enter[1], interiorData.enter[2], interiorData.enter[3], 0, 0, interiorData.enter[4])}
    setElementPosition(localPlayer, spawn[1], spawn[2], spawn[3])
    setElementRotation(localPlayer, 0, 0, spawn[6], 'default', true)
    setCameraTarget(localPlayer)

    local marker = createMarker(spawn[1], spawn[2], spawn[3] - 1, 'cylinder', 1, 0, 0, 255, 0)
    setElementDimension(marker, data.dimension)
    setElementData(marker, 'marker:title', 'Dom')
    setElementData(marker, 'marker:desc', 'Wyjście z domu')
    setElementData(marker, 'marker:house', data.dimension)

    interior.marker = marker
end

addEventHandler('houses:loadInterior', resourceRoot, loadInterior)