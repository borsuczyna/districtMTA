local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local record = false
local fonts = {
    dxCreateFont(':m-ui/data/css/fonts/Inter-Bold.ttf', 30, false, 'proof'),
    dxCreateFont(':m-ui/data/css/fonts/Inter-Medium.ttf', 22, false, 'proof'),
}

local policeVehicles = {
    [596] = true,
}

local function renderScreen()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end
    
    local interfaceSize = getElementData(localPlayer, 'player:interfaceSize')
    local zoom = zoomOriginal * ( 25 / interfaceSize )

    local x, y, z = getPositionFromElementOffset(vehicle, 0, 3, 0)
    local tx, ty, tz = getPositionFromElementOffset(vehicle, 0, 50, 0)

    local hit, hx, hy, hz, hitElement = processLineOfSight(x, y, z, tx, ty, tz, true, true, false, true, false, false, false, false, vehicle)
    tx, ty, tz = hx or tx, hy or ty, hz or tz

    if hitElement and getElementType(hitElement) == 'vehicle' then
        local vx, vy, vz = getElementVelocity(hitElement)
        local speed = math.sqrt(vx^2 + vy^2 + vz^2) * 180
        local driver = getVehicleOccupant(hitElement)
        local driverName = '-'

        if driver then
            driverName = ('(%d) %s'):format(getElementData(driver, 'player:id') or '-', getPlayerName(driver))
        end

        record = {
            speed = speed,
            name = exports['m-models']:getVehicleName(hitElement):sub(1, 20),
            plate = getVehiclePlateText(hitElement),
            driver = driverName,
        }
    end

    if record then
        dxDrawRoundedRectangle(sx/2 - 400/zoom, sy - 260/zoom, 800/zoom, 230/zoom, tocolor(25, 25, 25, 200), 10)
        dxDrawText('Ostatni pomiar', sx/2, sy - 245/zoom, nil, nil, tocolor(255, 255, 255, 255), 1/zoom, fonts[1], 'center', 'top')

        local text1 = ('Pojazd: %s\nRejestracja: %s\nKierowca: %s'):format(record.name, record.plate, record.driver, record.speed)
        local text2 = ('Prędkość: %.2f km/h'):format(record.speed)
        dxDrawText(text1, sx/2 - 380/zoom, sy - 180/zoom, nil, nil, tocolor(255, 255, 255, 255), 1/zoom, fonts[2], 'left', 'top')
        dxDrawText(text2, sx/2 + 380/zoom, sy - 180/zoom, nil, nil, tocolor(255, 255, 255, 255), 1/zoom, fonts[2], 'right', 'top')
    end
end

addEventHandler('onClientVehicleEnter', root, function(player, seat)
    local duty = getElementData(localPlayer, 'player:duty')
    if player ~= localPlayer or duty ~= 'SAPD' then return end
    
    local model = getElementModel(source)
    if policeVehicles[model] then
        addEventHandler('onClientRender', root, renderScreen)
    end
end)

addEventHandler('onClientVehicleExit', root, function(player, seat)
    if player ~= localPlayer then return end
    removeEventHandler('onClientRender', root, renderScreen)
end)

-- if already in vehicle
local vehicle = getPedOccupiedVehicle(localPlayer)
if vehicle and getVehicleOccupant(vehicle) == localPlayer then
    local model = getElementModel(vehicle)
    if policeVehicles[model] then
        addEventHandler('onClientRender', root, renderScreen)
    end
end