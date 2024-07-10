function setPlayerOnlineTime(player, time)
    local afk = getElementData(player, 'player:afk')
    if afk then return end

    setElementData(player, 'player:time', time)
end

function setPlayerSessionTime(player, time)
    local afk = getElementData(player, 'player:afk')
    if afk then return end

    setElementData(player, 'player:session', time)
end

function getPlayerOnlineTime(player)
    return getElementData(player, 'player:time') or 0
end

function getPlayerSessionTime(player)
    return getElementData(player, 'player:session') or 0
end

function updatePlayerTime(player)
    for i, player in pairs(getElementsByType('player')) do
        local onlineTime = getPlayerOnlineTime(player)
        local sessionTime = getPlayerSessionTime(player)

        setPlayerOnlineTime(player, onlineTime + 1)
        setPlayerSessionTime(player, sessionTime + 1)
    end
end

setTimer(updatePlayerTime, 60000, 0)