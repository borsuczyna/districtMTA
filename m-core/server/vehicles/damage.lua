addEventHandler('onVehicleDamage', root, function(loss)
    local player = getVehicleOccupant(source)
    local health = getElementHealth(source)
    local rx, ry = getElementRotation(source)
    local newHealth = health - loss

    if newHealth <= 315 then
        if rx > 90 and rx < 270 or ry > 90 and ry < 270 then
            setElementHealth(source, 350)
        end
        
        if loss >= 100 then
            setVehicleEngineState(source, false)
        end

        cancelEvent()
    end
end)