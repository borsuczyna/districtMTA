function setPlayerOnlineTime(player, time)
    local afk = getElementData(player, 'player:afk')
    if afk then return end

    setElementData(player, 'player:time', time)
end

function getPlayerOnlineTime(player)
    return getElementData(player, 'player:time') or 0
end

function updatePlayerOnlineTime(player)
    for i, player in pairs(getElementsByType('player')) do
        local onlineTime = getPlayerOnlineTime(player)
        setPlayerOnlineTime(player, onlineTime + 1)
    end
end

setTimer(updatePlayerOnlineTime, 60000, 0)