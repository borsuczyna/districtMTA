addEvent('createJobTarget', true)
addEvent('destroyJobTarget', true)

local target = nil
local scale = 0.5

function formatDistance(distance)
    if distance < 1000 then
        return math.floor(distance) .. ' m'
    end

    return string.format('%.1f km', distance / 1000)
end

function renderTarget()
    if not target then
        return
    end

    local x, y, z = getElementPosition(target)
    local sx, sy = getScreenFromWorldPosition(x, y, z + 1)

    if not sx or not sy then
        return
    end

    local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer)) * 1.5

    if dist < 40 then
        return
    end

    local foa = formatDistance(dist)

    dxDrawRectangle(sx - 50 * scale, sy - 50 * scale, 100 * scale, 100 * scale, tocolor(0, 0, 0, 150), false, true)
    dxDrawLine(sx - 35 * scale, sy - 35 * scale, sx + 35 * scale, sy + 35 * scale, tocolor(255, 175, 0, 150), 2, false, true)
    dxDrawLine(sx - 35 * scale, sy + 35 * scale, sx + 35 * scale, sy - 35 * scale, tocolor(255, 175, 0, 150), 2, false, true)

    dxDrawText(foa, sx + 1, sy + 51, sx + 1, sy + 51, tocolor(0, 0, 0), 1, 'default', 'center', 'bottom', false, false, true)
    dxDrawText(foa, sx, sy + 50, sx, sy + 50, tocolor(255, 255, 255), 1, 'default', 'center', 'bottom', false, false, true)
end

function createJobTarget(x, y, z)
    if target ~= nil then
        return
    end

    target = createElement('jobTarget')
    setElementPosition(target, x, y, z)

    addEventHandler('onClientRender', root, renderTarget)

    addEventHandler('onClientElementDestroy', target, function()
        target = nil

        removeEventHandler('onClientRender', root, renderTarget)
    end)
end
addEventHandler('createJobTarget', resourceRoot, createJobTarget)

function destroyJobTarget()
    if target == nil then
        return
    end

    destroyElement(target)
end
addEventHandler('destroyJobTarget', resourceRoot, destroyJobTarget)