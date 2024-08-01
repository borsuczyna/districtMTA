addEvent('jobs:burger:fryer', true)
addEvent('jobs:burger:fryerFinish', true)
addEvent('jobs:burger:fryerBurn', true)

local fries = {}
local fryers = {}
local effects = {}
local friesData = {}
local friesSounds = {}

function loadFryers(interior)
    for i, data in ipairs(settings.fryers) do
        local x, y, z = getPositionFromElementOffset(interior, unpack(data.position))
        local rx, ry, rz = getElementRotation(interior)
        local arx, ary, arz = unpack(data.rotation)
        rx, ry, rz = rx + arx, ry + ary, rz + arz
        
        local object = createObject(1337, x, y, z, rx, ry, rz)
        setObjectScale(object, data.scale)
        setElementData(object, 'element:model', 'burger/fryer-grid')
        setElementCollisionsEnabled(object, false)
        setElementDimension(object, getElementDimension(localPlayer))
        fryers[i] = object
    end
end

function clearFryers()
    for i, object in ipairs(fryers) do
        destroyElement(object)
    end

    for i, object in ipairs(effects) do
        destroyElement(object)
    end

    for i, object in ipairs(fries) do
        destroyElement(object)
    end

    fries = {}
    fryers = {}
    effects = {}
end

local function setEffect(fryerId, name, density)
    if effects[fryerId] then
        destroyElement(effects[fryerId])
    end

    effects[fryerId] = nil

    if not name then return end
    local x, y, z = getElementPosition(fryers[fryerId])
    local effect = createEffect(name, x, y, z)
    setEffectDensity(effect, density or 0.2)
    setElementDimension(effect, getElementDimension(localPlayer))

    effects[fryerId] = effect
end

addEventHandler('jobs:burger:fryer', resourceRoot, function(fryerId, objectHash, data)
    if fries[fryerId] then
        destroyElement(fries[fryerId])
    end

    if friesSounds[fryerId] and isElement(friesSounds[fryerId]) then
        stopSound(friesSounds[fryerId])
    end

    friesData[fryerId] = nil
    fries[fryerId] = nil
    friesSounds[fryerId] = nil
    setEffect(fryerId, false)

    if objectHash then
        local fryerObject = exports['m-jobs']:getObjectByHash(objectHash)
        if not fryerObject then return end

        local layData = settings.layPositions['burger/fryer-fries']
        local ax, ay, az = unpack(layData.position)
        local arx, ary, arz = unpack(layData.rotation or {0, 0, 0})

        local x, y, z = getElementPosition(fryers[fryerId])
        moveObject(fryers[fryerId], 150, x, y, z - 0.1)

        local object = createObject(1337, 0, 0, 0)
        setElementData(object, 'element:model', 'burger/fries')
        setObjectScale(object, layData.scale)
        setElementDimension(object, getElementDimension(localPlayer))
        setElementCollisionsEnabled(object, false)
        attachElements(object, fryers[fryerId], ax, ay, az, arx, ary, arz)

        fries[fryerId] = object
        friesData[fryerId] = data
        friesSounds[fryerId] = playSound('data/grill.wav')
        playSound('data/click.wav')
        setEffect(fryerId, 'vent', 0.8)
    else
        local x, y, z = getElementPosition(fryers[fryerId])
        moveObject(fryers[fryerId], 150, x, y, z + 0.1)
    end
end)

function updateFryersCook()
    local serverTick = getServerTick()
    
    for i, frie in pairs(fries) do
        if not isElement(frie) then
            fries[i] = nil
            friesData[i] = nil
            effects[i] = nil
            return
        end

        local data = friesData[i]
        if not data then return end

        drawGrillProgress(frie, data, serverTick)
    end
end

addEventHandler('jobs:burger:fryerFinish', resourceRoot, function(fryerId)
    if fries[fryerId] and isElement(fries[fryerId]) then
        setElementData(fries[fryerId], 'element:model', 'burger/fries-cooked')
    end
end)

addEventHandler('jobs:burger:fryerBurn', resourceRoot, function(fryerId, objectHash)
    if fries[fryerId] and isElement(fries[fryerId]) then
        setElementData(fries[fryerId], 'element:model', 'burger/fries-burned')

        setEffect(fryerId, 'fire', 0.2)
        playSound('data/burn.wav')
    end
end)