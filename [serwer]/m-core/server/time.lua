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

function setPlayerDutyTime(player, time)
    local duty = getElementData(player, 'player:duty')
    if not duty then return end

    local afk = getElementData(player, 'player:afk')
    if afk then return end

    setElementData(player, 'player:dutyTime', time)
end

function setPlayerPayDutyTime(player, time)
    local duty = getElementData(player, 'player:duty')
    if not duty then return end

    local afk = getElementData(player, 'player:afk')
    if afk then return end

    setElementData(player, 'player:payDutyTime', time)
end

function getPlayerOnlineTime(player)
    return getElementData(player, 'player:time') or 0
end

function getPlayerSessionTime(player)
    return getElementData(player, 'player:session') or 0
end

function getPlayerDutyTime(player)
    return getElementData(player, 'player:dutyTime') or 0
end

function getPlayerPayDutyTime(player)
    return getElementData(player, 'player:payDutyTime') or 0
end

function updatePlayerTime(player)
    for _, player in pairs(getElementsByType('player')) do
        local onlineTime = getPlayerOnlineTime(player)
        local sessionTime = getPlayerSessionTime(player)
        local dutyTime = getPlayerDutyTime(player)
        local payDutyTime = getPlayerPayDutyTime(player)

        setPlayerOnlineTime(player, onlineTime + 1)
        setPlayerSessionTime(player, sessionTime + 1)
        setPlayerDutyTime(player, dutyTime + 1)
        setPlayerPayDutyTime(player, payDutyTime + 1)
    end
end

setTimer(updatePlayerTime, 60000, 0)