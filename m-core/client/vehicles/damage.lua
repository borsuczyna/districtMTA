addEventHandler('onClientVehicleDamage', root, function(_, _, loss)
    local health = getElementHealth(source)
    local matrix = getElementMatrix(source)
    local newHealth = health - loss

    if newHealth <= 315 then
        if matrix[3][3] < 0 then
            setElementHealth(source, 315)
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