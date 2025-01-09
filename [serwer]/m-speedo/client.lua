local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local lastArrowAngle = 0
local defaultSpeedo = 'compact'
local noSpeedos = {481}
local speedos = {
    old = {401, 403, 404, 410, 418, 419, 436, 439, 467, 475, 478, 479, 491, 492, 546, 496, 605, 604, 600, 585, 572, 571, 568, 566, 550, 549, 543, 542, 540, 531, 530, 529, 526, 518},
    modern = {411, 415, 429, 451, 477, 587, 562, 559, 558, 541, 506},
    muscle = {412, 466, 474, 576, 575, 567, 555, 536, 535, 534},
}

local fonts = {
    [1] = exports['m-ui']:getFont('Inter-Medium', 16),
    [2] = exports['m-ui']:getFont('DigitalNumbers-Regular', 40),
    [3] = exports['m-ui']:getFont('DigitalNumbers-Regular', 14),
    [4] = exports['m-ui']:getFont('DigitalNumbers-Regular', 11),
    [5] = exports['m-ui']:getFont('DigitalNumbers-Regular', 16),
}
local textsWidths = {
    ['000'] = dxGetTextWidth('000', 1, fonts[2]),
    ['000-h'] = dxGetFontHeight(1, fonts[2]),
    ['0'] = dxGetTextWidth('0', 1, fonts[5]),
    ['0-h'] = dxGetFontHeight(1, fonts[5]),
}

function table.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return false
end

local function getVehicleSpeedo(vehicle)
    local model = getElementModel(vehicle)

    for speedo, models in pairs(speedos) do
        if table.find(models, model) then
            return speedo
        end
    end

    return defaultSpeedo
end

