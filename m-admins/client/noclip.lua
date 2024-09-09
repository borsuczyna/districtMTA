local sx, sy = guiGetScreenSize()
local font = exports['m-ui']:getFont('Inter-Medium', 12)
local noclipEnabled = false

local function max(...)
    local max = 0
    local args = {...}
    for i = 1, #args do
        if tonumber(args[i]) and tonumber(args[i]) > max then
            max = tonumber(args[i])
        end
    end

    return max
end

local function renderNoclip()    
    local element = localPlayer
    local vehicle = getPedOccupiedVehicle(element)
    if vehicle then
        element = vehicle
    end

    local x, y, z = getElementPosition(element)
    local rX, rY, rZ = getElementRotation(element)
    local text = ('#ff8800Pozycja: #ffffff%.2f, %.2f, %.2f\n#ff8800Rotacja: #ffffff%.2f, %.2f, %.2f'):format(x, y, z, rX, rY, rZ)
    local textNoHex = ('Pozycja: %.2f, %.2f, %.2f\nRotacja: %.2f, %.2f, %.2f'):format(x, y, z, rX, rY, rZ)

    dxDrawText(textNoHex, 2, 2, sx + 2, sy - 20 + 2, tocolor(0, 0, 0, 155), 1, font, 'center', 'bottom', false, false, false, true, false)
    dxDrawText(text, 0, 0, sx, sy - 20, white, 1, font, 'center', 'bottom', false, false, false, true, false)

    -- update noclip
    local cx, cy, cz, lx, ly, lz = getCameraMatrix()
    local rot = math.atan2(ly - cy, lx - cx)
    setElementRotation(element, 0, 0, math.deg(rot) - 90, 'default', true)

    local speed = 0.5
    local nx, ny, nz = 0, 0, 0

    if not isChatBoxInputActive() then
        if exports['m-ui']:getControllerButton(8) > 0.1 or getKeyState('lctrl') then
            speed = 5
        elseif exports['m-ui']:getControllerButton(7) > 0.1 or getKeyState('lalt') then
            speed = 0.1
        end

        local forwards = max(getAnalogControlState('forwards'), getAnalogControlState('accelerate'), (getKeyState('w') and 1))
        if forwards > 0.1 then
            nx = nx + math.cos(rot) * speed * forwards
            ny = ny + math.sin(rot) * speed * forwards
        end

        local backwards = max(getAnalogControlState('backwards'), getAnalogControlState('brake_reverse'), (getKeyState('s') and 1))
        if backwards > 0.1 then
            nx = nx - math.cos(rot) * speed * backwards
            ny = ny - math.sin(rot) * speed * backwards
        end

        local left = max(getAnalogControlState('left'), getAnalogControlState('vehicle_left'), (getKeyState('a') and 1))
        if left > 0.1 then
            nx = nx + math.cos(rot + math.rad(90)) * speed * left
            ny = ny + math.sin(rot + math.rad(90)) * speed * left
        end

        local right = max(getAnalogControlState('right'), getAnalogControlState('vehicle_right'), (getKeyState('d') and 1))
        if right > 0.1 then
            nx = nx + math.cos(rot - math.rad(90)) * speed * right
            ny = ny + math.sin(rot - math.rad(90)) * speed * right
        end

        local up = (exports['m-ui']:getControllerButton(1) or 0) > 0.1 or getKeyState('space')
        if up then
            nz = nz + speed
        end

        local down = (exports['m-ui']:getControllerButton(2) or 0) > 0.1 or getKeyState('lshift')
        if down then
            nz = nz - speed
        end

        setElementPosition(element, x + nx, y + ny, z + nz)
    end
end

function toggleNoClip()
    if not doesPlayerHavePermission(localPlayer, 'noclip') then return end

    if not noclipEnabled and getElementData(localPlayer, 'player:job') and getElementData(localPlayer, 'player:rank') < 5 then
        return exports['m-notis']:addNotification('error', 'Noclip', 'Nie możesz używać noclipa będąc w pracy')
    end

    noclipEnabled = not noclipEnabled

    local element = localPlayer
    local vehicle = getPedOccupiedVehicle(element)
    if vehicle then
        element = vehicle
    end

    if noclipEnabled then
        addEventHandler('onClientRender', root, renderNoclip)
        setElementCollisionsEnabled(element, false)
        setElementFrozen(element, true)
    else
        removeEventHandler('onClientRender', root, renderNoclip)
        setElementCollisionsEnabled(element, true)
        setElementFrozen(element, false)
    end
end

addEventHandler('onClientElementDataChange', localPlayer, function(dataName)
    if dataName == 'player:job' and noclipEnabled then
        toggleNoClip()
    end
end)

function controllerButtonPressed(button)
    if button ~= 14 or isCursorShowing() then return end
    toggleNoClip()
end

addEventHandler('onClientKey', root, function(button, press)
    if button ~= 'x' or not press or isChatBoxInputActive() then return end
    toggleNoClip()
end)
addEventHandler('controller:buttonPressed', root, controllerButtonPressed)