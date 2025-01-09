settings = {
    eventSpeed = 1
}

function assignLOD(element, dontDisableCollisions)
    local lod = createObject(getElementModel(element),0, 0 ,0, 0, 0, 0, true)
    setElementDimension(lod,getElementDimension(element))
    setElementPosition(lod, getElementPosition(element))
    setElementRotation(lod, getElementRotation(element))
    setElementData(lod,"element:model",getElementData(element,"element:model"))
    if not dontDisableCollisions then
        setElementCollisionsEnabled(lod, false)
    end
    setLowLODElement(element,lod)
    setObjectScale(lod,getObjectScale(element))
    attachElements(lod,element)
    return lod
end

function destroyElementWithLOD(element)
    if isElement(element) then
        local lod = getLowLODElement(element)
        if isElement(lod) then
            destroyElement(lod)
        end
        destroyElement(element)
    end
end

function setObjectScaleWithLod(element, scale)
    setObjectScale(element, scale)
    setObjectScale(getLowLODElement(element), scale)
end

function setElementDoubleSidedWithLOD(element, doubleSided)
    setElementDoubleSided(element, doubleSided)
    setElementDoubleSided(getLowLODElement(element), doubleSided)
end

function setElementAlphaWithLOD(element, alpha)
    if alpha < 0 then
        alpha = 0
    end
    setElementAlpha(element, alpha)
    setElementAlpha(getLowLODElement(element), alpha)
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

function inOutQuad(t, b)
    t = math.max(0, math.min(1, t))
    return t < 0.5 and 2 * t * t + b or -1 + (4 - 2 * t) * t + b
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function findRotation(x1,y1,x2,y2)
    local t = -math.deg(math.atan2(x2-x1,y2-y1))
    return t < 0 and t + 360 or t
end

function findRotation3D(pointA, pointB)
    local x1, y1, z1 = pointA[1], pointA[2], pointA[3]
    local x2, y2, z2 = pointB[1], pointB[2], pointB[3]
    
    local offX = x2 - x1
    local offY = y2 - y1
    local offZ = z2 - z1
    
    -- Calculate distance in the XY plane
    local distanceXY = math.sqrt(offX * offX + offY * offY)
    
    -- Calculate pitch (rotation around the X axis)
    local pitch = math.atan2(offZ, distanceXY)
    
    -- Calculate yaw (rotation around the Z axis)
    local yaw = math.atan2(offY, offX)
    
    -- Convert angles to degrees
    pitch = pitch * (180 / math.pi)
    yaw = yaw * (180 / math.pi)
    
    return pitch, yaw
end

function smallestAngleDiff( target, source )
    local a = target - source
    
    if (a > 180) then
       a = a - 360
    elseif (a < -180) then
       a = a + 360
    end
    
    return a
 end

function interpolateRotation(from, to, progress)
    local diff = smallestAngleDiff(to, from)
    return from + diff * progress
end

function interpolateRotation3D(from, to, progress)
    local pitch = interpolateRotation(from[1], to[1], progress)
    local yaw = interpolateRotation(from[2], to[2], progress)
    return pitch, yaw
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end