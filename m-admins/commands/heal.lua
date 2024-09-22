addCommandHandler('heal', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:heal') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if playerToFind then
        local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
        if not foundPlayer then
            exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
            return
        end

        exports['m-notis']:addNotification(foundPlayer, 'success', 'Uleczenie', ('Zostałeś uleczony przez %s'):format(getPlayerName(player)))
        exports['m-notis']:addNotification(player, 'success', 'Uleczenie', ('Uleczono gracza %s'):format(getPlayerName(foundPlayer)))

        setElementHealth(foundPlayer, 100)
    else
        exports['m-notis']:addNotification(player, 'success', 'Uleczenie', 'Zostałeś uleczony')
        setElementHealth(player, 100)
    end
end)