addCommandHandler('k', function(player, cmd, playerToFind, ...)
    if not doesPlayerHavePermission(player, 'command:kick') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local reason = table.concat({...}, ' ')
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local playerName = getPlayerName(player)
    local foundPlayerName = getPlayerName(foundPlayer)

    kickPlayer(foundPlayer, player, reason)
    exports['m-logs']:sendLog('admin', 'Kick', ('Admin `%s` wyrzucił gracza `%s`: `%s`'):format(playerName, foundPlayerName, reason))
    exports['m-notis']:addNotification(player, 'success', 'Kick', ('Wyrzucono gracza %s'):format(foundPlayerName))
end)