addEvent('houses:setFurnitureEditMode', true)

local editing = false
local holdingAxis = false
local sx, sy = guiGetScreenSize()
local zoomOriginal = sx < 2048 and math.min(2.2, 2048/sx) or 1
local zoom = 1
local cursorDown = false

local function drawDot(x, y, z, color)
    local px, py = getScreenFromWorldPosition(x, y, z)
    if not px or not py then return end

    local x, y, w, h = px - 15/zoom, py - 15/zoom, 30/zoom, 30/zoom
    dxDrawImage(x, y, w, h, 'data/textures/dot.png', 0, 0, 0, color)
    return isMouseInPosition(x, y, w, h)
end

local function distanceNotAbsolute(x, y)
    return math.sqrt(x * x + y * y) * ((x + y) < 0 and -1 or 1)
end

local function drawEditLine(axis, x2, y2, z2, color)
    local x, y, z = getElementPosition(editing.furniture.object)
    local tx, ty, tz = getPositionFromElementOffset(editing.furniture.object, x2, y2, z2)
    dxDrawLine3D(x, y, z, tx, ty, tz, color, 2)

    local px, py = getScreenFromWorldPosition(x, y, z, 100)
    local ptx, pty = getScreenFromWorldPosition(tx, ty, tz, 100)
    if not px or not py or not ptx or not pty then return end

    local inside = drawDot(tx, ty, tz, color)
    local cx, cy = getCursorPosition()
    if not cx or not cy then
        holdingAxis = false
        return
    end

    cx, cy = cx * sx, cy * sy

    local xDiff, yDiff = ptx - px, pty - py
    local distance = math.max(0.01, getDistanceBetweenPoints2D(px, py, ptx, pty))
    xDiff, yDiff = xDiff / distance, yDiff / distance

    if cursorDown then
        if inside and not holdingAxis then
            holdingAxis = {
                axis = axis,
                cx = cx,
                cy = cy,
            }
        elseif holdingAxis and holdingAxis.axis == axis then
            local changedX, changedY = cx - holdingAxis.cx, cy - holdingAxis.cy
            if editing.editMode == 'rotation' then
                xDiff, yDiff = yDiff, xDiff
            end
            changedX = changedX * xDiff
            changedY = changedY * yDiff

            local movedDistance = distanceNotAbsolute(changedX, changedY) / (editing.editMode == 'rotation' and 2.5 or 100)

            local tx, ty, tz = getPositionFromElementOffset(editing.furniture.object, x2 * movedDistance, y2 * movedDistance, z2 * movedDistance)

            if editing.editMode == 'position' then
                local tx, ty, tz = getPositionFromElementOffset(editing.furniture.object, x2 * movedDistance, y2 * movedDistance, z2 * movedDistance)
                setElementPosition(editing.furniture.object, tx, ty, tz)
            elseif editing.editMode == 'rotation' then
                local rx, ry, rz = getElementRotation(editing.furniture.object)
                local rx, ry, rz = rx + x2 * movedDistance, ry + y2 * movedDistance, rz + z2 * movedDistance
                setElementRotation(editing.furniture.object, rx, ry, rz)
            end

            holdingAxis.cx, holdingAxis.cy = cx, cy
        end
    else
        holdingAxis = false
    end
end

local function drawFurniture(data)
    local x, y, z = getElementPosition(data.object)
    local px, py = getScreenFromWorldPosition(x, y, z)
    local isEditing = editing.furniture and editing.furniture.uid == data.uid

    if isEditing then
        drawEditLine('x', 0.5, 0, 0, 0xFFFF0000)
        drawEditLine('y', 0, 0.5, 0, 0xFF00FF00)
        drawEditLine('z', 0, 0, 0.5, 0xFF0000FF)
    end

    if not px or not py then return end
    
    local icons = {'data/textures/furniture.png', 'data/textures/remove.png'}
    local furnitureData = exports['m-inventory']:getFurnitureByModel(data.model)
    if furnitureData and furnitureData.textures and #furnitureData.textures > 1 then
        table.insert(icons, 2, 'data/textures/paint.png')
    end

    if isEditing then
        icons = {'data/textures/check.png', editing.editMode == 'position' and 'data/textures/rotate.png' or 'data/textures/position.png', 'data/textures/remove.png'}
    end

    local width = 95/zoom * #icons
    for i, icon in ipairs(icons) do
        local x = px - width / 2 + (i - 1) * 95/zoom
        local y = py - 45/zoom
        local w, h = 90/zoom, 90/zoom
        local over = isMouseInPosition(x, y, w, h)

        dxDrawImage(x, y, w, h, icon, 0, 0, 0, over and 0xFFFFFFFF or 0xAAFFFFFF)
    end
