addCommandHandler('k', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:kick') then
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

    local playerRank = getElementData(player, 'player:rank')
    local foundPlayerRank = getElementData(foundPlayer, 'player:rank')

    if foundPlayerRank and playerRank and foundPlayerRank >= playerRank then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie możesz wyrzucić gracza o wyższej lub tej samej randze')
        return
    end

    local playerName = getPlayerName(player)
    local foundPlayerName = getPlayerName(foundPlayer)

    banPlayer(foundPlayer, true, false, true, player, 'Zostałeś wyrzucony: ' .. reason, 5)
    
    exports['m-logs']:sendLog('admin', 'error', ('Admin `%s` wyrzucił gracza `%s`: `%s`'):format(playerName, foundPlayerName, reason))
    exports['m-notis']:addNotification(player, 'success', 'Kick', ('Wyrzucono gracza %s'):format(foundPlayerName))

    triggerClientEvent('createAdminNotification', resourceRoot, 'kick', ('Admin %s wyrzucił gracza %s: %s'):format(playerName, foundPlayerName, reason))
end)