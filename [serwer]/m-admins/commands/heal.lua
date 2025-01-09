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

        if getElementHealth(foundPlayer) <= 0 then
            exports['m-notis']:addNotification(foundPlayer, 'success', 'Uleczenie', ('Zostałeś uleczony i zrespawnowany przez %s'):format(getPlayerName(player)))
            exports['m-notis']:addNotification(player, 'success', 'Uleczenie', ('Uleczono i zrespawnowano gracza %s'):format(getPlayerName(foundPlayer)))
        
            spawnPlayer(foundPlayer, Vector3(getElementPosition(foundPlayer)), 0, getElementModel(foundPlayer))
        else
            exports['m-notis']:addNotification(foundPlayer, 'success', 'Uleczenie', ('Zostałeś uleczony przez %s'):format(getPlayerName(player)))
            exports['m-notis']:addNotification(player, 'success', 'Uleczenie', ('Uleczono gracza %s'):format(getPlayerName(foundPlayer)))
            
            setElementHealth(foundPlayer, 100)
        end
    else
        if getElementHealth(player) <= 0 then
            exports['m-notis']:addNotification(player, 'success', 'Uleczenie', 'Zostałeś uleczony i zrespawnowany')
            spawnPlayer(player, Vector3(getElementPosition(player)), 0, getElementModel(player))
        else
            exports['m-notis']:addNotification(player, 'success', 'Uleczenie', 'Zostałeś uleczony') 
            setElementHealth(player, 100)
        end
    end
end)