local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local zoom = 1

local notifications = {}
local activeNotification = nil
local isRendering = false

function createAdminNotification(type, text, color, time)
    if #text > 0 then
        table.insert(notifications, {
            text = text,
            color = color or {150, 150, 150},
            alpha = 1,
            time = time or 7500,
        })

        outputConsole(('[%s] %s'):format(type, text))

        if not isRendering then
            addEventHandler('onClientRender', root, renderNotification, true, 'high-999')
            isRendering = true
        end
    end
end

addEvent('createAdminNotification', true)
addEventHandler('createAdminNotification', resourceRoot, createAdminNotification)

function renderNotification()
    if not activeNotification and #notifications == 0 then
        removeEventHandler('onClientRender', root, renderNotification)
        isRendering = false
        return
    end

    if not activeNotification and #notifications > 0 then
        activeNotification = table.remove(notifications, 1)
        activeNotification.y = -2/zoom
        activeNotification.tick = getTickCount()
    end

    if activeNotification then
        local v = activeNotification

        if getTickCount() - v.tick > v.time then
            v.alpha = math.max(v.alpha - 0.05, 0)
            
            if v.alpha == 0 then
                activeNotification = nil
            end
        end

        v.y = math.min(v.y + 0.15, 0)

        dxDrawImage(0, 0 + (25/zoom) * v.y, 1920/zoom, 22/zoom, 'data/background.png', 0, 0, 0, tocolor(v.color[1], v.color[2], v.color[3], 240 * v.alpha))
        dxDrawText(v.text, sx/2, 9/zoom + (22/zoom) * v.y, nil, nil, tocolor(v.color[1], v.color[2], v.color[3], 255 * v.alpha), 1, exports['m-ui']:getFont('Inter-Regular', 10/zoom), 'center', 'center', false, false)
    end
end