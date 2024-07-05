addEvent('interaction:action', true)
addEventHandler('interaction:action', resourceRoot, function(action, ...)
    local args = {...}
    local vehicle = getPedOccupiedVehicle(client)
    if not vehicle then return end

    if action == 'engine' then
        setVehicleEngineState(vehicle, not getVehicleEngineState(vehicle))
    elseif action == 'lights' then
        setVehicleOverrideLights(vehicle, getVehicleOverrideLights(vehicle) ~= 2 and 2 or 1)
    elseif action == 'trunk' then
        setVehicleDoorOpenRatio(vehicle, 1, getVehicleDoorOpenRatio(vehicle, 1) > 0 and 0 or 1, 500)
    elseif action == 'hood' then
        setVehicleDoorOpenRatio(vehicle, 0, getVehicleDoorOpenRatio(vehicle, 0) > 0 and 0 or 1, 500)
    elseif action == 'window' then
        local seat = getPedOccupiedVehicleSeat(client)
        local occupants = getVehicleOccupants(vehicle)
        triggerClientEvent(root, 'interaction:window', resourceRoot, vehicle, seatsWindows[seat], args[1])
    end

    triggerClientEvent(client, 'interaction:action-feedback', resourceRoot, action)
end)