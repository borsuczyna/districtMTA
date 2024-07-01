function setPlayerTriggerLocked(player, state, reason)
    setElementData(player, 'player:triggerLocked', state)
    exports['m-logs']:sendLog('anticheat', 'error', ('Locked player %s for all triggers: %s'):format(getPlayerName(player), reason or 'No reason provided'))
end

function isPlayerTriggerLocked(player)
    if not getPlayerFingerprint(player) then
        local message = ('%s tried to use trigger without fingerprint'):format(getPlayerName(player))
        exports['m-logs']:sendLog('anticheat', 'warning', message)
        return true
    end
    
    return getElementData(player, 'player:triggerLocked')
end