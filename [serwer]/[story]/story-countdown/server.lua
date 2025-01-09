local eventStartTime = 1730746800 - (60*59)
-- local eventStartTime = getRealTime().timestamp + 30

function sendPlayerCountdownData(player)
    local serverTick = getTickCount()
    local timeLeft = eventStartTime - getRealTime().timestamp
    local startServerTick = serverTick + timeLeft * 1000

    triggerClientEvent(player, 'onCountdownStart', resourceRoot, serverTick, startServerTick)
end

function startLiveEvent()
    triggerEvent('onLiveEventStart', root)
    stopResource(getResourceFromName('m-timecyc'))
end

function soundInfo()
    exports['m-notis']:addNotification(root, 'info', 'Event na żywo', 'Event jest mocno udźwiękowiony, zalecamy włączenie dźwięków MTA w ustawieniach gry.')
end

addEventHandler('onResourceStart', root, function(resource)
    if resource ~= getThisResource() then return end
    
    local timeLeft = eventStartTime - getRealTime().timestamp
    setTimer(startLiveEvent, timeLeft * 1000, 1)
    setTimer(soundInfo, (timeLeft - 10) * 1000, 1)
end)

addEventHandler('onPlayerResourceStart', root, function(resource)
    if resource ~= getThisResource() then return end
    
    sendPlayerCountdownData(source)
end)