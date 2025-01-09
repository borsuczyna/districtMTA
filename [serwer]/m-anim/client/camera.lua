local sx, sy = guiGetScreenSize()
local camera = false

local function updateCamera()
    if not camera then return end

    setElementPosition(camera.tempObject, camera.x, camera.y, camera.z)
    setElementRotation(camera.tempObject, camera.rx, camera.ry, camera.rz)

    local lx, ly, lz = getPositionFromElementOffset(camera.tempObject, 0, 1, 0)
    setCameraMatrix(camera.x, camera.y, camera.z, lx, ly, lz, 0, 90)

    if camera.holding then
        local cx, cy = getCursorPosition()
        cx, cy = cx * sx, cy * sy
        cx, cy = cx - camera.lastX, cy - camera.lastY

        camera.rz = camera.rz - cx * 0.1
        camera.rx = math.max(-89, math.min(89, camera.rx - cy * 0.1))

        setCursorPosition(camera.lastX, camera.lastY)

        local mx, my, mz = 0, 0, 0
        if getKeyState('w') then
            my = my + 0.1
        elseif getKeyState('s') then
            my = my - 0.1
        end

        if getKeyState('a') then
            mx = mx - 0.1
        elseif getKeyState('d') then
            mx = mx + 0.1
        end

        if getKeyState('space') then
            mz = mz + 0.1
        elseif getKeyState('lshift') then
            mz = mz - 0.1
        end

        local x, y, z = getPositionFromElementOffset(camera.tempObject, mx / 4, my / 4, mz / 4)
        camera.x, camera.y, camera.z = x, y, z
    end
end

local function clickCamera(button, state, _, _, _, _, _, element)
    if button ~= 'right' then return end
    
    camera.holding = state == 'down'
    if camera.holding then
        local cx, cy = getCursorPosition()
        cx, cy = cx * sx, cy * sy
        camera.lastX, camera.lastY = cx, cy
    end
end

function toggleCamera(visible)
    if visible then
        local x, y, z = getPositionFromElementOffset(localPlayer, 0, 2, 0.6)
        local rx, ry, rz = getElementRotation(localPlayer)
        local tempObject = createObject(1337, x, y, z)

        setElementCollisionsEnabled(tempObject, false)
        setElementAlpha(tempObject, 0)

        camera = {
            x = x,
            y = y,
            z = z,
            rx = rx,
            ry = ry,
            rz = rz + 180,
            tempObject = tempObject,
        }

        addEventHandler('onClientRender', root, updateCamera)
        addEventHandler('onClientClick', root, clickCamera)
        showCursor(true)
    else
        if not camera then return end
        destroyElement(camera.tempObject)
        camera = false
        setCameraTarget(localPlayer)
        showCursor(false)
        removeEventHandler('onClientRender', root, updateCamera)
        removeEventHandler('onClientClick', root, clickCamera)
    end
end