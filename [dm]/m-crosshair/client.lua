local isCustom = false
local replaceShader = [[
    texture gTexture;
    technique TexReplace
    {
        pass P0
        {
            Texture[0] = gTexture;
        }
    }
]]

function updateCrosshair()
    if not fileExists('data/crosshair.png') then 
        setDefaultCrosshair() 
        return 
    end

    setCustomCrosshair()
end

setTimer(updateCrosshair, 10000, 0)

function setDefaultCrosshair()
    if not isCustom then return end
    isCustom = nil

    if isElement(shader) then 
        destroyElement(shader) 
    end

    if isElement(texture) then 
        destroyElement(texture) 
    end
end

function setCustomCrosshair()
    if isCustom then 
        checkIsNew() 
        return 
    end
    isCustom = true

    shader = dxCreateShader(replaceShader)
    texture = dxCreateTexture('data/crosshair.png', 'argb', true, 'clamp')

    local file = fileOpen('data/crosshair.png', true)
    fileSize = fileGetSize(file)
    fileClose(file)

    engineApplyShaderToWorldTexture(shader, 'sitem16')
    dxSetShaderValue(shader, 'gTexture', texture)
end

function checkIsNew()
    local file = fileOpen('data/crosshair.png', true)

    if fileGetSize(file) ~= fileSize then
        setDefaultCrosshair()
        setCustomCrosshair()
    end

    fileClose(file)
end