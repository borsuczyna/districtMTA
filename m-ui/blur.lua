local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local blurQuality = 0.4
local lastBlurQuality = 0
local blurShaderH, blurShaderV, screenSource, maskRenderTarget, shaderRenderTarget, maskTexture;

local function renderblurShaderH()
    if not blurShaderH then return end
    if not isElement(maskTexture) then return end
    
    dxUpdateScreenSource(screenSource)
    
    dxSetRenderTarget(shaderRenderTarget)
    dxDrawImage(0, 0, sx * blurQuality, sy * blurQuality, blurShaderH)
    dxSetRenderTarget()
    
    dxSetRenderTarget(maskRenderTarget, true)
    dxDrawImage(0, 0, sx, sy, maskTexture, 0, 0, 0, 0xFF000000)

    local interfaceSize = getElementData(localPlayer, "player:interfaceSize")
    if interfaceSize and tonumber(interfaceSize) then
        local zoom = zoomOriginal * ( 25 / interfaceSize )
        local radarSize = 470/zoom
        local radarX, radarY, radarW, radarH = 45/zoom, sy - radarSize - 45/zoom, radarSize, radarSize
        dxDrawCircle(radarX + radarW/2, radarY + radarH/2, radarW/2, 0, 360, 0xFF000000)
    end
    dxSetRenderTarget()

    dxDrawImage(0, 0, sx, sy, blurShaderV)
end

function setBlurShaderEnabled(enabled, maskTexture_)
    -- if not not blurShaderH == enabled then return end
    if lastBlurQuality == blurQuality then return end
    if enabled and tonumber(blurQuality) == 0 then
        enabled = false
    end

    if isElement(blurShaderH) then
        destroyElement(blurShaderH)
    end
    if isElement(blurShaderV) then
        destroyElement(blurShaderV)
    end
    if isElement(screenSource) then
        destroyElement(screenSource)
    end
    if isElement(maskRenderTarget) then
        destroyElement(maskRenderTarget)
    end
    if isElement(shaderRenderTarget) then
        destroyElement(shaderRenderTarget)
    end

    blurShaderH = nil
    screenSource = nil
    maskRenderTarget = nil
    shaderRenderTarget = nil
    removeEventHandler('onClientRender', root, renderblurShaderH)

    if enabled then
        lastBlurQuality = blurQuality
        blurShaderH = dxCreateShader('data/blurH.fx')
        blurShaderV = dxCreateShader('data/blurV.fx')
        screenSource = dxCreateScreenSource(sx * blurQuality, sy * blurQuality)
        maskRenderTarget = dxCreateRenderTarget(sx, sy, true)
        shaderRenderTarget = dxCreateRenderTarget(sx * blurQuality, sy * blurQuality, false)
        dxSetShaderValue(blurShaderH, 'ScreenSize', sx, sy)
        dxSetShaderValue(blurShaderV, 'ScreenSize', sx, sy)
        dxSetShaderValue(blurShaderH, 'ScreenTexture', screenSource)
        dxSetShaderValue(blurShaderV, 'ScreenTexture', shaderRenderTarget)
        dxSetShaderValue(blurShaderV, 'MaskTexture', maskRenderTarget)
        addEventHandler('onClientRender', root, renderblurShaderH, true, 'high+9999')
        maskTexture = maskTexture_
    end
end

function setBlurQuality(quality)
    blurQuality = tonumber(quality)
    setBlurShaderEnabled(blurQuality > 0, maskTexture)
end

-- setBlurQuality(0.1)