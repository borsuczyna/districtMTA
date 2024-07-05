function setPlayerTriggerLocked(player, state, reason)
    setElementData(player, 'player:triggerLocked', state)
    exports['m-logs']:sendLog('anticheat', 'error', ('Locked player %s for all triggers: %s'):format(getPlayerName(player), reason or 'No reason provided'))
end

function isPlayerTriggerLocked(player)
    return getElementData(player, 'player:triggerLocked')
end

addCommandHandler('test11', function()
    createExplosion(713.52167, -522.02460, 16.32814,1)
end)