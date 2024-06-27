local lockedTriggers = {}

function setPlayerTriggerLocked(player, state)
    lockedTriggers[player] = state
end

function isPlayerTriggerLocked(player)
    return lockedTriggers[player]
end