end

local function clickFurniture(data)
    local x, y, z = getElementPosition(data.object)
    local px, py = getScreenFromWorldPosition(x, y, z)
    if not px or not py then return end

    local icons = {
        {'data/textures/furniture.png', function()
            editing.furniture = data
        end},
        {'data/textures/remove.png', function()
            triggerServerEvent('houses:removeFurniture', resourceRoot, data.uid)
        end},
    }

    local furnitureData = exports['m-inventory']:getFurnitureByModel(data.model)
    if furnitureData and furnitureData.textures and #furnitureData.textures > 1 then
        table.insert(icons, 2, {'data/textures/paint.png', function()
            triggerServerEvent('houses:changeFurnitureTexture', resourceRoot, data.uid)
        end})
    end

    if editing.furniture and editing.furniture.uid == data.uid then
        icons = {
            {'data/textures/check.png', function()
                local x, y, z = getElementPosition(editing.furniture.object)
                local rx, ry, rz = getElementRotation(editing.furniture.object)
                triggerServerEvent('houses:saveFurniture', resourceRoot, data.uid, x, y, z, rx, ry, rz)

                setElementCollisionsEnabled(editing.furniture.object, true)
                editing.furniture = false
            end},
            {editing.editMode == 'position' and 'data/textures/rotate.png' or 'data/textures/position.png', function()
                editing.editMode = editing.editMode == 'position' and 'rotation' or 'position'
            end},
            {'data/textures/remove.png', function()
                triggerServerEvent('houses:removeFurniture', resourceRoot, data.uid)
            end},
        }
    end

    local width = 95/zoom * #icons
    for i, icon in ipairs(icons) do
        local x = px - width / 2 + (i - 1) * 95/zoom
        local y = py - 45/zoom
        local w, h = 90/zoom, 90/zoom
        local over = isMouseInPosition(x, y, w, h)

        if over then
            if icon[2] then
                icon[2]()
            end
        end
    end
end

local function renderFurnitureEditor()
    local interfaceSize = getElementData(localPlayer, "player:interfaceSize")
    zoom = zoomOriginal * (25 / interfaceSize)
    
    local furniture = getInteriorFurniture()
    if not furniture then return end
    
    if editing.furniture and isElement(editing.furniture.object) then
        drawFurniture(editing.furniture)
    else
        for i, data in ipairs(furniture) do
            drawFurniture(data)
        end
    end
end

local function clickFurnitureEditor(button, state)
    if button == 'left' then
        cursorDown = state == 'down'
    end
    if button ~= 'left' or state ~= 'down' then return end

    local furniture = getInteriorFurniture()
    if not furniture then return end

    for i, data in ipairs(furniture) do
        clickFurniture(data)
    end
end

addEventHandler('houses:setFurnitureEditMode', resourceRoot, function(state, furnitureUid)    
    local furniture = false
    if state and furnitureUid then
        furniture = getFurnitureData(furnitureUid)
        if furniture then
            setElementCollisionsEnabled(furniture.object, false)
        end
    end

    editing = {
        state = state,
        furniture = furniture,
        editMode = 'position',
    }

    if state then
        if isEventHandlerAdded('onClientRender', root, renderFurnitureEditor) then return end
        addEventHandler('onClientRender', root, renderFurnitureEditor, true, 'high+9999')
        addEventHandler('onClientClick', root, clickFurnitureEditor)
    else
        removeEventHandler('onClientRender', root, renderFurnitureEditor)
        removeEventHandler('onClientClick', root, clickFurnitureEditor)
    end
end)