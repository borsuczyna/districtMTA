local vehicleParts = {}
local componentsPositions = {
    
}

function destroyVehicleTuningPart(vehicle, partName)
    if not vehicleParts[vehicle] then return end

    local part = vehicleParts[vehicle][partName]
    if part and isElement(part) then
        destroyElement(part)
        vehicleParts[vehicle][partName] = nil
    end
end

function createVehicleTuningPart(vehicle, partName, model)
    destroyVehicleTuningPart(vehicle, partName)

    position = position or Vector3(0, 0, 0)
    rotation = rotation or Vector3(0, 0, 0)
    scale = scale or Vector3(1, 1, 1)

    local part = createObject(model, 0, 0, 0)

    if not vehicleParts[vehicle] then
        vehicleParts[vehicle] = {}
    end

    vehicleParts[vehicle][partName] = part
end

function getVehicleComponentMatrix(vehicle, component, offsetPosition)
    if not isElement(vehicle) then return end

    local position = Vector3(getVehicleComponentPosition(vehicle, component, 'world'))
    local rotation = Vector3(getVehicleComponentRotation(vehicle, component, 'world'))

    local matrix = Matrix(position, rotation)
    matrix = Matrix(matrix:transformPosition(offsetPosition), rotation)

    return matrix
end

function renderVehicleTuningPart(vehicle, partName, part, componentData)
    if not isElement(vehicle) or not isElement(part) then return end

    local matrix = getVehicleComponentMatrix(vehicle, componentData.component, componentData.position, componentData.rotation)
    setElementMatrix(part, matrix)
    setObjectScale(part, componentData.scale)
end

function renderVehicleTuningParts(vehicle)
    local parts = vehicleParts[vehicle]
    if not parts then return end

    local model = getElementModel(vehicle)
    local components = componentsPositions[model]

    for partName, part in pairs(parts) do
        local componentData = components[partName]

        if componentData then
            renderVehicleTuningPart(vehicle, partName, part, componentData)
        end
    end
end

addEventHandler('onClientPreRender', root, function()
    for vehicle, parts in pairs(vehicleParts) do
        renderVehicleTuningParts(vehicle)
    end
end)

-- test 
-- createVehicleTuningPart(getPedOccupiedVehicle(localPlayer), 'spoiler', 1049, Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(1.2, 1.2, 1.2))
-- setVehicleDoorOpenRatio(getPedOccupiedVehicle(localPlayer), 1, 1, 1000)

-- editor
if getPlayerName(localPlayer) ~= 'soth' then return end
local sx, sy = guiGetScreenSize()
local editing = true
local editingPosition = {
    component = 'chassis',
    position = Vector3(0, 0, 0),
    -- rotation = Vector3(0, 0, 0),
    scale = Vector3(1, 1, 1)
}
local componentNames = {
    {'boot_dummy', 'Bagażnik', function(veh)
        local openRatio = getVehicleDoorOpenRatio(veh, 1)
        setVehicleDoorOpenRatio(veh, 1, openRatio == 1 and 0 or 1, 200)
    end},
    {'ug_nitro', 'Nitro'},
    {'wheel_rf_dummy', 'Prawe przednie koło'},
    {'wheel_lf_dummy', 'Lewe przednie koło'},
    {'wheel_rb_dummy', 'Prawe tylne koło'},
    {'wheel_lb_dummy', 'Lewe tylne koło'},
    {'chassis', 'Karoseria'},
    {'ug_roof', 'Dach'},
    {'door_rf_dummy', 'Prawe przednie drzwi', function(veh)
        local openRatio = getVehicleDoorOpenRatio(veh, 3)
        setVehicleDoorOpenRatio(veh, 3, openRatio == 1 and 0 or 1, 200)
    end},
    {'door_lf_dummy', 'Lewe przednie drzwi', function(veh)
        local openRatio = getVehicleDoorOpenRatio(veh, 2)
        setVehicleDoorOpenRatio(veh, 2, openRatio == 1 and 0 or 1, 200)
    end},
    {'door_rr_dummy', 'Prawe tylne drzwi', function(veh)
        local openRatio = getVehicleDoorOpenRatio(veh, 5)
        setVehicleDoorOpenRatio(veh, 5, openRatio == 1 and 0 or 1, 200)
    end},
    {'door_lr_dummy', 'Lewe tylne drzwi', function(veh)
        local openRatio = getVehicleDoorOpenRatio(veh, 4)
        setVehicleDoorOpenRatio(veh, 4, openRatio == 1 and 0 or 1, 200)
    end},
    {'bonnet_dummy', 'Maska', function(veh)
        local openRatio = getVehicleDoorOpenRatio(veh, 0)
        setVehicleDoorOpenRatio(veh, 0, openRatio == 1 and 0 or 1, 200)
    end},
    {'ug_wing_right', 'Prawe skrzydło'},
    {'bump_front_dummy', 'Zderzak przedni'},
    {'bump_rear_dummy', 'Zderzak tylny'},
    {'windscreen_dummy', 'Szyba'},
    {'misc_a', 'Hak'},
    {'ug_wing_left', 'Lewe skrzydło'},
    {'exhaust_ok', 'Wydech'}
}
local editingVehicle = createVehicle(400, 1942.476, -1806.212, 13.383)
setCameraTarget(editingVehicle)
-- setVehicleComponentVisible(editingVehicle, 'bump_rear_dummy', false)
local editingPart = createObject(1004, 0, 0, 0)
setElementCollisionsEnabled(editingPart, false)
if getPlayerName(localPlayer) == 'soth' then
    setElementData(editingPart, 'element:model', 'tuning/pack2/Spoilers/Spoiler4')
