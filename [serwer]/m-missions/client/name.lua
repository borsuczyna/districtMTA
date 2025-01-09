local sx, sy = guiGetScreenSize()
local missionName = false
local missionNameAnimation = {0, getTickCount()}
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1

function renderMissionName()
    local interfaceSize = getElementData(localPlayer, 'player:interfaceSize')
    local zoom = zoomOriginal * ( 25 / interfaceSize )
    local textWidth = dxGetTextWidth(missionName, 6/zoom, 'pricedown')

    local alpha, y = 0, 0
    local top = sy * 0.3
    if missionNameAnimation[1] == 0 then
        local progress = (getTickCount() - missionNameAnimation[2]) / 1000
        alpha, y = interpolateBetween(0, 0, 0, 255, top, 0, math.min(1, progress), 'InOutQuad')

        if progress >= 1 then
            missionNameAnimation = {1, getTickCount()}
        end
    elseif missionNameAnimation[1] == 1 then
        alpha, y = 255, top

        if getTickCount() - missionNameAnimation[2] > 5000 then
            missionNameAnimation = {2, getTickCount()}
        end
    elseif missionNameAnimation[1] == 2 then
        local progress = (getTickCount() - missionNameAnimation[2]) / 1000
        alpha, y = interpolateBetween(255, top, 0, 0, sy * 0.8, 0, math.min(1, progress), 'InOutQuad')

        if progress >= 1 then
            missionNameAnimation = {0, getTickCount()}
            removeEventHandler('onClientRender', root, renderMissionName)
        end
    end

    dxDrawText(missionName, sx/2, y, nil, nil, tocolor(255, 200, 0, alpha), 6/zoom, 'pricedown', 'center', 'center', false, false, false, true)
end

function showMissionName(name)
    missionName = name
    missionNameAnimation = {0, getTickCount()}
    addEventHandler('onClientRender', root, renderMissionName)
end