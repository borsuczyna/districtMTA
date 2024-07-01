addCommandHandler('tt', function(player, cmd, ...)
    if not doesPlayerHavePermission(player, 'command:teleport') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local playerToFind = table.concat({...}, ' ')
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local x, y, z = getElementPosition(foundPlayer)
    setElementPosition(player, x, y + 0.5, z)
    exports['m-notis']:addNotification(player, 'success', 'Teleportacja', ('Teleportowano do gracza %s'):format(getPlayerName(foundPlayer)))
end)

addCommandHandler('th', function(player, cmd, ...)
    if not doesPlayerHavePermission(player, 'command:teleport') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local playerToFind = table.concat({...}, ' ')
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local x, y, z = getElementPosition(player)
    setElementPosition(foundPlayer, x, y + 0.5, z)
    exports['m-notis']:addNotification(player, 'success', 'Teleportacja', ('Teleportowano gracza %s do Ciebie'):format(getPlayerName(foundPlayer)))
end)

addCommandHandler('vtt', function(player, cmd, id)
    if not doesPlayerHavePermission(player, 'command:teleport') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local vehicle = exports['m-core']:findVehicle(id)
    if not vehicle then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono pojazdu')
        return
    end

    local x, y, z = getElementPosition(vehicle)
    setElementPosition(player, x, y, z + 0.5)
    exports['m-notis']:addNotification(player, 'success', 'Teleportacja', ('Teleportowano do pojazdu %s'):format(getVehicleName(vehicle)))
end)

addCommandHandler('vth', function(player, cmd, id)
    if not doesPlayerHavePermission(player, 'command:teleport') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local vehicle = exports['m-core']:findVehicle(id)
    if not vehicle then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono pojazdu')
        return
    end

    local x, y, z = getElementPosition(player)
    local rx, ry, rz = getElementRotation(player)
    setElementPosition(vehicle, x, y, z)
    setElementRotation(vehicle, rx, ry, rz)
    setElementPosition(player, x, y, z + 0.5)
    exports['m-notis']:addNotification(player, 'success', 'Teleportacja', ('Teleportowano pojazd %s do Ciebie'):format(getVehicleName(vehicle)))
end)