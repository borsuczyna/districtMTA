local fries = {}

function loadFries(interior)
    for i, data in ipairs(settings.fries) do
        local x, y, z = getPositionFromElementOffset(interior, unpack(data.position))
        local rx, ry, rz = getElementRotation(interior)
        local arx, ary, arz = unpack(data.rotation)
        rx, ry, rz = rx + arx, ry + ary, rz + arz
        
        local object = createObject(1337, x, y, z, rx, ry, rz)
        setObjectScale(object, data.scale)
        setElementData(object, 'element:model', 'burger/fryer-grid')
        setElementCollisionsEnabled(object, false)
        setElementDimension(object, getElementDimension(localPlayer))
        fries[i] = object
    end
end

function clearFries()
    for i, object in ipairs(fries) do
        destroyElement(object)
    end

    fries = {}
end