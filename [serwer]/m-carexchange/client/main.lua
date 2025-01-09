local renderTarget = false
local sx, sy = guiGetScreenSize()
local lastVehicle = false
local currentTab = 1
local scrollPosition = 0
local scrollView = 5
local fonts = {
    dxCreateFont(':m-ui/data/css/fonts/Inter-Bold.ttf', 27, false, 'proof'),
    dxCreateFont(':m-ui/data/css/fonts/Inter-Medium.ttf', 24, false, 'proof'),
    dxCreateFont(':m-ui/data/css/fonts/Inter-Regular.ttf', 22, false, 'proof')
}
local fontsHeights = {
    dxGetFontHeight(1, fonts[1]),
    dxGetFontHeight(1, fonts[2]),
    dxGetFontHeight(1, fonts[3])
}

local function getRenderTarget()
    if not renderTarget then
        renderTarget = {
            element = dxCreateRenderTarget(800, 450, true),
            lastUsed = getTickCount()
        }
    end

    renderTarget.lastUsed = getTickCount()
    return renderTarget.element
end

local function updateRenderTarget()
    if renderTarget then
        if getTickCount() - renderTarget.lastUsed > 5000 then
            destroyElement(renderTarget.element)
            renderTarget = false
            lastVehicle = false
            scrollPosition = 0
        end
    end
end

local function getClosestVehicleWithElementData(elementData, distance)
    local x, y, z = getElementPosition(localPlayer)
    local vehicles = getElementsWithinRange(x, y, z, distance, 'vehicle')
    local closestVehicle = {false, distance}

    for i, vehicle in ipairs(vehicles) do
        if getElementData(vehicle, elementData) then
            local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
            local distance = getDistanceBetweenPoints3D(x, y, z, vehicleX, vehicleY, vehicleZ)

            if distance < closestVehicle[2] then
                closestVehicle = {vehicle, distance}
            end
        end
    end

    return closestVehicle[1]
end

local function renderRenderTarget()
    local renderTarget = getRenderTarget()
    local carExchange = getElementData(lastVehicle, 'vehicle:carExchange')
    if not carExchange then return end

    local ownerPlayer = exports['m-core']:getPlayerByUid(carExchange.owner)

    dxSetRenderTarget(renderTarget, true)
    -- dxDrawRoundedRectangle(0, 0, 800, 450, tocolor(30, 30, 30, 245), 20)
    local vehicleName = ('(%d) %s'):format(getElementData(lastVehicle, 'vehicle:uid'), exports['m-models']:getVehicleName(lastVehicle))
    local ownerName = ('(%d) %s'):format(carExchange.owner, carExchange.ownerName)
    local vehicleNameWidth = dxGetTextWidth(vehicleName, 1, fonts[1])
    local ownerNameWidth = dxGetTextWidth(ownerName, 1, fonts[2]) + 45

    dxDrawRoundedRectangle(7, 7, vehicleNameWidth + 17, fontsHeights[1] + 5, tocolor(30, 30, 30, 245), 10)
    dxDrawRoundedRectangle(785 - ownerNameWidth, 7, ownerNameWidth + 10, fontsHeights[2] + 14, tocolor(30, 30, 30, 245), 10)
    dxDrawText(vehicleName, 15, 10, 785, 435, tocolor(255, 255, 255, 230), 1, fonts[1], 'left', 'top')
    dxDrawText(ownerName, 15, 13, 748, 435, tocolor(255, 255, 255, 230), 1, fonts[2], 'right', 'top')

    dxSetBlendMode('modulate_add')
    local onlineColorA, onlineColorB = ownerPlayer and 0x6600FF00 or 0x66FF0000, ownerPlayer and 0xFF00FF00 or 0xFFFF0000
    dxDrawCircle(770, 35, 15, 0, 360, onlineColorA, onlineColorA, 32, 1)
    dxDrawCircle(770, 35, 6, 0, 360, onlineColorB, onlineColorB, 32, 1)
    
    if currentTab == 1 then
        local r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4 = getVehicleColor(lastVehicle, true)
        local mileage = math.floor(getElementData(lastVehicle, 'vehicle:mileage') or 0)
        local engineCapacity = getElementData(lastVehicle, 'vehicle:engineCapacity') or 0
        local fuelType = getElementData(lastVehicle, 'vehicle:fuelType') or 0
        local lpg = getElementData(lastVehicle, 'vehicle:lpg')

        dxDrawRoundedRectangle(7, 70, 788, fontsHeights[2] + 17, tocolor(35, 35, 35, 245), 15)
        dxDrawText('Cena', 18, 78, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'left', 'top', false, false, false, true)
        dxDrawText(addCents(carExchange.price), 18, 78, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'right', 'top', false, false, false, true)
        
        dxDrawRoundedRectangle(7, 135, 788, fontsHeights[2] + 17, tocolor(35, 35, 35, 245), 15)
        dxDrawText('Przebieg', 18, 143, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'left', 'top', false, false, false, true)
        dxDrawText(formatNumber(mileage) .. ' km', 18, 143, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'right', 'top', false, false, false, true)
    
        dxDrawRoundedRectangle(7, 200, 788, fontsHeights[2] + 17, tocolor(35, 35, 35, 245), 15)
        dxDrawText('Pojemność silnika', 18, 208, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'left', 'top', false, false, false, true)
        dxDrawText(('%.1f dm³'):format(engineCapacity), 18, 208, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'right', 'top', false, false, false, true)

        dxDrawRoundedRectangle(7, 265, 788, fontsHeights[2] + 17, tocolor(35, 35, 35, 245), 15)
        dxDrawText('Rodzaj paliwa', 18, 273, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'left', 'top', false, false, false, true)
        dxDrawText(fuelType == 'diesel' and 'Diesel' or 'Benzyna', 18, 273, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'right', 'top', false, false, false, true)

        dxDrawRoundedRectangle(7, 330, 788, fontsHeights[2] + 17, tocolor(35, 35, 35, 245), 15)
        dxDrawText('Instalacja LPG', 18, 338, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'left', 'top', false, false, false, true)
        dxDrawText(lpg and 'Tak' or 'Nie', 18, 338, 785, 432, tocolor(255, 255, 255, 230), 1, fonts[2], 'right', 'top', false, false, false, true)
    elseif currentTab == 2 then
        local max = #carExchange.tuning
        if max == 0 then
            dxDrawText('Brak tuningów', 15, 75, 785, 435, tocolor(255, 255, 255, 230), 1, fonts[2], 'left', 'top')
        else
            local start = math.max(scrollPosition, 0)
            local finish = start + scrollView - 1
            local scrollPosition = scrollPosition / math.max(max - scrollView, 1)
            local scrollSize = math.min(scrollView / max, 1)
            
            dxDrawRoundedRectangle(783, 70, 12, 325, tocolor(85, 85, 85, 200), 5)
            dxDrawRoundedRectangle(783, 70 + scrollPosition * (325 - 325 * scrollSize), 12, 325 * scrollSize, tocolor(180, 180, 180, 160), 5)

            local rowHeight = (325 / scrollView)
            for i = start, finish do
                local tuning = carExchange.tuning[i + 1]
                if not tuning then break end

                local y = 70 + (i - start) * rowHeight
                local rowHeight = rowHeight - 5
                dxDrawRoundedRectangle(7, y, 768, rowHeight, tocolor(35, 35, 35, 245), 15)
                dxDrawText(tuning, 18, y, 785, y + rowHeight, tocolor(255, 255, 255, 230), 1, fonts[2], 'left', 'center')
            end
        end
    end

    -- tabs
    local function color(tab)
        return currentTab == tab and 0xCCFF8800 or 0x66FFFFFF
    end

    local function size(tab)
        return currentTab == tab and 12 or 8
    end

    dxDrawRoundedRectangle(400 - 180/2, 395, 180, 50, tocolor(30, 30, 30, 245), 20)
    dxDrawCircle(380, 420, size(1), 0, 360, color(1), color(1), 32, 1)
    dxDrawCircle(420, 420, size(2), 0, 360, color(2), color(2), 32, 1)
    -- dxDrawCircle(440, 420, size(3), 0, 360, color(3), color(3), 32, 1)

    dxDrawText('Q', 350, 420, nil, nil, 0x99FFFFFF, 1, fonts[2], 'right', 'center')
    dxDrawText('E', 450, 420, nil, nil, 0x99FFFFFF, 1, fonts[2], 'left', 'center')
    dxSetBlendMode('blend')
    
    dxSetRenderTarget()
