addEvent('houses:textureChange', true)
addEvent('houses:resetTextures', true)

local shaders = {}

function destroyInteriorTextures()
    for i, shader in ipairs(shaders) do
        destroyElement(shader.shader)
        destroyElement(shader.texture)
    end

    shaders = {}
end

function destroyInteriorTexture(texture)
    local shader, index = table.findCallback(shaders, function(shader)
        return shader.textureId == texture
    end)

    if shader then
        destroyElement(shader.shader)
        destroyElement(shader.texture)
        table.remove(shaders, index)
    end
end

function setInteriorTexture(interiorData, object, texture, textureId)
    destroyInteriorTexture(texture)

    local interiorTexture = interiorData.textureNames[texture]
    if not interiorTexture then return end

    local textureData = interiorTextures[textureId]
    if not textureData then return end

    local path = 'data/textures/interior/' .. textureData.texture .. '.png'
    if not fileExists(path) then return end

    local shader = dxCreateShader('data/shader.fx')
    if not shader then return end

    local textureElement = dxCreateTexture(path)
    if not textureElement then
        destroyElement(shader)
        return
    end

    dxSetShaderValue(shader, 'Tex0', textureElement)
    engineApplyShaderToWorldTexture(shader, interiorTexture.texture, object)
    table.insert(shaders, {shader = shader, texture = textureElement, textureId = texture})
end

function loadInteriorTextures(interiorData, object, textures)
    destroyInteriorTextures()

    for _, textureData in pairs(textures) do
        setInteriorTexture(interiorData, object, textureData.textureId + 1, textureData.texture + 1)
    end
end

addEventHandler('houses:textureChange', resourceRoot, function(textureId, texture)
    local object = getInteriorObject()
    if not object then return end

    local interiorData = getInteriorData()

    if texture ~= -1 then
        setInteriorTexture(interiorData, object, textureId + 1, texture + 1)
    else
        destroyInteriorTexture(textureId + 1)
    end
end)

addEventHandler('houses:resetTextures', resourceRoot, function()
    destroyInteriorTextures()
end)