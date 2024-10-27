local sx, sy = guiGetScreenSize()
local startTime = false
local font = dxCreateFont('data/fonts/Inter-Bold.ttf', 11)
local text = 'Twoja karta graficzna nie jest wspierana'

function renderUnsupportedGPU()
    local timeElapsed = getTickCount() - startTime
    local progress = timeElapsed / 1000
    if timeElapsed > 10000 then
        progress = 1 - (timeElapsed - 10000) / 1000
        if progress <= 0 then
            removeEventHandler('onClientRender', root, renderUnsupportedGPU)
            return
        end
    end

    progress = interpolateBetween(0, 0, 0, 1, 0, 0, progress, 'InOutQuad')

    local textW = dxGetTextWidth(text, 1, font)
    local x, y, w, h = sx/2 - (textW + 25) * progress / 2, sy - 50, (textW + 25) * progress, 40

    dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 200))
    dxDrawText(text, x, y, x + w, y + h, white, 1, font, 'center', 'center', true)
end

function showUnsupportedGPU()
    addEventHandler('onClientRender', root, renderUnsupportedGPU)
    startTime = getTickCount()
end

function testIfGPUIsSupported()
    local shader, tec = dxCreateShader('data/shaders/test.fx')
    if tec ~= 'supported' then
        showUnsupportedGPU()
        return
    end
end