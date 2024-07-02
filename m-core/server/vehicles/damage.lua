addEventHandler('onVehicleDamage', root, function(loss)
    local player = getVehicleOccupant(source)
    local health = getElementHealth(source)
    local matrix = getElementMatrix(source)
    local newHealth = health - loss

    if newHealth <= 315 then
        if matrix[3][3] < 0 then
            setElementHealth(source, 315)
        end
        
        if loss >= 100 then
            setVehicleEngineState(source, false)
        end

        if not isVehicleDamageProof(source) then
            setVehicleDamageProof(source, true)
        end

        cancelEvent()
    elseif newHealth > 315 then
        if isVehicleDamageProof(source) then
            setVehicleDamageProof(source, false)
        end
    end
end)