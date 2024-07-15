addEvent('onClientPlayPrivateMessageSound', true)
addEventHandler('onClientPlayPrivateMessageSound', resourceRoot, function()
    playSFX('genrl', 52, 19, false)
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