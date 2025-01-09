local engines = {}

addEventHandler('onVehicleStartEnter', root, function()
    engines[source] = getVehicleEngineState(source)
end)

addEventHandler('onVehicleEnter', root, function(player, seat)
    if seat ~= 0 then return end

    if engines[source] ~= nil then
        setVehicleEngineState(source, engines[source])
    else
        setVehicleEngineState(source, false)
    end
end)