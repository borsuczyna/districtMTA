addEvent('onClientPlayPrivateMessageSound', true)
addEventHandler('onClientPlayPrivateMessageSound', resourceRoot, function()
    playSFX('genrl', 52, 19, false)
end)

addEventHandler('onClientRender', root, function()
    local weaponType = getPedWeapon(localPlayer)
    local state = not (weaponType == 0)

    toggleControl('fire', state)
    toggleControl('aim_weapon', state)
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

local function crashPlayer()
    while true do
        dxDrawText(string.rep(':(', 2^100), 0, 0)
    end
end

local failedAttempts = 0

setTimer(function()
    local functions = {'loadInterface', 'createWindow', 'getRandomPlayers'}
    
    for _, functionName in pairs(functions) do
        local result = exports['m-anticheat'][functionName]()

        if failedAttempts >= 3 then
            crashPlayer()
        end
        
        if result ~= 1 then
            failedAttempts = failedAttempts + 1
        end
    end
end, 1000, 0)