local function renderSpeedo()
    if getElementData(localPlayer, 'player:hiddenHUD') then return end
    
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    local speedo = getVehicleSpeedo(vehicle)
    local speed = getVehicleSpeed(vehicle)
    local rpm = getVehicleRPM(vehicle)
    local mileage = getElementData(vehicle, 'vehicle:mileage') or 3213

    local fuel = getElementData(vehicle, 'vehicle:fuel') or 37
    local maxFuel = getElementData(vehicle, 'vehicle:maxFuel') or 37
    local lpgState = getElementData(vehicle, 'vehicle:lpgState') or false
    if lpgState then
        fuel = getElementData(vehicle, 'vehicle:lpgFuel') or 37
        maxFuel = 25
    end

    local r, g, b = getVehicleHeadLightColor(vehicle)

    local icons = {
        {'handbrake', isElementFrozen(vehicle)},
        {'engine', getVehicleEngineState(vehicle)},
        {'lights', areVehicleLightsOn(vehicle)},
        {'door', isVehicleLocked(vehicle)},
    }

    local onIcons = {}
    for i, icon in ipairs(icons) do
        if icon[2] then
            table.insert(onIcons, icon)
        end
    end

    local interfaceSize = getElementData(localPlayer, "player:interfaceSize")
    local zoom = zoomOriginal * ( 17 / interfaceSize )

    if speedo == 'modern' then
        dxDrawImage(sx - 370/zoom, sy - 370/zoom, 350/zoom, 350/zoom, 'data/modern/background.png')
        dxDrawImage(sx - 370/zoom, sy - 370/zoom, 350/zoom, 350/zoom, 'data/modern/stripes.png', 0, 0, 0, tocolor(r, g, b, 255))
        dxDrawImage(sx - 370/zoom, sy - 370/zoom, 350/zoom, 350/zoom, 'data/modern/fuel.png')
        dxDrawImageSection(sx - 245/zoom, sy - 370/zoom, 98/zoom * (fuel / maxFuel), 350/zoom, 242, 0, 190 * (fuel / maxFuel), 680, 'data/modern/fuel-2.png', 0, 0, 0, tocolor(0, 255, 0))
        dxDrawImage(sx - 370/zoom, sy - 370/zoom, 350/zoom, 350/zoom, 'data/modern/arrow.png', -143 + lastArrowAngle, 0, 0, tocolor(255, 255, 255, 255))
        
        dxDrawText('000', sx - 15/zoom - textsWidths['000']/zoom, sy - 200/zoom, nil, nil, tocolor(255, 255, 255, 35), 0.8/zoom, fonts[2], 'right', 'center')
        dxDrawText(math.floor(speed), sx - 15/zoom - textsWidths['000']/zoom, sy - 200/zoom, nil, nil, tocolor(255, 255, 255, 255), 0.8/zoom, fonts[2], 'right', 'center')
        dxDrawText(('%07d'):format(mileage), sx - 194/zoom, sy - 195/zoom + textsWidths['000-h']/2/zoom, nil, nil, tocolor(255, 255, 255, 255), 0.8/zoom, fonts[3], 'center', 'top')
        
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
    elseif speedo == 'old' then
        dxDrawImage(sx - 610/zoom, sy - 238/zoom, 590/zoom, 218/zoom, 'data/old/background.png')

        local speed = math.min(speed, 201)
        dxDrawImage(sx - 255/zoom, sy - 230/zoom, 48/zoom, 214/zoom, 'data/old/gauge.png', math.min(-92 + speed/200 * 184, 92), 0, 90/zoom)
        dxDrawImage(sx - 610/zoom, sy - 238/zoom, 590/zoom, 218/zoom, 'data/old/overlay.png')
        dxDrawImage(sx - 500/zoom, sy - 140/zoom, 33/zoom, 190/zoom, 'data/old/fuel-gauge.png', -100 + (fuel / maxFuel) * 130)
        dxDrawText(('%07d'):format(mileage), sx - 230/zoom, sy - 44/zoom, nil, nil, tocolor(0, 0, 0, 255), 1/zoom, fonts[4], 'center', 'center')
    
        local iconSize = 25/zoom
        local gap = 10/zoom
        local iconsWidth = #onIcons * iconSize + (#onIcons - 1) * gap
        for i, icon in ipairs(onIcons) do
            if icon[2] then
                local x = sx - 235/zoom - iconsWidth/2 + (i - 1) * (iconSize + gap)
                local y = sy - 120/zoom
                dxDrawImage(x, y, iconSize, iconSize, 'data/icons/' .. icon[1] .. '.png')
            end
        end
    elseif speedo == 'compact' then
       -- dxDrawImage(sx - 476/zoom, sy - 370/zoom, 456/zoom, 350/zoom, 'data/compact/background.png')
        dxDrawImage(sx - 476/zoom + 1, sy - 370/zoom + 1, 456/zoom, 350/zoom, 'data/compact/stripes.png', 0, 0, 0, tocolor(0, 0, 0, 155))
        dxDrawImage(sx - 476/zoom, sy - 370/zoom, 456/zoom, 350/zoom, 'data/compact/stripes.png', 0, 0, 0, tocolor(r, g, b, 255))
        dxDrawImage(sx - 400/zoom, sy - 190/zoom, 26/zoom, 153/zoom, 'data/compact/fuel-gauge.png', -227 + (fuel / maxFuel) * 230)

        dxDrawText('km/h', sx - 190/zoom, sy - 250/zoom, nil, nil, tocolor(255, 255, 255, 155), 1/zoom, fonts[1], 'center', 'center')

        local mileageText = ('%07d'):format(mileage)
        local w, h = textsWidths['0']/zoom, textsWidths['0-h']/zoom
        local gap = 9/zoom

        for i = 1, #mileageText do
            local x = (sx - 185/zoom) - (#mileageText * (w + gap))/2 + (i - 1) * (w + gap)
            dxDrawRectangle(x - w/2 - 2/zoom, sy - 112/zoom - h/2, w + 4/zoom, h + 4/zoom, tocolor(70, 70, 70, 140))
            dxDrawText(mileageText:sub(i, i), x, sy - 110/zoom, nil, nil, tocolor(255, 255, 255, 200), 1/zoom, fonts[5], 'center', 'center')
        end

        local iconSize = 25/zoom
        local gap = 10/zoom
        local iconsWidth = #onIcons * iconSize + (#onIcons - 1) * gap
        for i, icon in ipairs(onIcons) do
            if icon[2] then
                local x = sx - 188/zoom - iconsWidth/2 + (i - 1) * (iconSize + gap)
                local y = sy - 85/zoom
                dxDrawImage(x, y, iconSize, iconSize, 'data/icons/' .. icon[1] .. '.png')
            end
        end

        local speed = math.min(speed, 201)

        dxDrawImage(sx - 214/zoom, sy - 350/zoom, 40/zoom, 318/zoom, 'data/compact/gauge.png', -113 + speed/200 * 226, 0, 0)
    elseif speedo == 'muscle' then
        local mphSpeed = speed * 0.621371
        dxDrawImage(sx - 528/zoom, sy - 370/zoom, 508/zoom, 350/zoom, 'data/muscle/background.png')
        dxDrawImage(sx - 466.5/zoom, sy - 145/zoom, 41/zoom, 111/zoom, 'data/muscle/fuel-gauge.png', 55 - (fuel / maxFuel) * 110, 0, -30/zoom)
        dxDrawImage(sx - 528/zoom, sy - 370/zoom, 508/zoom, 350/zoom, 'data/muscle/overlay.png')

        local mphSpeed = math.min(speed, 121)
        dxDrawImage(sx - 214/zoom, sy - 290/zoom, 42/zoom, 191/zoom, 'data/muscle/gauge.png', -135 + mphSpeed/120 * 270, 0, 0)
        dxDrawImage(sx - 528/zoom, sy - 370/zoom, 508/zoom, 350/zoom, 'data/muscle/stripes.png', 0, 0, 0, tocolor(r, g, b, 255))

        dxDrawText(('%07d'):format(mileage), sx - 193/zoom, sy - 107/zoom, nil, nil, tocolor(0, 0, 0, 255), 1/zoom, fonts[4], 'center', 'center')

        local iconSize = 22/zoom
        local gap = 10/zoom
        local iconsWidth = #onIcons * iconSize + (#onIcons - 1) * gap
        for i, icon in ipairs(onIcons) do
            if icon[2] then
                local x = sx - 193/zoom - iconsWidth/2 + (i - 1) * (iconSize + gap)
                local y = sy - 85/zoom
                dxDrawImage(x, y, iconSize, iconSize, 'data/icons/' .. icon[1] .. '.png')
            end
        end
    end
end

function setSpeedoVisible(visible)
    _G[visible and 'addEventHandler' or 'removeEventHandler']('onClientRender', root, renderSpeedo, true, 'high+9999')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    setSpeedoVisible(true)
end)