function setPlayerTriggerLocked(player, state, reason)
    setElementData(player, 'player:triggerLocked', state)

    if state then
        exports['m-log']:addLog('anticheat', 'error', ('Locked player %s for all triggers: %s'):format(getPlayerName(player), reason or 'No reason provided'))
    else
        exports['m-log']:addLog('anticheat', 'error', ('Unlocked player %s for all triggers'):format(getPlayerName(player)))
    end
end

function isPlayerTriggerLocked(player)
    return getElementData(player, 'player:triggerLocked')
end
