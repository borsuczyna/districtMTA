local attachedEffects = {}

-- Taken from https://wiki.multitheftauto.com/wiki/GetElementMatrix example
function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z  -- Return the transformed point
end

function attachEffect(effect, element, pos)
    attachedEffects[effect] = { effect = effect, element = element, pos = pos }
    addEventHandler("onClientElementDestroy", effect, function() attachedEffects[effect] = nil end)
    addEventHandler("onClientElementDestroy", element, function() attachedEffects[effect] = nil end)
    return true
end

addEventHandler("onClientPreRender", root, function()
    for fx, info in pairs(attachedEffects) do
        local x, y, z = getPositionFromElementOffset(info.element, info.pos.x, info.pos.y, info.pos.z)
        setElementPosition(fx, x, y, z)
    end
end)