end
local editingPartName = 'spoiler2'
local editingModel = 400

addCommandHandler('edit', function(cmd, model)
    setElementModel(editingVehicle, tonumber(model) or 400)
    -- setVehicleComponentVisible(editingVehicle, 'bump_rear_dummy', false)
    editingModel = tonumber(model) or 400
end)

addCommandHandler('reset', function(cmd, model)
    editingPosition = {
        component = editingPosition.component,
        position = Vector3(0, 0, 0),
        -- rotation = Vector3(0, 0, 0),
        scale = Vector3(1, 1, 1)
    }
end)

function updateElementPosition(vehicle)
    local model = getElementModel(vehicle)
    local components = componentsPositions[model]

    if not components then
        componentsPositions[model] = {}
        components = componentsPositions[model]
    end

    components[editingPartName] = {
        component = editingPosition.component,
        position = editingPosition.position,
        -- rotation = editingPosition.rotation,
        scale = editingPosition.scale
    }
end

function getVehicleComponentsNames(vehicle)
    local c = {}

    for k in pairs(getVehicleComponents(vehicle)) do
        table.insert(c, k)
    end

    -- return c
    return {'chassis', 'boot_dummy'}
end

local lastUse = 0

addEventHandler('onClientRender', root, function()
    dxDrawRectangle(0, sy - 200, sx, 200, tocolor(0, 0, 0, 200))
    
    local currentComponentData = false
    for i, component in ipairs(componentNames) do
        if component[1] == editingPosition.component then
            currentComponentData = component
            break
        end
    end

    dxDrawText('Komponent: ' .. (editingPosition.component), 10, sy - 190, sx, sy, tocolor(255, 255, 255), 1.2, 'default-bold')

    local cx, cy = getCursorPosition()
    cx, cy = cx or 0, cy or 0
    cx, cy = cx * sx, cy * sy
    local function drawEditPosition(axis, y)
        local max = 10
        local floatValue = editingPosition.position[axis]/max
        
        dxDrawText(axis:upper() .. ': ' .. editingPosition.position[axis], 10, y, sx, sy, tocolor(255, 255, 255), 1.2, 'default-bold')
        dxDrawRectangle(100, y - 6, 700, 26, tocolor(65,65,65, 150))
        dxDrawRectangle(450 + (floatValue * 700), y - 6, 6, 26, tocolor(255, 255, 255))

        if cx > 100 and cx < 800 and cy > y - 6 and cy < y + 20 then
            if getKeyState('mouse1') then
                editingPosition.position[axis] = math.min(max, math.max(-max, (cx - 100) / 700 * max)) - max/2
                updateElementPosition(editingVehicle)
            end
        end
    end

    local function drawEditRotation(axis, y)
        local max = 360
        local floatValue = editingPosition.rotation[axis]/max
        
        dxDrawText(axis:upper() .. ': ' .. editingPosition.rotation[axis], 460, y, sx, sy, tocolor(255, 255, 255), 1.2, 'default-bold')
        dxDrawRectangle(700, y - 6, 700, 26, tocolor(65,65,65, 150))
        dxDrawRectangle(700 + (floatValue * 700), y - 6, 6, 26, tocolor(255, 255, 255))

        if cx > 550 and cx < 850 and cy > y - 6 and cy < y + 20 then
            if getKeyState('mouse1') then
                editingPosition.rotation[axis] = math.floor(math.min(max, math.max(-max, (cx - 700) / 700 * max)) - max/2)
                updateElementPosition(editingVehicle)
            end
        end
    end

    drawEditPosition('x', sy - 160)
    drawEditPosition('y', sy - 130)
    drawEditPosition('z', sy - 100)
    -- drawEditRotation('x', sy - 160)
    -- drawEditRotation('y', sy - 130)
    -- drawEditRotation('z', sy - 100)

    local function drawEditScale(axis, y)
        local max = 2
        local floatValue = editingPosition.scale[axis]/max
        
        dxDrawText(axis:upper() .. ': ' .. editingPosition.scale[axis], 920, y, sx, sy, tocolor(255, 255, 255), 1.2, 'default-bold')
        dxDrawRectangle(1010, y - 6, 700, 26, tocolor(65,65,65, 150))
        dxDrawRectangle(1160 + (floatValue * 700) - 150, y - 6, 6, 26, tocolor(255, 255, 255))

        if cx > 1010 and cx < 1710 and cy > y - 6 and cy < y + 20 then
            if getKeyState('mouse1') then
                local val = math.min(max, math.max(0, (cx - 1010) / 700 * max))
                val = tonumber(('%.2f'):format(val))
                editingPosition.scale[axis] = val
                updateElementPosition(editingVehicle)
            end
        end
    end

    drawEditScale('x', sy - 160)
    drawEditScale('y', sy - 130)
    drawEditScale('z', sy - 100)

    local currentComponentAction = currentComponentData and currentComponentData[3] or false

    dxDrawRectangle(10, sy - 50, 190, 30, tocolor(65,65,65, 150))
    dxDrawText('Zmień komponent', 10, sy - 50, 200, sy - 20, tocolor(255, 255, 255), 1.2, 'default-bold', 'center', 'center')

    if cx > 10 and cx < 200 and cy > sy - 50 and cy < sy - 20 then
        if getKeyState('mouse1') and (lastUse or 0) + 500 < getTickCount() then
            lastUse = getTickCount()
            -- local currentIndex = 1
            -- for i, component in ipairs(componentNames) do
            --     if component[1] == editingPosition.component then
            --         currentIndex = i
            --         break
            --     end
            -- end

            -- currentIndex = currentIndex + 1
            -- if currentIndex > #componentNames then
            --     currentIndex = 1
            -- end

            -- editingPosition.component = componentNames[currentIndex][1]
            -- updateElementPosition(editingVehicle, editingPosition.position)

            local vehicleComponents = getVehicleComponentsNames(editingVehicle)
            local currentIndex = false

            for i, component in ipairs(vehicleComponents) do
                if component == editingPosition.component then
                    currentIndex = i
                    break
                end
            end

            if currentIndex then
                currentIndex = currentIndex + 1
                if currentIndex > #vehicleComponents then
                    currentIndex = 1
                end

                editingPosition.component = vehicleComponents[currentIndex]
                updateElementPosition(editingVehicle, editingPosition.position)
            else
                editingPosition.component = vehicleComponents[1]
                updateElementPosition(editingVehicle, editingPosition.position)
            end
            
            print(editingPosition.component)
        end
    end

    if currentComponentAction then
        dxDrawText('Akcja: ' .. currentComponentData[2], 210, sy - 70, sx, sy, tocolor(255, 255, 255), 1.2, 'default-bold')
        dxDrawRectangle(210, sy - 50, 200, 30, tocolor(65,65,65, 150))
        dxDrawText('Otwórz/Zamknij', 210, sy - 50, 410, sy - 20, tocolor(255, 255, 255), 1.2, 'default-bold', 'center', 'center')

        if cx > 210 and cx < 410 and cy > sy - 50 and cy < sy - 20 then
            if getKeyState('mouse1') and (lastUse or 0) + 500 < getTickCount() then
                lastUse = getTickCount()
                currentComponentAction(editingVehicle)
            end
        end
    end

    -- render vehicle tuning part
    renderVehicleTuningPart(editingVehicle, editingPartName, editingPart, editingPosition)
end)

