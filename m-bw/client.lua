local sx, sy = guiGetScreenSize()
local shader, screenSource;

function renderBW()
    dxUpdateScreenSource(screenSource)
    dxDrawImage(0, 0, sx, sy, shader)

    local px, py, pz = getElementPosition(localPlayer)
    local camX = px + math.cos(getTickCount() / 10000) * 5
    local camY = py + math.sin(getTickCount() / 10000) * 5
    
    setCameraMatrix(camX, camY, pz + 2, px, py, pz)
end

addEventHandler('onClientPlayerWasted', root, function()
    if source ~= localPlayer then return end

    shader = dxCreateShader('data/shader.fx')
    screenSource = dxCreateScreenSource(sx, sy)

    addEventHandler('onClientRender', root, renderBW, true, 'high+9998')
    dxSetShaderValue(shader, 'screenSource', screenSource)

    toggleAllControls(false, true, false)
    setBWUIVisible(true)
end)

addEventHandler('onClientPlayerSpawn', root, function()
    if source ~= localPlayer then return end

    removeEventHandler('onClientRender', root, renderBW)

    if isElement(shader) then
        destroyElement(shader)
    end

    if isElement(screenSource) then
        destroyElement(screenSource)
    end

    setCameraTarget(localPlayer)
    toggleAllControls(true)
    setBWUIVisible(false)
end)