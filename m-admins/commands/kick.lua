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

    kickPlayer(foundPlayer, player, reason)
    exports['m-logs']:sendLog('admin', 'Kick', ('Gracz %s wyrzucił gracza %s: %s'):format(getPlayerName(player), getPlayerName(foundPlayer), reason))
    exports['m-notis']:addNotification(player, 'success', 'Kick', ('Wyrzucono gracza %s'):format(getPlayerName(foundPlayer)))
end)