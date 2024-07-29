addCommandHandler('k', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
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

    banPlayer(foundPlayer, true, false, true, player, 'Zostałeś wyrzucony: ' .. reason, 5)
    exports['m-logs']:sendLog('admin', 'error', ('Admin `%s` wyrzucił gracza `%s`: `%s`'):format(playerName, foundPlayerName, reason))
    exports['m-notis']:addNotification(player, 'success', 'Kick', ('Wyrzucono gracza %s'):format(foundPlayerName))
end)