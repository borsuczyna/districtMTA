local lastActivityTime = getTickCount()

function resetPlayerAFK()
    local afk = getElementData(localPlayer, 'player:afk')
    if not afk then return end

    lastActivityTime = getTickCount()
    showCursor(false)
    setElementData(localPlayer, 'player:afk', false)
end

addEventHandler('onClientKey', root, function(button, press)
    if press then
        resetPlayerAFK()
    end
end)

addEventHandler('onClientMinimize', root, function()
    setElementData(localPlayer, 'player:afk', true)
end)

addEventHandler('onClientRestore', root, function()
    resetPlayerAFK()
end)

function checkAFKStatus()
    local currentTime = getTickCount()
    local idleTime = (currentTime - lastActivityTime) / 60000

    if idleTime >= 1 then
        setElementData(localPlayer, 'player:afk', true)
    else
        resetPlayerAFK()
    end
end

setTimer(checkAFKStatus, 60000, 0)