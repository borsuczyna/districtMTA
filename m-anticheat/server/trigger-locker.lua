function setPlayerTriggerLocked(player, state)
    setElementData(player, 'player:triggerLocked', state)
end

function isPlayerTriggerLocked(player)
    if not getElementData(player, 'player:fingerprint') then
        local message = ('%s tried to use trigger without fingerprint'):format(getPlayerName(player))
        exports['m-logs']:sendLog('anticheat', 'warning', message)
        return true
    end
    
    return getElementData(player, 'player:triggerLocked')
end