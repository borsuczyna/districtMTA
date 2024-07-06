local sx, sy = guiGetScreenSize()
local zoom = sx < 2048 and math.min(2.2, 2048/sx) or 1
local lastArrowAngle = 0
local defaultSpeedo = 'modern'
local customSpeedos = {
    [411] = 'modern',
}
local fonts = {
    [1] = exports['m-ui']:getFont('Inter-Medium', 16/zoom),
    [2] = exports['m-ui']:getFont('DigitalNumbers-Regular', 40/zoom),
    [3] = exports['m-ui']:getFont('DigitalNumbers-Regular', 14/zoom),
}
local textsWidths = {
    ['000'] = dxGetTextWidth('000', 1, fonts[2]),
    ['000-h'] = dxGetFontHeight(1, fonts[2]),
}

local function getVehicleSpeedo(vehicle)
    local model = getElementModel(vehicle)
    return customSpeedos[model] or defaultSpeedo
end

local function renderSpeedo()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    local speedo = getVehicleSpeedo(vehicle)
    local speed = getVehicleSpeed(vehicle)
    local rpm = getVehicleRPM(vehicle)
    local mileage = getElementData(vehicle, 'vehicle:mileage') or 3213
    local fuel = getElementData(vehicle, 'vehicle:fuel') or 50
    local r, g, b = getVehicleHeadLightColor(vehicle)

    local icons = {
        {'handbrake', isElementFrozen(vehicle)},
        {'engine', getVehicleEngineState(vehicle)},
        {'lights', getVehicleOverrideLights(vehicle) == 2},
        {'door', isVehicleLocked(vehicle)},
    }

    local onIcons = {}
    for i, icon in ipairs(icons) do
        if icon[2] then
            table.insert(onIcons, icon)
        end
    end

    if speedo == 'modern' then
        dxDrawImage(sx - 370/zoom, sy - 370/zoom, 350/zoom, 350/zoom, 'data/modern/background.png')
        dxDrawImage(sx - 370/zoom, sy - 370/zoom, 350/zoom, 350/zoom, 'data/modern/stripes.png', 0, 0, 0, tocolor(r, g, b, 255))
        dxDrawImage(sx - 370/zoom, sy - 370/zoom, 350/zoom, 350/zoom, 'data/modern/fuel.png')
        dxDrawImageSection(sx - 245/zoom, sy - 370/zoom, 98/zoom * (fuel / 100), 350/zoom, 242, 0, 190 * (fuel / 100), 680, 'data/modern/fuel-2.png', 0, 0, 0, tocolor(0, 255, 0))
        dxDrawImage(sx - 370/zoom, sy - 370/zoom, 350/zoom, 350/zoom, 'data/modern/arrow.png', -143 + lastArrowAngle, 0, 0, tocolor(255, 255, 255, 255))
        
        dxDrawText('000', sx - 6/zoom - textsWidths['000'], sy - 200/zoom, nil, nil, tocolor(255, 255, 255, 35), 1, fonts[2], 'right', 'center')
        dxDrawText(math.floor(speed), sx - 6/zoom - textsWidths['000'], sy - 200/zoom, nil, nil, tocolor(255, 255, 255, 255), 1, fonts[2], 'right', 'center')
        dxDrawText(('%07d'):format(mileage), sx - 194/zoom, sy - 190/zoom + textsWidths['000-h']/2, nil, nil, tocolor(255, 255, 255, 255), 1, fonts[3], 'center', 'top')

        local iconSize = 25/zoom
        local gap = 10/zoom
        local iconsWidth = #onIcons * iconSize + (#onIcons - 1) * gap
        for i, icon in ipairs(onIcons) do
            if icon[2] then
                local x = sx - 195/zoom - iconsWidth/2 + (i - 1) * (iconSize + gap)
                local y = sy - 260/zoom
                dxDrawImage(x, y, iconSize, iconSize, 'data/icons/' .. icon[1] .. '.png')
            end
        end

        local nextArrowAngle = rpm / 9900 * 160
        lastArrowAngle = lastArrowAngle + (nextArrowAngle - lastArrowAngle) * 0.1
    end
end

function setSpeedoVisible(visible)
    _G[visible and 'addEventHandler' or 'removeEventHandler']('onClientRender', root, renderSpeedo)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    setSpeedoVisible(true)
end)