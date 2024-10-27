function applyShaderToObject(shader, object, texture)
    engineApplyShaderToWorldTexture(shader, texture or '*', object)
    local lod = getLowLODElement(object)
    if lod then
        engineApplyShaderToWorldTexture(shader, texture or '*', lod)
    end
end