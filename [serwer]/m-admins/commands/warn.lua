addCommandHandler('warn', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:warn') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local reason = table.concat({...}, ' ') or 'nie podano powodu'
    reason = reason ~= '' and reason or 'nie podano powodu'

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local playerName = getPlayerName(player)
    local foundPlayerName = getPlayerName(foundPlayer)

    triggerClientEvent(foundPlayer, 'onClientShowWarn', resourceRoot, getPlayerName(player), reason)
    
    exports['m-logs']:sendLog('admin', 'warning', ('Admin `%s` ostrzegł gracza `%s`: `%s`'):format(playerName, foundPlayerName, reason))
    exports['m-notis']:addNotification(player, 'success', 'Ostrzeżenie', ('Ostrzegłeś gracza %s'):format(foundPlayerName))

    triggerClientEvent('createAdminNotification', resourceRoot, 'warn', ('Admin %s ostrzegł gracza %s: %s'):format(playerName, foundPlayerName, reason))
end)