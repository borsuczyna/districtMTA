addCommandHandler('b', function(player, cmd, playerToFind, time, ...)
    if not doesPlayerHavePermission(player, 'command:ban') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local reason = table.concat({...}, ' ')
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    -- match {number}{d|h|m|s} pattern
    local timePattern = '(%d+)([dhms])'
    local timeUnit = time:match(timePattern)
    if not timeUnit then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nieprawidłowy format czasu (przykład: 1d, 1h, 1m, 1s)')
        return
    end

    local timeValue, unit = timeUnit:match(timePattern)
    timeValue = tonumber(timeValue)
    if not timeValue then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nieprawidłowy format czasu (przykład: 1d, 1h, 1m, 1s)')
        return
    end

    
end)