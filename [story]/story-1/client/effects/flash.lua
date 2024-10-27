local flashes = {}
local shaders = {}
local flashTexture = false
local flashDissolveTexture = false

function createFlash(data)
    if not flashTexture then
        flashTexture = dxCreateTexture('data/textures/flash.png')
    end
    if not flashDissolveTexture then
        flashDissolveTexture = dxCreateTexture('data/textures/flash-dissolve.png')
    end

    local shader = dxCreateShader('data/shaders/dissolve.fx')
    dxSetShaderValue(shader, 'newTexture', flashTexture)
    dxSetShaderValue(shader, 'dissolveTexture', flashDissolveTexture)
    dxSetShaderValue(shader, 'dissolveStep', 0)
    dxSetShaderValue(shader, 'dissolveSize', 0)
    dxSetShaderValue(shader, 'noAlpha', false)

    table.insert(flashes, {
        position = data.position,
        size = data.size,
        time = data.time,
        stage = 1,
        startTime = getTickCount(),
        shader = shader
    })
end

function renderFlash(flash, i)
    local progress, dissolveStep, dissolveSize, alpha
    if flash.stage == 1 then
        progress = (getTickCount() - flash.startTime) / flash.time
        progress = math.min(progress, 1)
        dissolveStep = progress
        dissolveSize = 0.4 + progress * 0.5
        alpha = 1

        if progress >= 1 then
            flash.stage = 2
            flash.startTime = getTickCount()
            flash.time = flash.time * 1.6
        end
    elseif flash.stage == 2 then
        progress = (getTickCount() - flash.startTime) / flash.time
        alpha = 1-(getTickCount() - flash.startTime) / flash.time
        dissolveStep = 1 - progress
        dissolveSize = 0.9 - progress
        progress = 1 + (getTickCount() - flash.startTime) / flash.time

        if progress >= 2 then
            destroyElement(flash.shader)
            table.remove(flashes, i)
            return
        end
    end
    local size = flash.size * progress

    local x, y, z = unpack(flash.position)
    local x, y = getScreenFromWorldPosition(x, y, z, size/2, false)
    if x then
        dxDrawImage(x - size, y - size/2, size * 2, size, flash.shader, progress * 10)
        dxSetShaderValue(flash.shader, 'dissolveStep', dissolveStep)
        dxSetShaderValue(flash.shader, 'dissolveSize', dissolveSize)
        dxSetShaderValue(flash.shader, 'alphaValue', alpha)
    end
end

addEventHandler('onClientHUDRender', root, function()
    for i, flash in ipairs(flashes) do
        renderFlash(flash, i)
    end
end)

bindKey('f', 'down', function()
    
end)