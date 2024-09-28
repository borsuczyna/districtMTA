local vehicleParts = {}
local _getVehicleUpgradeOnSlot = getVehicleUpgradeOnSlot
local _removeVehicleUpgrade = removeVehicleUpgrade
local _addVehicleUpgrade = addVehicleUpgrade

local function destroyVehicleTuningPart(vehicle, partName)
    if not vehicleParts[vehicle] then return end

    local part = vehicleParts[vehicle][partName]
    if part and isElement(part) then
        destroyElement(part)
        vehicleParts[vehicle][partName] = nil
    end
end

function removeVehicleUpgradeOnSlot(vehicle, slotName)
    if not isElement(vehicle) then return end

    local slotId = upgradesOriginalSlots[slotName]
    if slotId then
        local upgrade = getVehicleOriginalUpgradeOnSlot(vehicle, slotName)
        if upgrade then
            return _removeVehicleUpgrade(vehicle, upgrade)
        end
    end

    destroyVehicleTuningPart(vehicle, slotName)
end

function removeVehicleUpgrade(vehicle, model)
    -- local slotName = getUpgradeSlotByModel(model)
    -- if not slotName then return false end

    -- local parts = getVehicleCustomUpgrades(vehicle)
    -- if not parts[slotName] then return false end

    -- parts[slotName] = nil
    -- setElementData(vehicle, 'vehicle:custom-upgrades', parts)
    -- return true

    local slotName = type(model) == 'string' and getUpgradeSlotByModel(model) or getOriginalUpgradeSlotName(model)
    if not slotName then return false end

    local originalUpgrade = getVehicleOriginalUpgradeOnSlot(vehicle, slotName)
    if originalUpgrade then return _removeVehicleUpgrade(vehicle, originalUpgrade) end

    local customUpgrade = getVehicleCustomUpgradeOnSlot(vehicle, slotName)
    if customUpgrade then
        removeVehicleUpgradeOnSlot(vehicle, slotName)
        return true
    end

    return false
end

function destroyVehicleTuningParts(vehicle)
    if not vehicleParts[vehicle] then return end

    for partName, part in pairs(vehicleParts[vehicle]) do
        if part and isElement(part) then
            destroyElement(part)
        end
    end

    vehicleParts[vehicle] = nil
end

function addVehicleUpgrade(vehicle, model)
    if type(model) == 'number' then
        _addVehicleUpgrade(vehicle, model)
    end

    local slotName = getUpgradeSlotByModel(model)
    if not slotName then return false end

    local vehicleModel = getElementModel(vehicle)
    local components = componentsPositions[vehicleModel]
    if not components then return false end

    local componentData = components[slotName]
    if not componentData then return false end

    local currentUpgrade = getVehicleUpgradeOnSlot(vehicle, slotName)
    if currentUpgrade then
        removeVehicleUpgradeOnSlot(vehicle, slotName)
    end

    local part = createObject(type(model) == 'number' and model or 1337, 0, 0, 0)
    setElementData(part, 'element:model', model, false)

    setElementCollisionsEnabled(part, false)
    local shader = getVehicleShader(vehicle)
    engineApplyShaderToWorldTexture(shader, 'vehiclegrunge256', part)

    if not vehicleParts[vehicle] then
        vehicleParts[vehicle] = {}
    end

    vehicleParts[vehicle][slotName] = part
    return true
end

local function forceVehicleUpgradeWithSlot(vehicle, slotName, upgrade)
    if not isElement(vehicle) then return end
    
    removeVehicleUpgradeOnSlot(vehicle, slotName)
    addVehicleUpgrade(vehicle, upgrade)
end

function forceVehicleUpgrade(vehicle, model)
    local slotName = type(model) == 'string' and getUpgradeSlotByModel(model) or getOriginalUpgradeSlotName(model)
    if not slotName then return end

    forceVehicleUpgradeWithSlot(vehicle, slotName, model)
end

