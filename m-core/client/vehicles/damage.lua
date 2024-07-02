addEventHandler('onClientVehicleDamage', root, function(_, _, loss)
    local health = getElementHealth(source)
    local matrix = getElementMatrix(source)
    local newHealth = health - loss

    if newHealth <= 315 then
        if matrix[3][3] < 0 then
            setElementHealth(source, 315)
        end
        
        if loss >= 100 and getVehicleOccupant(source) == localPlayer then
            exports['m-notis']:addNotification('error', 'Silnik zniszczony', 'Udaj się do najbliższego mechanika, aby naprawić swój silnik')
            setVehicleEngineState(source, false)
        end

        setVehicleDamageProof(source, true)
        cancelEvent()
    end
end)

addEventHandler('onClientRender', root, function()
    for _, vehicle in ipairs(getElementsByType('vehicle', root, true)) do
        local health = getElementHealth(vehicle)
        if health > 315 then
            setVehicleDamageProof(vehicle, false)
        end
    end
end)