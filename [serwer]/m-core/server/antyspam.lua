local antySpam = {}
local antySpamTime = 500
local blockedCommands = {
    'Admin', 'admin', 'crun', 'aexec', 'adminpanel', 'refresh', 'restart', 'start', 'stop', 'Reload',
    'say', 'pm', 're', 'do', 'me', 'v',
}

addEventHandler('onPlayerCommand', root, function(cmd)
    local playerUID = getElementData(source, 'player:uid')
    if not playerUID then return end
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
    local color = getPlayerColor(source)
    local id = getElementData(source, 'player:id')
    if not id then return end

    if cmd and not table.find(blockedCommands, cmd) then
        local message = ('%s(#ffffff%d%s) #dddddd%s użył komendy: %s'):format(color, id, color, getPlayerName(source), cmd)
        exports['m-admins']:addLog('komendy', '#aaddff' .. message, {
            {'teleport', 'teleport-uid', playerUID}
        })
    end
end)

setTimer(function()
    for player, data in pairs(antySpam) do
        data.count = data.count - 1
    end
end, 1000, 0)