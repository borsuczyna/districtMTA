local rifts = {}
local dissolveTexture = dxCreateTexture('data/textures/rift-dissolve.png')
local glowDissolveTexture = dxCreateTexture('data/textures/rift-glow-dissolve.png')

function createRift(data)
    local x, y, z = unpack(data.position)
    local objectGlow, shaderGlow = createTexturePlane('data/textures/rift-glow.png', x, y, z, 0, 180, data.rot or 0, data.radius, 'data/shaders/dissolve.fx')
    dxSetShaderValue(shaderGlow, 'dissolveTexture', glowDissolveTexture)
    dxSetShaderValue(shaderGlow, 'dissolveStep', 0)
    dxSetShaderValue(shaderGlow, 'dissolveSize', 0)

    local object, shader = createTexturePlane('data/textures/rift.png', x, y, z - 5, 0, 180, data.rot or 0, data.radius, 'data/shaders/dissolve.fx')
    dxSetShaderValue(shader, 'dissolveTexture', dissolveTexture)
    dxSetShaderValue(shader, 'dissolveStep', 0)
    dxSetShaderValue(shader, 'dissolveSize', 0)

    table.insert(rifts, {
        position = data.position,
        showTime = data.showTime,
        liveTime = data.liveTime,
        dissolveTime = data.dissolveTime,
        radius = data.radius,
        splashSize = data.splashSize,

        stage = 1,
        startTime = getTickCount(),
        object = object,
        shader = shader,
        objectGlow = objectGlow,
        shaderGlow = shaderGlow
    })
end

function renderRift(rift, i)
    if rift.stage == 1 then
        local progress = (getTickCount() - rift.startTime) / rift.showTime
        dxSetShaderValue(rift.shader, 'dissolveStep', progress)
        dxSetShaderValue(rift.shader, 'dissolveSize', 0.2 + progress * 0.9)
        dxSetShaderValue(rift.shaderGlow, 'dissolveStep', progress)
        dxSetShaderValue(rift.shaderGlow, 'dissolveSize', 0.2 + progress * 0.9)

        if progress >= 1 then
            rift.stage = 2
            rift.startTime = getTickCount()
        end
    elseif rift.stage == 2 then
        local progress = (getTickCount() - rift.startTime) / rift.liveTime
        
        if progress >= 1 then
            rift.stage = 3
            rift.startTime = getTickCount()
        end
    elseif rift.stage == 3 then
        local progress = (getTickCount() - rift.startTime) / rift.dissolveTime
        dxSetShaderValue(rift.shader, 'dissolveStep', 1 - progress)
        dxSetShaderValue(rift.shader, 'dissolveSize', 0.2 + (1 - progress) * 0.9)
        dxSetShaderValue(rift.shaderGlow, 'dissolveStep', 1 - progress)
        dxSetShaderValue(rift.shaderGlow, 'dissolveSize', 0.2 + (1 - progress) * 0.9)

        if progress >= 1 then
            setElementAlphaWithLOD(rift.object, 0)
            setElementAlphaWithLOD(rift.objectGlow, 0)
            destroyElementWithLOD(rift.object)
            destroyElementWithLOD(rift.objectGlow)
            destroyElement(rift.shader)
            destroyElement(rift.shaderGlow)
            table.remove(rifts, i)
            return
        end
    end
end

function renderRifts()
    for i, rift in ipairs(rifts) do
        renderRift(rift, i)
    end
end

addEventHandler("onClientRender", root, renderRifts)

bindKey('k', 'down', function()
    createRift({
        position = {463.20001, 1528.1, 1208.50717},
        showTime = 500,
        liveTime = 1000,
        dissolveTime = 6000,
        radius = 920,
        splashSize = 100
    })
end)