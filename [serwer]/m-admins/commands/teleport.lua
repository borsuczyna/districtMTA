addCommandHandler('tt', function(player, cmd, ...)
    if not getElementData(player, 'player:uid') then return end
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

    if foundPlayer == player then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie mozesz teleportować samego siebie')
        return
    end

    exports['m-notis']:addNotification(player, 'success', 'Teleportacja', ('Teleportowano do gracza %s'):format(htmlEscape(getPlayerName(foundPlayer))))

    local vehicle = getPedOccupiedVehicle(foundPlayer)
    if vehicle then
        local maxSeats = getVehicleMaxPassengers(vehicle)

        for i = 0, maxSeats do
            if not getVehicleOccupant(vehicle, i) then
                warpPedIntoVehicle(player, vehicle, i)
                return
            end
        end
    end

    local vehicle = getPedOccupiedVehicle(player)
    if vehicle then
        setElementPosition(vehicle, getElementPosition(foundPlayer))
    end

    local x, y, z = getElementPosition(foundPlayer)
    local interior = getElementInterior(foundPlayer)
    local dimension = getElementDimension(foundPlayer)

    setElementPosition(player, x, y + 0.5, z)
    setElementInterior(player, interior)
    setElementDimension(player, dimension)
end)

addCommandHandler('th', function(player, cmd, ...)
    if not getElementData(player, 'player:uid') then return end
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

    if foundPlayer == player then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie mozesz teleportować samego siebie')
        return
    end

    exports['m-notis']:addNotification(player, 'success', 'Teleportacja', ('Teleportowano gracza %s do Ciebie'):format(htmlEscape(getPlayerName(foundPlayer))))

    local vehicle = getPedOccupiedVehicle(player)
    if vehicle then
        local maxSeats = getVehicleMaxPassengers(vehicle)
    
        for i = 0, maxSeats do
            if not getVehicleOccupant(vehicle, i) then
                warpPedIntoVehicle(foundPlayer, vehicle, i)
                return
            end
        end
    end

    local vehicle = getPedOccupiedVehicle(foundPlayer)
    if vehicle then
        setElementPosition(vehicle, getElementPosition(player))
    end

    local x, y, z = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)

    setElementPosition(foundPlayer, x, y + 0.5, z)
    setElementInterior(foundPlayer, interior)
    setElementDimension(foundPlayer, dimension)
end)

addCommandHandler('vtt', function(player, cmd, id)
    if not getElementData(player, 'player:uid') then return end
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
    setElementDimension(player, getElementDimension(vehicle))
    setElementInterior(player, getElementInterior(vehicle))
    exports['m-notis']:addNotification(player, 'success', 'Teleportacja', ('Teleportowano do pojazdu %s'):format(exports['m-models']:getVehicleName(vehicle)))
end)

addCommandHandler('vth', function(player, cmd, id)
    if not getElementData(player, 'player:uid') then return end
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
    setElementDimension(vehicle, getElementDimension(player))
    setElementInterior(vehicle, getElementInterior(player))
    exports['m-notis']:addNotification(player, 'success', 'Teleportacja', ('Teleportowano pojazd %s do Ciebie'):format(exports['m-models']:getVehicleName(vehicle)))
end)