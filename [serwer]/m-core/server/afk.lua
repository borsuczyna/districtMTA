function setPlayerAFKTime(player, time)
    setElementData(player, 'player:afkTime', time)
end

function getPlayerAFKTime(player)
    return getElementData(player, 'player:afkTime') or 0
end

function setPlayerNowAFKTime(player, time)
    setElementData(player, 'player:afkNow', time)
end

function getPlayerNowAFKTime(player)
    return getElementData(player, 'player:afkNow') or 0
end

function updateAFKTime()
    for _, player in pairs(getElementsByType('player')) do
        local afk = getElementData(player, 'player:afk') 
        if not afk then
            setPlayerNowAFKTime(player, 0)
            return
        end

        local afkTime = getPlayerAFKTime(player)
        setPlayerAFKTime(player, afkTime + 1)

        local afkNow = getPlayerNowAFKTime(player)
        setPlayerNowAFKTime(player, afkNow + 1)
    end
end

setTimer(updateAFKTime, 60000, 0)