function findVehicle(id)
    if not id then
        return false
    end

    for _, vehicle in ipairs(getElementsByType('vehicle')) do
        if getElementData(vehicle, 'vehicle:uid') == tonumber(id) then
            return vehicle
        end
    end

    return false
end