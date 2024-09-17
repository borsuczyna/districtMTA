function onCanisterUse(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        exports['m-notis']:addNotification(player, 'error', 'Kanister z benzyną', 'Nie znajdujesz się w pojeździe.')
        return 0
    end

    local fuel = getElementData(vehicle, 'vehicle:fuel')
    local maxFuel = getElementData(vehicle, 'vehicle:maxFuel')

    if fuel == maxFuel then
        exports['m-notis']:addNotification(player, 'error', 'Kanister z benzyną', 'Bak jest pełny.')
        return 0
    end
    
    setElementData(vehicle, 'vehicle:fuel', maxFuel)
    exports['m-notis']:addNotification(player, 'success', 'Kanister z benzyną', 'Zatankowałeś bak do pełna.')
    
    return -1
end