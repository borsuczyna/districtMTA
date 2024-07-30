local colaData = false
local colaObject = false

addEvent('jobs:burger:cola', true)
addEventHandler('jobs:burger:cola', resourceRoot, function(objectHash, timeData)
    colaData = timeData
    toggleMovement(false)

    setTimer(toggleMovement, timeData.finish - getServerTick(), 1, true)
end)

function createColaObject(interior)
    if colaObject then
        destroyElement(colaObject)
    end

    local x, y, z = getPositionFromElementOffset(interior, unpack(settings.cola.position))
    local rx, ry, rz = getElementRotation(interior)
    local arx, ary, arz = unpack(settings.cola.rotation)
    rx, ry, rz = rx + arx, ry + ary, rz + arz
    
    local object = createObject(1337, x, y, z, rx, ry, rz)
    setObjectScale(object, settings.cola.scale)
    setElementData(object, 'element:model', settings.cola.model)
    setElementCollisionsEnabled(object, false)
    setElementDimension(object, getElementDimension(localPlayer))
    colaObject = object
end

function destroyColaObject()
    if colaObject then
        destroyElement(colaObject)
        colaObject = false
    end
end

function updateColaData()
    if not colaData then return end
    local serverTick = getServerTick()

    if colaData.finish <= serverTick then
        colaData.start = colaData.finish
        colaData.finish = colaData.renew
        if colaData.finish <= serverTick then
            colaData = false
            return
        end
    end
    
    drawGrillProgress(colaObject, colaData, serverTick)
end