local sx, sy = guiGetScreenSize()
local axisObjects = {}
local shaders = {}
local renderTarget = dxCreateRenderTarget(sx, sy, true)
local pixelRenderTarget = dxCreateRenderTarget(sx, sy, true)
local rotateTexture = dxCreateTexture('data/rotate.png')
local bgTexture = dxCreateTexture('data/bg.png')
local angleDifferenceTarget = dxCreateRenderTarget(256, 256, true)

local function getShader(axis, color)
    if not shaders[axis] then
        shaders[axis] = dxCreateShader('data/shader.fx')
        dxSetShaderValue(shaders[axis], 'outTarget', renderTarget)
        dxSetShaderValue(shaders[axis], 'color', color)
        dxSetShaderValue(shaders[axis], 'rotateTexture', rotateTexture)
        dxSetShaderValue(shaders[axis], 'axis', axis == 'x' and 0 or axis == 'y' and 1 or 2)
    end

    return shaders[axis]
end

local function getAngleDifferenceRender(a, b)
    dxSetRenderTarget(angleDifferenceTarget, true)
    dxDrawCircle(128, 128, 128, a, b, 0xFFFFFFFF, 0xFFFFFFFF, 32, 1, false)
    dxSetRenderTarget()
    return angleDifferenceTarget
end

local function getTempObject(axis, color)
    if not axisObjects[axis] then
        axisObjects[axis] = createObject(1337, 0, 0, 0)
        setElementDimension(axisObjects[axis], getElementDimension(localPlayer))
        setElementInterior(axisObjects[axis], getElementInterior(localPlayer))
        setElementData(axisObjects[axis], 'element:model', 'rotate')
        setElementCollisionsEnabled(axisObjects[axis], false)
        setElementDoubleSided(axisObjects[axis], true)

        local shader = getShader(axis, color)
        engineApplyShaderToWorldTexture(shader, '*', axisObjects[axis])
    end

    return axisObjects[axis]
end

function destroyTempElements()
    for axis, object in pairs(axisObjects) do
        destroyElement(object)
        axisObjects[axis] = nil
    end

    for axis, shader in pairs(shaders) do
        destroyElement(shader)
        shaders[axis] = nil
    end
end

local function swapMatrixAxis(matrix, axis1, axis2)
    local outMatrix = {
        {matrix[1][1], matrix[1][2], matrix[1][3], matrix[1][4]},
        {matrix[2][1], matrix[2][2], matrix[2][3], matrix[2][4]},
        {matrix[3][1], matrix[3][2], matrix[3][3], matrix[3][4]},
        {matrix[4][1], matrix[4][2], matrix[4][3], matrix[4][4]}
    }

    for i = 1, 3 do
        outMatrix[axis1][i], outMatrix[axis2][i] = outMatrix[axis2][i], outMatrix[axis1][i]
    end

    return outMatrix
end

