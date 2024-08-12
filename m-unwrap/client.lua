local texture = dxCreateTexture('gradient.png')
local shader = dxCreateShader('shader.fx')
local vehicle = getPedOccupiedVehicle(localPlayer)
dxSetShaderValue(shader, 'Tex0', texture)

engineApplyShaderToWorldTexture(shader, 'vehiclegrunge256', vehicle)

addEventHandler('onClientPreRender', root, function()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    local matrix = getElementMatrix(veh)
    dxSetShaderValue(shader, "vehicleMatrix", {
        matrix[1][1], matrix[1][2], matrix[1][3], 0,
        matrix[2][1], matrix[2][2], matrix[2][3], 0,
        matrix[3][1], matrix[3][2], matrix[3][3], 0,
        matrix[4][1], matrix[4][2], matrix[4][3], 1,
    })
end)