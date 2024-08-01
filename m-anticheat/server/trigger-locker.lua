function setPlayerTriggerLocked(player, state, reason)
    setElementData(player, 'player:triggerLocked', state)

    if state then
        exports['m-logs']:sendLog('anticheat', 'error', ('Locked player %s for all triggers: %s'):format(getPlayerName(player), reason or 'No reason provided'))
    else
        exports['m-logs']:sendLog('anticheat', 'error', ('Unlocked player %s for all triggers'):format(getPlayerName(player)))
    end
end

function isPlayerTriggerLocked(player)
    local redirected = getElementData(player, 'redirected')
    if redirected then
        exports['m-logs']:sendLog('anticheat', 'error', ('Player %s is redirected but sent trigger, anty redirect?'):format(getPlayerName(player)))
        return true
    end

    return getElementData(player, 'player:triggerLocked')
end

function onPlayerTriggerInvalidEvent()
    ban(source, 'Trigger invalid event', 'Trigger invalid event')
end

addEventHandler('onPlayerTriggerInvalidEvent', root, onPlayerTriggerInvalidEvent)