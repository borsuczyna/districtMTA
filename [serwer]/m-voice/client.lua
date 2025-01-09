local sx, sy = guiGetScreenSize()
local zoom = (sx < 2048) and math.min(2.2, 2048/sx) or 1
local voicePlayers = {}
local defaultVoiceDistance = 25

local fonts = {
	default = exports['m-ui']:getFont('Inter-Medium', 15/zoom),
}
local fontHeight = dxGetFontHeight(1, fonts.default)

local function length(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

local function updateVoiceVolume(player, cx, cy, cz)
    if not isElement(player) then return end

    local voiceDistance = defaultVoiceDistance
    local x, y, z = getElementPosition(player)
    local distance = getDistanceBetweenPoints3D(cx, cy, cz, x, y, z)
    local volume = math.max(0, 1 - distance / voiceDistance)

    setSoundVolume(player, volume)
end

local function drawPlayerVoice(player, y)
    local name = getPlayerName(player)
    local r, g, b = getPlayerNametagColor(player)
    local volume = getSoundVolume(player)
    local width = dxGetTextWidth(name, 1, fonts.default)

    dxDrawText(name, sx - width - 10/zoom, y, 0, y, tocolor(r, g, b), 1, fonts.default, 'left', 'center')
    dxDrawRectangle(sx - width - 10/zoom, y + fontHeight/2, width, 3/zoom, tocolor(255, 255, 255, 100))
    dxDrawRectangle(sx - width - 10/zoom, y + fontHeight/2, width * volume, 3/zoom, tocolor(r, g, b))

    return y + fontHeight + 3/zoom
end

addEventHandler('onClientPlayerVoiceStart', root, function()
    local muted = getElementData(source, 'player:mute') or false
    if muted then
        cancelEvent()
        return
    end

    local cx, cy, cz = getCameraMatrix()
    local x, y, z = getElementPosition(localPlayer)
    local distance = getDistanceBetweenPoints3D(cx, cy, cz, x, y, z)

    if distance > defaultVoiceDistance then
        cancelEvent()
        return
    end

    updateVoiceVolume(source, cx, cy, cz)
    voicePlayers[source] = true
end)

addEventHandler('onClientPlayerVoiceStop', root, function()
    voicePlayers[source] = nil
end)

addEventHandler('onClientRender', root, function()
    local cx, cy, cz = getCameraMatrix()

    local height = 1 * (fontHeight + 3/zoom)
    local y = sy/2 - height/2

    for player in pairs(voicePlayers) do
        local dist = getDistanceBetweenPoints3D(cx, cy, cz, getElementPosition(player))

        updateVoiceVolume(player, cx, cy, cz)

        if dist < defaultVoiceDistance then
            y = drawPlayerVoice(player, y)
        end
    end
end)