end

local function render()
    local vehicle = getClosestVehicleWithElementData('vehicle:carExchange', 15)
    if not vehicle then
        updateRenderTarget()
        return
    end
    
    if lastVehicle ~= vehicle then
        lastVehicle = vehicle
        currentTab = 1
        scrollPosition = 0
        renderRenderTarget()
    end
    
    local width, length, height = getElementSize(vehicle)
    local x, y, z = getPositionFromElementOffset(vehicle, 0, length / 2, height / 2)
    local lx, ly, lz = getPositionFromElementOffset(vehicle, 0, length / 2 + 5, height / 2)

    local renderTarget = getRenderTarget()
    dxDrawMaterialLine3D(x, y, z + 1, x, y, z, renderTarget, 800/450, tocolor(255, 255, 255), 'postfx', lx, ly, lz)
end

bindKey('q', 'down', function()
    if not lastVehicle then return end
    
    currentTab = currentTab - 1
    if currentTab < 1 then
        currentTab = 2
    end

    renderRenderTarget()
end)

bindKey('e', 'down', function()
    if not lastVehicle then return end
    
    currentTab = currentTab + 1
    if currentTab > 2 then
        currentTab = 1
    end

    renderRenderTarget()
end)

bindKey('mouse_wheel_down', 'down', function()
    if not lastVehicle then return end
    if currentTab ~= 2 then return end

    local carExchange = getElementData(lastVehicle, 'vehicle:carExchange')
    if not carExchange then return end

    local max = #carExchange.tuning
    scrollPosition = math.min(math.max(scrollPosition + 1, 0), math.max(max - scrollView, 0))
    renderRenderTarget()
end)

bindKey('mouse_wheel_up', 'down', function()
    if not lastVehicle then return end
    if currentTab ~= 2 then return end

    scrollPosition = math.max(scrollPosition - 1, 0)
    renderRenderTarget()
end)

addEventHandler('onClientRestore', root, function()
    if renderTarget and isElement(renderTarget.element) then
        renderRenderTarget()
    end
end)

addEventHandler('onClientPreRender', root, render)

function addCents(amount)
    -- return '$' .. string.format('%0.2f', amount / 100)
    local value = ('%0.2f'):format(amount / 100)
    local integer, decimal = value:match('(%d+)%.(%d+)')
    return ('%s.%s $'):format(formatNumber(integer), decimal)
end