function renderRotatePoint(point, data)
    local outAxis = false
    local xObject = getTempObject('x', {1, 0, 0})
    local yObject = getTempObject('y', {0, 1, 0})
    local zObject = getTempObject('z', {0, 0, 1})

    if not data.drawAxis or data.drawAxis == 'x' then
        setObjectScale(xObject, data.size * 1.02, data.size * 1.02, data.size / 2)
        setElementMatrix(xObject, data.matrix)
        dxDrawMaterialLine3D(point + data.up * data.size / 2, point - data.up * data.size / 2, rotateTexture, data.size, tocolor(255, 0, 0), 'postgui', point + data.forward)
    else
        setElementPosition(xObject, 0, 0, 0)
    end

    if not data.drawAxis or data.drawAxis == 'y' then
        setObjectScale(yObject, data.size * 1.01, data.size * 1.01, data.size / 2)
        setElementMatrix(yObject, swapMatrixAxis(data.matrix, 2, 3))
        dxDrawMaterialLine3D(point + data.up * data.size / 2, point - data.up * data.size / 2, rotateTexture, data.size, tocolor(0, 255, 0), 'postgui', point + data.right)
    else
        setElementPosition(yObject, 0, 0, 0)
    end
    
    if not data.drawAxis or data.drawAxis == 'z' then
        setObjectScale(zObject, data.size, data.size, data.size / 2)
        setElementMatrix(zObject, swapMatrixAxis(data.matrix, 1, 3))
        dxDrawMaterialLine3D(point + data.right * data.size / 2, point - data.right * data.size / 2, rotateTexture, data.size, tocolor(0, 0, 255), 'postgui', point + data.up)
    else
        setElementPosition(zObject, 0, 0, 0)
    end

    local cx, cy = getCursorPosition()
    if not cx then cx, cy = 0, 0 end
    cx, cy = math.floor(cx * sx), math.floor(cy * sy)

    local pixels = dxGetTexturePixels(pixelRenderTarget, cx, cy, 1, 1)
    if pixels then
        local r, g, b, a = dxGetPixelColor(pixels, 0, 0)
        if not r then r, g, b, a = 0, 0, 0, 0 end
        local x, y = r/255, g/255
        local axis = false

        if x > 0 and x < 1/3 then
            axis = 'x'
            x = x * 3
            y = y * 3
        elseif x > 1/3 and x < 2/3 then
            axis = 'y'
            x = (x - 1/3) * 3
            y = (y - 1/3) * 3
        elseif x > 2/3 and x < 1 then
            axis = 'z'
            x = (x - 2/3) * 3
            y = (y - 2/3) * 3
        end

        x, y = x - 0.5, y - 0.5
        local rot = -math.deg(math.atan2(y, x))
        rot = axis == 'z' and (rot + 180) or (axis == 'x' and (-rot - 90) or rot - 90)

        -- dxDrawText(('%s: %.2f, %.2f, %.2f'):format(tostring(axis), x, y, rot), 350, 350)
        
        if axis == 'x' then
            if data.startAngle then
                dxDrawMaterialLine3D(point + data.up * data.size / 2, point - data.up * data.size / 2, getAngleDifferenceRender(data.startAngle, rot), data.size, tocolor(255, 0, 0, 88), 'postgui', point + data.forward)
            else
                dxDrawMaterialLine3D(point + data.up * data.size / 2, point - data.up * data.size / 2, bgTexture, data.size, tocolor(255, 0, 0, 55), 'postgui', point + data.forward)
            end
        elseif axis == 'y' then
            if data.startAngle then
                dxDrawMaterialLine3D(point + data.up * data.size / 2, point - data.up * data.size / 2, getAngleDifferenceRender(data.startAngle, rot), data.size, tocolor(0, 255, 0, 88), 'postgui', point + data.right)
            else
                dxDrawMaterialLine3D(point + data.up * data.size / 2, point - data.up * data.size / 2, bgTexture, data.size, tocolor(0, 255, 0, 55), 'postgui', point + data.right)
            end
        elseif axis == 'z' then
            if data.startAngle then
                dxDrawMaterialLine3D(point + data.right * data.size / 2, point - data.right * data.size / 2, getAngleDifferenceRender(data.startAngle, rot), data.size, tocolor(0, 0, 255, 88), 'postgui', point + data.up)
            else
                dxDrawMaterialLine3D(point + data.right * data.size / 2, point - data.right * data.size / 2, bgTexture, data.size, tocolor(0, 0, 255, 55), 'postgui', point + data.up)
            end
        end

        if getKeyState('mouse1') and (data.startAngle or data.clicked) then
            outAxis = axis
        else
            outAxis = false
        end
        
        return outAxis, rot
    else
        return false
    end
end

addEventHandler('onClientPreRender', root, function()
    dxSetRenderTarget(pixelRenderTarget, true)
    dxDrawImage(0, 0, sx, sy, renderTarget)
    dxSetRenderTarget()
    dxSetRenderTarget(renderTarget, true)
    dxSetRenderTarget()
end)