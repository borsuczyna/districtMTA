addCommandHandler('fix', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:fix') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie jesteś w pojeździe')
        return
    end

    local playerName = getPlayerName(player)
    local vehicleDriver = getVehicleOccupant(vehicle, 0)
    
    exports['m-notis']:addNotification(vehicleDriver, 'success', 'Pojazd', ('Twój pojazd został naprawiony przez %s'):format(playerName))
    exports['m-notis']:addNotification(player, 'success', 'Pojazd', 'Pojazd został naprawiony')

    fixVehicle(vehicle)
end)