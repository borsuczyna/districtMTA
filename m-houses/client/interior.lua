addEvent('houses:loadInterior', true)
addEvent('houses:unloadInterior', true)
addEvent('houses:ringBell', true)
addEvent('houses:updateFurniture', true)
addEvent('houses:removeFurniture', true)

local interior = false
local textures = {}
local shaders = {}

local function getFurnitureTexture(path)
    if not textures[path] then
        textures[path] = dxCreateTexture(('data/furniture-textures/%s.png'):format(path))
    end

    return textures[path]
end

local function getFurnitureShaderTexture(path)
    if not shaders[path] then
        shaders[path] = dxCreateShader('data/shader.fx')
        dxSetShaderValue(shaders[path], 'Tex0', getFurnitureTexture(path))
    end

    return shaders[path]
end

local function destroyFurnitureTextures()
    for path, texture in pairs(textures) do
        destroyElement(texture)
    end

    textures = {}
end

local function destroyHouseInterior()
    if not interior then return end

    destroyElement(interior.mainObject)
    destroyElement(interior.marker)
    destroyInteriorTextures()
    destroyFurnitureTextures()

    if interior.furniture then
        for i, data in ipairs(interior.furniture) do
            if data.object and isElement(data.object) then
                destroyElement(data.object)
            end
        end
    end

    interior = false
end

local function loadFurnitureObject(data)
    if data.object and isElement(data.object) then
        destroyElement(data.object)
    end

    if data.shader and isElement(data.shader) then
        destroyElement(data.shader)
    end

    local spawn = map(split(data.position, ','), tonumber)
    spawn = {getRelativeInteriorPosition(interior.mainObject, spawn[1], spawn[2], spawn[3], spawn[4], spawn[5], spawn[6])}

    local isNumber = type(data.model) == 'number' or tonumber(data.model)
    local object = createObject(isNumber and tonumber(data.model) or 1337, unpack(spawn))
    if not isNumber then
        setElementData(object, 'element:model', data.model)
    end

    if data.texture then
        local furnitureData = exports['m-inventory']:getFurnitureByModel(data.model)

        local texture = furnitureData.textures[data.texture]
        if texture then
            local shaderTexture = getFurnitureShaderTexture(texture)
            engineApplyShaderToWorldTexture(shaders[texture], furnitureData.textures[1], object)
        end
    end

    setElementDimension(object, interior.dimension)

    data.object = object
end

local function loadFurniture()
    if not interior.furniture then return end

    for i, data in ipairs(interior.furniture) do
        loadFurnitureObject(data)
    end
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
        furniture = data.furniture,
        dimension = data.dimension,
        interiorData = interiorData
    }

    loadInteriorTextures(interiorData, mainObject, data.textures)

    local spawn = {getRelativeInteriorPosition(mainObject, interiorData.enter[1], interiorData.enter[2], interiorData.enter[3], 0, 0, interiorData.enter[4])}
    setElementPosition(localPlayer, spawn[1], spawn[2], spawn[3])
    setElementRotation(localPlayer, 0, 0, spawn[6], 'default', true)
    setCameraTarget(localPlayer)

    local marker = createMarker(spawn[1], spawn[2], spawn[3] - 1, 'cylinder', 1, 0, 0, 255, 0)
    setElementDimension(marker, data.dimension)
    setElementData(marker, 'marker:title', 'Dom')
    setElementData(marker, 'marker:desc', 'Wyjście z domu')
    setElementData(marker, 'marker:house', data.dimension)
    
    loadFurniture()

    interior.marker = marker
end

function resetInteriorTextures()
    if not interior then return end

    loadInteriorTextures(interior.interiorData, interior.mainObject, {})
end

function getFurnitureData(id)
    return table.findCallback(interior.furniture, function(furniture)
        return furniture.uid == id
    end)
end

function getInteriorFurniture()
    return interior.furniture
end

function getInteriorObject()
    return interior.mainObject
end

function getInteriorData()
    return interior.interiorData
end

addEventHandler('houses:loadInterior', resourceRoot, loadInterior)
addEventHandler('houses:unloadInterior', resourceRoot, destroyHouseInterior)

addEventHandler('houses:ringBell', resourceRoot, function(position, player)
    local sound = playSound3D('data/doorbell.wav', unpack(position))
    setElementDimension(sound, getElementDimension(localPlayer))
    setSoundMinDistance(sound, 4)
    setSoundMaxDistance(sound, 30)
    exports['m-notis']:addNotification('info', 'Dzwonek do drzwi', 'Gracz ' .. htmlEscape(getPlayerName(player)) .. ' dzwoni do drzwi')
end)

addEventHandler('houses:updateFurniture', resourceRoot, function(furniture)
    if not interior then return end

    local furnitureData, index = getFurnitureData(furniture.uid)
    
    if index then
        furnitureData.model = furniture.model
        furnitureData.position = furniture.position
        furnitureData.rotation = furniture.rotation
        furnitureData.texture = furniture.texture

        loadFurnitureObject(furnitureData)
    else
        table.insert(interior.furniture, furniture)
        loadFurnitureObject(furniture)
    end
end)

addEventHandler('houses:removeFurniture', resourceRoot, function(uid)
    if not interior then return end

    local furnitureData, index = getFurnitureData(uid)
    if not index then return end

    if furnitureData.object and isElement(furnitureData.object) then
        destroyElement(furnitureData.object)
    end

    table.remove(interior.furniture, index)
end)