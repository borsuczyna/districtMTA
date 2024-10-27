local hole = {843.20001, 1228.1, 1058.50717, 500}
local holeObject, holeShader, holeStart, holeStep
local dissolveTexture = dxCreateTexture('data/textures/sky-dissolve.png')

function renderHole()
    local progress

    if holeStep == 1 then
        progress = (getTickCount() - holeStart) / (15500 / settings.eventSpeed)
        dxSetShaderValue(holeShader, 'dissolveStep', progress)
        dxSetShaderValue(holeShader, 'dissolveSize', 0.2 + progress * 0.9)

        if progress >= 1 then
            holeStep = 2
            holeStart = getTickCount()
        end
    elseif holeStep == 2 then
        progress = (getTickCount() - holeStart) / (15000 / settings.eventSpeed)
        dxSetShaderValue(holeShader, 'dissolveStep', 1)
        dxSetShaderValue(holeShader, 'dissolveSize', 1)

        if progress >= 1 then
            holeStep = 3
            holeStart = getTickCount()
        end
    elseif holeStep == 3 then
        progress = 1 - (getTickCount() - holeStart) / (5000 / settings.eventSpeed)
        dxSetShaderValue(holeShader, 'dissolveStep', progress)
        dxSetShaderValue(holeShader, 'dissolveSize', 1 + progress * 0.2)

        if progress <= 0 then
            removeEventHandler('onClientRender', root, renderHole)
            destroyElement(getLowLODElement(holeObject))
            destroyElement(holeObject)
            destroyElement(dissolveTexture)
            destroyElement(holeShader)
        end
    end
end

function createHole()
    holeObject, holeShader = createTexturePlane('data/textures/sky.png', hole[1], hole[2], hole[3], 0, 180, 0, hole[4], 'data/shaders/dissolve.fx')
    dxSetShaderValue(holeShader, 'dissolveTexture', dissolveTexture)
    dxSetShaderValue(holeShader, 'dissolveStep', 0)
    dxSetShaderValue(holeShader, 'dissolveSize', 0)
    holeStart = getTickCount()
    holeStep = 1

    local sound = playSound3D('data/sounds/sky.wav', hole[1], hole[2], hole[3])
    setSoundVolume(sound, 25)
    setSoundMinDistance(sound, 150)
    setSoundMaxDistance(sound, 2000)
    setSoundSpeed(sound, settings.eventSpeed)

    addEventHandler('onClientRender', root, renderHole)
    playMusic('showdown', 2)
end

engineSetModelLODDistance(1339, 3000)
-- createHole()