addCommandHandler('savepos', function()
    -- setClipboard(inspect(componentsPositions))
    local code = ''
    -- for model, components in pairs(componentsPositions) do
    -- only current
    for model, components in pairs({
        [editingModel] = componentsPositions[editingModel]
    }) do
        code = code .. ('    [%d] = {\n'):format(model)
        for partName, componentData in pairs(components) do
            code = code .. ('        [%q] = {\n'):format(partName)
            code = code .. ('            component = %q,\n'):format(componentData.component)
            code = code .. ('            position = Vector3(%.5f, %.5f, %.5f),\n'):format(componentData.position.x, componentData.position.y, componentData.position.z)
            -- code = code .. ('            rotation = Vector3(%.5f, %.5f, %.5f),\n'):format(componentData.rotation.x, componentData.rotation.y, componentData.rotation.z)
            code = code .. ('            scale = Vector3(%.5f, %.5f, %.5f)\n'):format(componentData.scale.x, componentData.scale.y, componentData.scale.z)
            code = code .. ('        },\n')
        end
        code = code .. ('    },\n')
    end
    setClipboard(code)
end)

-- local sx, sy = guiGetScreenSize()
-- addEventHandler('onClientRender', root, function()
--     dxDrawImage(0, 0, sx, sy, 'bluescreen.png', 0, 0, 0, tocolor(255, 255, 255, 255), true)
-- end)
-- local sound = playSound('xd.wav', true)
-- setSoundVolume(sound, 50)