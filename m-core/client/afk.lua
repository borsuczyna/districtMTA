addEventHandler('onClientMinimize', root, function()
    setElementData(localPlayer, 'player:afk', true)
    createTrayNotification("Zminimalizowano grę, został tobie nadany status AFK.", "warning", false)
end)

addEventHandler('onClientRestore', root, function()
    local afk = getElementData(localPlayer, 'player:afk')
    if not afk then return end

    setElementData(localPlayer, 'player:afk', false)
end)

function setPlayerAFKTime(time)
    setElementData(localPlayer, 'player:afkTime', time)
end

function getPlayerAFKTime()
    return getElementData(localPlayer, 'player:afkTime') or 0
end

function updatePlayerAFKTime()
    local afk = getElementData(localPlayer, 'player:afk')
    if not afk then return end

    local afkTime = getElementData(localPlayer, 'player:afkTime') or 0
    setPlayerAFKTime(afkTime + 1)
end

setTimer(updatePlayerAFKTime, 60000, 0)