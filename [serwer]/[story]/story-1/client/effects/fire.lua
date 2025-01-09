local effect

function applyFireEffect(object)
    local shader = dxCreateShader('data/shaders/fire.fx', 0, 0, false, 'all')
    applyShaderToObject(shader, object, '*')

    effect = shader
end

function destroyFireEffect()
    if not effect or not isElement(effect) then return end
    destroyElement(effect)
end

function setFireEffectProperties(object, fireLength, smokeLength, totalLength, alpha)
    if not effect or not isElement(effect) then return end
    dxSetShaderValue(effect, 'fireLength', fireLength)
    dxSetShaderValue(effect, 'smokeLength', smokeLength)
    dxSetShaderValue(effect, 'totalLength', totalLength)
    dxSetShaderValue(effect, 'alpha', alpha)
end