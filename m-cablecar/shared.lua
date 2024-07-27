cableCars = {
    {
        start = Vector3(1180.5, -1987.379, 72.75),
        finish = Vector3(1180.7, -1696.253, 18),
        lineStart = Vector3(1180.698, -1991.684, 73.5),
        lineFinish = Vector3(1180.7, -1696.253, 18),
        drawDistance = 400
    },
    {
        start = Vector3(1174.57, -1696.253, 18),
        finish = Vector3(1174.4, -1987.379, 72.75),
        lineStart = Vector3(1174.57, -1696.253, 18),
        lineFinish = Vector3(1174.4, -1991.684, 73.5),
        drawDistance = 400
    }
}

doorsPositions = {
    [1] = {
        Vector3(1.234, 1.88, -2),
        Vector3(1.234, 0.53, -2),
        Vector3(1.134, 0.53, -2),
        rotation = Vector3(0, 0, 0)
    },
    [2] = {
        Vector3(1.234, -2.067, -2),
        Vector3(1.234, -0.767, -2),
        Vector3(1.134, -0.767, -2),
        rotation = Vector3(0, 0, 0)
    },
    [3] = {
        Vector3(-1.234, 1.88, -2),
        Vector3(-1.234, 0.53, -2),
        Vector3(-1.134, 0.53, -2),
        rotation = Vector3(0, 0, 180)
    },
    [4] = {
        Vector3(-1.234, -2.067, -2),
        Vector3(-1.234, -0.767, -2),
        Vector3(-1.134, -0.767, -2),
        rotation = Vector3(0, 0, 180)
    }
}

cableCarOffset = Vector3(0, 0, -1.55)

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function findRotation3D(a, b)
    local offX = b.x - a.x
    local offY = b.y - a.y
    local offZ = b.z - a.z

    local distanceXY = math.sqrt(offX * offX + offY * offY)
    local pitch = math.atan2(offZ, distanceXY)
    local yaw = math.atan2(offY, offX)

    pitch = pitch * (180 / math.pi)
    yaw = yaw * (180 / math.pi)

    return Vector3(pitch, 0, yaw - 90)
end

function assignLOD(element)
    local lod = createObject(getElementModel(element),0, 0 ,0, 0, 0, 0, true)
    setElementDimension(lod,getElementDimension(element))
    setElementPosition(lod, getElementPosition(element))
    setElementRotation(lod, getElementRotation(element))
    setElementCollisionsEnabled(lod,false)
    setLowLODElement(element,lod)
    setElementData(lod,'element:model',getElementData(element,'element:model'))
    attachElements(lod,element)
    return lod
end