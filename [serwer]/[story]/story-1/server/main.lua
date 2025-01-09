function startLiveEvent()
    if client then banPlayer(client, true, false, true, 'Live event anticheat') return end

    -- launchMissile()
    triggerClientEvent('startLiveEvent', root)
    -- startUfos()
    setTimer(startUfos, 60000 / settings.eventSpeed, 1)
end

addEvent('onLiveEventStart', true)
addEventHandler('onLiveEventStart', resourceRoot, startLiveEvent)

-- triggerEvent('onLiveEventStart', resourceRoot)
-- addEventHandler('onPlayerResourceStart', root, function(resource)
--     if resource == getThisResource() then
--         triggerEvent('onLiveEventStart', resourceRoot)
--     end
-- end)

-- setTimer(function()
--     triggerEvent('onLiveEventStart', resourceRoot)
-- end, 200, 1)

function finishEvent()
    local players = getElementsByType('player')
    for i, player in ipairs(players) do
        setElementFrozen(player, false)
        setPedAnimation(player)
    end

    exports['m-notis']:addNotification(root, 'success', 'Event na żywo', 'Dziękujemy za uczestnictwo w evencie na żywo!<br>Daj nam znać o swoich wrażeniach na naszym discordzie/forum!<br><br>Nowe przedmioty i misje przepustki sezonowej będą dostępne od jutra.', 30000)

    local resource = getThisResource()
    stopResource(resource)
end