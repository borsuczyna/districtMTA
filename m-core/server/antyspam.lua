local antySpam = {}
local antySpamTime = 500

addEventHandler('onPlayerCommand', root, function()
    if exports['m-anticheat']:isPlayerTriggerLocked(source) then return end
    if not antySpam[source] then
        antySpam[source] = {count = 0, lastCommand = getTickCount()}
    end

    if antySpam[source].lastCommand > getTickCount() then
        cancelEvent()
        exports['m-notis']:addNotification(source, 'error', 'Błąd', 'Zbyt szybko używasz komend')
        return
    end

    if antySpam[source].count > 5 then
        exports['m-notis']:addNotification(source, 'error', 'Błąd', 'Zbyt szybko używasz komend')
        return
    end

    antySpam[source].count = antySpam[source].count + 1
    antySpam[source].lastCommand = getTickCount() + antySpamTime
end)

setTimer(function()
    for player, data in pairs(antySpam) do
        data.count = data.count - 1
    end
end, 1000, 0)