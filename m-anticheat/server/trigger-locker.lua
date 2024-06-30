function setPlayerTriggerLocked(player, state)
    setElementData(player, 'player:triggerLocked', state)
end

function isPlayerTriggerLocked(player)
    return getElementData(player, 'player:triggerLocked')
end