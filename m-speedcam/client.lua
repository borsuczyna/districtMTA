addEvent('speedcam:playSound', true)

local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local screenSource = false
local time = 0
local state = 0

function renderSpeedCamTicket()
    local interfaceSize = getElementData(localPlayer, "player:interfaceSize")
    local zoom = zoomOriginal * ( 25 / interfaceSize )
    local alpha = 0

    if state == 1 then
        local progress = (getTickCount() - time) / 500
        alpha = math.min(255, progress * 255)
        if progress >= 1 then
            state = 2
            time = getTickCount()
        end
    elseif state == 2 then
        alpha = 255
        if getTickCount() - time >= 5000 then
            state = 3
            time = getTickCount()
        end
    elseif state == 3 then
        alpha = 255 - math.min(255, (getTickCount() - time) / 500 * 255)
        if alpha <= 0 then
            removeEventHandler('onClientRender', root, renderSpeedCamTicket)
            return
        end
    end

    local aspectRatio = sy / sx
    dxDrawRectangle(sx - 1050/zoom - 5/zoom, sy/2 - 500/zoom * aspectRatio - 5/zoom, 1000/zoom + 10/zoom, 1000/zoom * aspectRatio + 10/zoom, tocolor(0, 0, 0, alpha))
    dxDrawImage(sx - 1050/zoom, sy/2 - 500/zoom * aspectRatio, 1000/zoom, 1000/zoom * aspectRatio, screenSource, 0, 0, 0, tocolor(255, 255, 255, alpha))
end

function takeSpeedCamPic()
    if isElement(screenSource) then
        destroyElement(screenSource)
    end

    screenSource = dxCreateScreenSource(sx, sy)
    if not screenSource then return end

    dxUpdateScreenSource(screenSource)
    addEventHandler('onClientRender', root, renderSpeedCamTicket)
    time = getTickCount()
    state = 1
end

addEventHandler('speedcam:playSound', resourceRoot, function(player, x, y, z)
    local sound = playSound3D('data/effect.wav', x, y, z)
    setSoundMaxDistance(sound, 50)
    setSoundVolume(sound, 0.5)

    if player == localPlayer then
        takeSpeedCamPic()
    end
end)