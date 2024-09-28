local vehicleShaders = {}

function getVehicleShader(vehicle)
    if not vehicleShaders[vehicle] then
        vehicleShaders[vehicle] = dxCreateShader('data/paint.fx')
    end

    return vehicleShaders[vehicle]
end

function destroyVehicleShader(vehicle)
    if vehicleShaders[vehicle] then
        destroyElement(vehicleShaders[vehicle])
        vehicleShaders[vehicle] = nil
    end
end