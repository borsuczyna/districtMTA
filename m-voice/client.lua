local voicePlayers = {}
local defaultVoiceDistance = 25

function updateVoiceVolume(player, cx, cy, cz)
    if not isElement(player) then return end

    local voiceDistance = defaultVoiceDistance
    local x, y, z = getElementPosition(player)
    local distance = getDistanceBetweenPoints3D(cx, cy, cz, x, y, z)
    local volume = math.max(0, 1 - distance / voiceDistance)

    setSoundVolume(player, volume)
end

addEventHandler('onClientPlayerVoiceStart', root, function()
    local muted = getElementData(localPlayer, 'player:mute') or false
    if muted then
        cancelEvent()
        return
    end

    local cx, cy, cz = getCameraMatrix()
    local x, y, z = getElementPosition(localPlayer)
    local distance = getDistanceBetweenPoints3D(cx, cy, cz, x, y, z)

    if distance > defaultVoiceDistance * 10 then
        cancelEvent()
        return
    end

    updateVoiceVolume(source, cx, cy, cz)
    voicePlayers[source] = true
end)

addEventHandler('onClientPlayerVoiceStop', root, function()
    voicePlayers[source] = nil
end)