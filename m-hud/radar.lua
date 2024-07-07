local sx, sy = guiGetScreenSize()
local zoom = sx < 2048 and math.min(2.2, 2048/sx) or 1
zoom = zoom * 1.5
local radar = {}
local radarX, radarY, radarW, radarH
local radarVisible = false
local radarSettings = {
    ['size'] = 420/zoom,
    ['mapTextureSize'] = 3072,
}

addEvent('interface:visibilityChange', true)
addEventHandler('interface:visibilityChange', root, function(name, visible)
	if name == 'hud' then
		radarVisible = visible
	end
end)

local textures = {
    dxCreateTexture('data/images/blur_mask.png'),
	dxCreateTexture('data/images/world.png'),
	dxCreateTexture('data/images/bg.png'),
	dxCreateTexture('data/images/overlay.png'),
	dxCreateTexture('data/images/blur_mask.png'),
}

local fonts = {
	dxCreateFont(':m-ui/data/fonts/Inter-Medium.ttf', 23/zoom, false, 'proof'),
	dxCreateFont(':m-ui/data/fonts/Inter-Medium.ttf', 18/zoom, false, 'proof'),
}

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function renderRadar()
    if not getElementData(localPlayer, 'player:spawn') then return end
    if not radarVisible then return end

    local px, py, pz = getElementPosition(localPlayer)
    local x = (px) / 6000
    local y = (py) / -6000
    dxSetShaderValue(radar.shader, "gUVPosition", x, y)
    dxSetShaderValue(radar.shader, "gUVScale", 0.1, 0.1)

    
    local _, _, camrot = getElementRotation(getCamera())
    dxSetShaderValue(radar.shader, "gUVRotAngle", math.rad(-camrot))
    
    local radarX, radarY, radarW, radarH = 45/zoom, sy - radarSettings.size - 45/zoom, radarSettings.size, radarSettings.size
    dxDrawImage(radarX, radarY, radarW, radarH, textures[4], 0, 0, 0, tocolor(175, 175, 175, 255))
    dxDrawImage(radarX, radarY, radarW, radarH, radar.shader, 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawImage(radarX, radarY, radarW, radarH, textures[3], 0, 0, 0, tocolor(255, 255, 255, 255))
    -- draw zone name
    local zone = getZoneName(px, py, pz, true)
    dxDrawText(zone, radarX + radarW + 1, radarY + radarH - 75/zoom + 1, nil, nil, tocolor(0, 0, 0, 200), 1, fonts[1], 'left', 'bottom', false, false, false, true)
    dxDrawText(zone, radarX + radarW, radarY + radarH - 75/zoom, nil, nil, tocolor(255, 255, 255, 200), 1, fonts[1], 'left', 'bottom', false, false, false, true)

    local zone = getZoneName(px, py, pz, false)
    dxDrawText(zone, radarX + radarW - 20/zoom + 1, radarY + radarH - 75/zoom + 1, nil, nil, tocolor(0, 0, 0, 200), 1, fonts[2], 'left', 'top', false, false, false, true)
    dxDrawText(zone, radarX + radarW - 20/zoom, radarY + radarH - 75/zoom, nil, nil, tocolor(255, 255, 255, 225), 1, fonts[2], 'left', 'top', false, false, false, true)

    local _, _, cz = getElementRotation(getCamera())
    local x, y, z = getElementPosition(localPlayer)
    -- draw blips with radar circle
    local blips = getElementsByType('blip')
    for k,v in pairs(blips) do
        local bx, by, bz = getElementPosition(v)
        local blipIcon = getBlipIcon(v)
        local size = 36/zoom
        local visible = getBlipVisibleDistance(v)

        if not (bx == 0 and by == 0 and blipIcon == 0) then
            if fileExists('data/images/blips/'..blipIcon..'.png') then
                local distance = getDistanceBetweenPoints2D(x, y, bx, by)
                if distance <= visible then
                    local dist = math.min(distance/zoom/1.44, radarW/2)
                    if (visible == 9999 and dist < radarW/2) or visible ~= 9999 then
                        local angle = findRotation(x, y, bx, by)
                        angle = angle - cz + 180
                        local x, y = getPointFromDistanceRotation(radarX + radarW/2, radarY + radarH/2, dist, angle)
                        dxDrawImage(x - size/2, y - (size*1.15)/2, size, size*1.15, 'data/images/blips/'..blipIcon..'.png')
                    end
                end
            end
        end
    end

    -- draw player arrow
    local px, py, pz = getElementPosition(localPlayer)
    local x, y, w, h = radarX + radarW/2 - 14/zoom, radarY + radarH/2 - 14/zoom, 28/zoom, 28/zoom
    local rx, ry, rz = getElementRotation(localPlayer)
    dxDrawImage(x, y, w, h, "data/images/player.png", camrot - rz, 0, 0, tocolor(255, 255, 255, 255))
end

function constructRadar()
    radar = {
        shader = dxCreateShader('data/hud_mask.fx'),
        maskTexture = textures[1],
        mapTexture = textures[2],
    }

    if radar.shader then
        dxSetShaderValue(radar.shader, "sPicTexture", radar.mapTexture)
        dxSetShaderValue(radar.shader, "sMaskTexture", radar.maskTexture)
    end

    addEventHandler('onClientRender', root, renderRadar, true, 'high+999')
end
addEventHandler('onClientResourceStart', resourceRoot, constructRadar)