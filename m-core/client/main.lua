addEvent('onClientPlayPrivateMessageSound', true)
addEventHandler('onClientPlayPrivateMessageSound', resourceRoot, function()
    playSFX('genrl', 52, 19, false)
end)

addEventHandler('onClientRender', root, function()
    toggleControl('fire', false)
    toggleControl('aim_weapon', false)
end)

addEventHandler('onClientResourceStart', root, function()
    setAmbientSoundEnabled('general', false)
    setAmbientSoundEnabled('gunfire', false)
    
    setWorldSoundEnabled(0, 0, false, true)
    setWorldSoundEnabled(0, 29, false, true)
    setWorldSoundEnabled(0, 30, false, true)
end)

addCommandHandler('gp', function(cmd, rotation)
    local element = getPedOccupiedVehicle(localPlayer) or localPlayer
    local x, y, z = getElementPosition(element)
    local rx, ry, rz = getElementRotation(element)
    local message = ('{%.3f, %.3f, %.3f},'):format(x, y, z)
    if rotation == '1' then
        message = ('{%.3f, %.3f, %.3f, %.3f, %.3f, %.3f},'):format(x, y, z, rx, ry, rz)
    end

    outputChatBox(message)
    setClipboard(message)
end)