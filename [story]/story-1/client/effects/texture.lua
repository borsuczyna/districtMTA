local shaders = {}
local textures = {}
local sx, sy = guiGetScreenSize()
local outRt = false

function getTextureShader(path, customShader)
    customShader = customShader or 'data/shaders/texture.fx'

    if not outRt then
        outRt = dxCreateRenderTarget(sx, sy, true)
    end

    if not textures[path] then
        textures[path] = dxCreateTexture(path)
    end

    local shader = dxCreateShader(customShader)
    dxSetShaderValue(shader, 'newTexture', textures[path])
    dxSetShaderValue(shader, 'outRt', outRt)

    return shader
end

function createTexturePlane(texture, x, y, z, rx, ry, rz, size, customShader)
    local object = createObject(2000, x, y, z, rx, ry, rz)
    local shader = getTextureShader(texture, customShader)
    setObjectScale(object, size)
    setElementCollisionsEnabled(object, false)
    local lod = assignLOD(object)
    setObjectCustomModel(object, 'plane')
    engineApplyShaderToWorldTexture(shader, '*', object)
    engineApplyShaderToWorldTexture(shader, '*', lod)

    return object, shader
end

addEventHandler('onClientRender', root, function()
    if not outRt then return end
    dxDrawImage(0, 0, sx, sy, outRt)
end, false, 'high+99999')

addEventHandler('onClientPreRender', root, function()
    if not outRt then return end
    dxSetRenderTarget(outRt, true)
    dxSetRenderTarget()
end)