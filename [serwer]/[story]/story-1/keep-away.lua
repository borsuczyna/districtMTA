local rocketPosition = {463, 1528, 72, 50}

addEventHandler('onClientRender', root, function()
    local veh = getPedOccupiedVehicle(localPlayer)
    local x, y, z = getElementPosition(localPlayer)

    if veh and getPedOccupiedVehicleSeat(localPlayer) == 0 and getDistanceBetweenPoints3D(x, y, z, unpack(rocketPosition)) < rocketPosition[4] then
        -- push away
        local dx, dy, dz = rocketPosition[1] - x, rocketPosition[2] - y, rocketPosition[3] - z
        local distance = 1 - (getDistanceBetweenPoints3D(x, y, z, unpack(rocketPosition)) / rocketPosition[4])
        local push = 0.1
        local pushX, pushY, pushZ = dx / distance * push, dy / distance * push, dz / distance * push
        setElementVelocity(veh, -pushX, -pushY, -pushZ)
    end
end)