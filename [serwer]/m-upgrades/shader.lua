local vehicleShaders = {}
local lightsShader = dxCreateShader('data/lights.fx')
local envTexture = dxCreateTexture('data/env.png')

function getVehicleShader(vehicle)
    if not vehicleShaders[vehicle] then
        vehicleShaders[vehicle] = {
            paint = dxCreateShader('data/paint.fx'),
            default = dxCreateShader('data/default.fx'),
        }

        dxSetShaderValue(vehicleShaders[vehicle].paint, 'gEnvMap', envTexture)
        dxSetShaderValue(vehicleShaders[vehicle].default, 'gEnvMap', envTexture)
    end

    return vehicleShaders[vehicle]
end

function getLightsShader()
    return lightsShader
end

function destroyVehicleShader(vehicle)
    if vehicleShaders[vehicle] then
        destroyElement(vehicleShaders[vehicle].paint)
        destroyElement(vehicleShaders[vehicle].default)
        vehicleShaders[vehicle] = nil
    end
end