local sx, sy = guiGetScreenSize()
local font = exports['m-ui']:getFont('Inter-Medium', 12)
local noclipEnabled = false

function renderNoclip()    
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
        if getKeyState('lctrl') then
            speed = 5
        elseif getKeyState('lalt') then
            speed = 0.1
        end

        if getKeyState('w') then
            nx = nx + math.cos(rot) * speed
            ny = ny + math.sin(rot) * speed
        end

        if getKeyState('s') then
            nx = nx - math.cos(rot) * speed
            ny = ny - math.sin(rot) * speed
        end

        if getKeyState('a') then
            nx = nx + math.cos(rot + math.rad(90)) * speed
            ny = ny + math.sin(rot + math.rad(90)) * speed
        end

        if getKeyState('d') then
            nx = nx + math.cos(rot - math.rad(90)) * speed
            ny = ny + math.sin(rot - math.rad(90)) * speed
        end

        if getKeyState('space') then
            nz = nz + speed
        end

        if getKeyState('lshift') then
            nz = nz - speed
        end

        setElementPosition(element, x + nx, y + ny, z + nz)
    end
end

function toggleNoClip()
    if not doesPlayerHavePermission(localPlayer, 'noclip') then return end

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

bindKey('x', 'down', toggleNoClip)