local function getClosestVehicle(player, maxDistance)
    local closestVehicle = nil

    for _, vehicle in ipairs(getElementsByType('vehicle')) do
        local distance = getDistanceBetweenPoints3D(Vector3(getElementPosition(player)), Vector3(getElementPosition(vehicle)))
        
        if distance <= maxDistance then
            closestVehicle = vehicle
        end
    end

    return closestVehicle
end

function onCanisterUse(player)
    local closestVehicle = getClosestVehicle(player, 2)
    if not closestVehicle or getPedOccupiedVehicle(player) then
        exports['m-notis']:addNotification(player, 'error', 'Kanister z benzyną', 'Nie znajdujesz się obok pojazdu.')
        return 0
    end

    local fuel = getElementData(closestVehicle, 'vehicle:fuel')
    local maxFuel = getElementData(closestVehicle, 'vehicle:maxFuel')
    local newFuel = math.min(fuel + 10, maxFuel)

    if newFuel == fuel then
        exports['m-notis']:addNotification(player, 'error', 'Kanister z benzyną', 'Bak jest pełny.')
        return 0
    end

    setElementData(closestVehicle, 'vehicle:fuel', newFuel)
    exports['m-notis']:addNotification(player, 'success', 'Kanister z benzyną', 'Zatankowałeś '..('%.2f'):format(newFuel - fuel)..'L paliwa.')
    
    return -1
end