local function getVehicleComponentMatrix(vehicle, component, offsetPosition)
    if not isElement(vehicle) or not isElementStreamedIn(vehicle) then return end

    local check = componentsChecks[component]
    if check and not check(vehicle) then return end

    local position = Vector3(getVehicleComponentPosition(vehicle, component, 'world'))
    local rotation = Vector3(getVehicleComponentRotation(vehicle, component, 'world'))

    local matrix = Matrix(position, rotation)
    matrix = Matrix(matrix:transformPosition(offsetPosition), rotation)

    return matrix
end

local function renderVehicleTuningPart(vehicle, partName, part, componentData)
    if not isElement(vehicle) or not isElement(part) then return end

    local matrix = getVehicleComponentMatrix(vehicle, componentData.component, componentData.position, componentData.rotation)
    if not matrix then
        setElementAlpha(part, 0)
        return
    end

    setElementAlpha(part, 255)
    setElementMatrix(part, matrix)
    setObjectScale(part, componentData.scale)

    local interior = getElementInterior(vehicle)
    local dimension = getElementDimension(vehicle)

    setElementInterior(part, interior)
    setElementDimension(part, dimension)
end

local function renderVehicleTuningParts(vehicle)
    local parts = vehicleParts[vehicle]
    if not parts then return end

    if not isElement(vehicle) then
        destroyVehicleTuningParts(vehicle)
        return
    end

    local model = getElementModel(vehicle)
    local components = componentsPositions[model]
    if not components then
        destroyVehicleTuningParts(vehicle)
        return
    end
    
    local shader = getVehicleShader(vehicle)
    local lighting = getElementLighting(vehicle)
    local r, g, b = getVehicleColor(vehicle, true)
    dxSetShaderValue(shader, 'gVehicleLighting', (lighting or 1) * 0.8 + 0.1)
    dxSetShaderValue(shader, 'gVehicleColor', r / 255, g / 255, b / 255, 1)

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

-- sync
local function syncVehicleUpgrades(vehicle)
    local upgrades = getElementData(vehicle, 'vehicle:custom-upgrades')
    if not upgrades then return end

    -- add all upgrades
    for slotName, upgrade in pairs(upgrades) do
        forceVehicleUpgradeWithSlot(vehicle, slotName, upgrade)
    end

    -- if there are any upgrades that are not in the list, remove them
    for slotName, part in pairs(vehicleParts[vehicle] or {}) do
        if not upgrades[slotName] then
            removeVehicleUpgradeOnSlot(vehicle, slotName)
        end
    end
end

addEventHandler('onClientElementDataChange', root, function(key, oldValue)
    if getElementType(source) == 'vehicle' and key == 'vehicle:custom-upgrades' then
        syncVehicleUpgrades(source)
    end
end)

addEventHandler('onClientElementStreamIn', root, function()
    if getElementType(source) == 'vehicle' then
        syncVehicleUpgrades(source)
    end
end)

addEventHandler('onClientElementStreamOut', root, function()
    if getElementType(source) == 'vehicle' then
        destroyVehicleTuningParts(source)
    end
end)

addEventHandler('onClientElementDestroy', root, function()
    if getElementType(source) == 'vehicle' then
        destroyVehicleTuningParts(source)
    end
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
    for _, vehicle in ipairs(getElementsByType('vehicle')) do
        syncVehicleUpgrades(vehicle)
    end
end)

-- test
-- local vehicle = getPedOccupiedVehicle(localPlayer)
-- addVehicleUpgrade(vehicle, 'tuning/spoiler')

-- bindKey('1', 'down', function()
--     local vehicle = getPedOccupiedVehicle(localPlayer)
--     if not vehicle then return end

--     forceVehicleUpgrade(vehicle, 'tuning/spoiler')
-- end)

-- bindKey('2', 'down', function()
--     local vehicle = getPedOccupiedVehicle(localPlayer)
--     if not vehicle then return end

--     forceVehicleUpgrade(vehicle, 1002)
-- end)

-- bindKey('3', 'down', function()
--     local vehicle = getPedOccupiedVehicle(localPlayer)
--     if not vehicle then return end

--     removeVehicleUpgradeOnSlot(vehicle, 'spoiler')
-- end)