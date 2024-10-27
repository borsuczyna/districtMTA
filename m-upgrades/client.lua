local vehicleParts = {}
local lightsStates = {}
local _getVehicleUpgradeOnSlot = getVehicleUpgradeOnSlot
local _removeVehicleUpgrade = removeVehicleUpgrade
local _addVehicleUpgrade = addVehicleUpgrade
local ambientColor = {0, 0, 0}
local lastDamageUpdate = 0

local function destroyVehicleTuningPart(vehicle, partName)
    if not vehicleParts[vehicle] then return end

    local part = vehicleParts[vehicle][partName]
    if part and isElement(part) then
        destroyElement(part)
        vehicleParts[vehicle][partName] = nil
    end
end

local function updateVehicleLightsState(vehicle)
    if not isElement(vehicle) then return end

    local lastState = lightsStates[vehicle]
    local currentState = areVehicleLightsOn(vehicle)

    if lastState == currentState then return end

    lightsStates[vehicle] = currentState

    local defaultShader = getVehicleShader(vehicle).default
    local lightsShader = getLightsShader()

    local parts = vehicleParts[vehicle]
    if not parts then return end

    for partName, part in pairs(parts) do
        if part and isElement(part) then
            if currentState then
                engineApplyShaderToWorldTexture(lightsShader, 'vehiclelights128', part)
                engineRemoveShaderFromWorldTexture(defaultShader, 'vehiclelights128', part)
            else
                engineApplyShaderToWorldTexture(defaultShader, 'vehiclelights128', part)
                engineRemoveShaderFromWorldTexture(lightsShader, 'vehiclelights128', part)
            end
        end
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
    setElementDoubleSided(part, true)
    
    local shader = getVehicleShader(vehicle)
    local lightsShader = getLightsShader()

    engineApplyShaderToWorldTexture(shader.default, '*', part)
    engineRemoveShaderFromWorldTexture(shader.default, 'vehiclegrunge256', part)
    engineRemoveShaderFromWorldTexture(shader.default, 'vehiclelights128', part)
    engineApplyShaderToWorldTexture(shader.paint, 'vehiclegrunge256', vehicle)
    engineApplyShaderToWorldTexture(shader.paint, 'vehiclegrunge256', part)
    -- engineApplyShaderToWorldTexture(lightsShader, 'vehiclelights128', part)

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

local function getVehicleComponentMatrix(vehicle, component, attachComponent, offsetPosition)
    if not isElement(vehicle) or not isElementStreamedIn(vehicle) then return end

    local check = componentsChecks[component]
    if check and not check(vehicle) then return end

    if attachComponent then
        check = componentsChecks[attachComponent]
        if check and not check(vehicle) then return end
    end

    local position = Vector3(getVehicleComponentPosition(vehicle, component, 'world'))
    local rotation = Vector3(getVehicleComponentRotation(vehicle, component, 'world'))

    local matrix = Matrix(position, rotation)
    matrix = Matrix(matrix:transformPosition(offsetPosition), rotation)

    return matrix
end

-- iprint(getWorldProperty('Illumination'))

local function renderVehicleTuningPart(vehicle, partName, part, componentData)
    if not isElement(vehicle) or not isElement(part) then return end

    local matrix = getVehicleComponentMatrix(vehicle, componentData.component, componentData.attach, componentData.position, componentData.rotation)
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

    if componentData.attach then
        setVehicleComponentVisible(vehicle, componentData.attach, false)
    end
end

local function updatePartDamage(vehicle, partName)
    local part = vehicleParts[vehicle][partName]
    if not part then return end

    local componentData = componentsPositions[getElementModel(vehicle)][partName]
    if not componentData then return end

    local damageCheck = damageChecks[componentData.component] or damageChecks[componentData.attach]
    local model = tostring(getElementData(part, 'element:model') or getElementModel(part)):gsub('_dam', '')
    local damageModelExists = doesModelExist(('%s_dam'):format(model))

    if damageModelExists and damageCheck then
        local damaged = damageCheck(vehicle)
        local model = (damaged and '%s_dam' or '%s'):format(model)
        setElementData(part, 'element:model', model, false)
    end
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
    
    local x, y, z = getElementPosition(vehicle)
    local shader = getVehicleShader(vehicle)
    local lighting = math.pow(getElementLighting(vehicle) or 1, 0.2) * 0.45
    local r, g, b = getVehicleColor(vehicle, true)
    dxSetShaderValue(shader.paint, 'gVehicleLighting', lighting)
    dxSetShaderValue(shader.paint, 'gVehiclePosition', x, y, z)
    dxSetShaderValue(shader.paint, 'gVehicleColor', r / 255, g / 255, b / 255, 1)
    dxSetShaderValue(shader.paint, 'gAmbientColor', ambientColor)
    dxSetShaderValue(shader.default, 'gVehicleLighting', lighting)

    for partName, part in pairs(parts) do
        local componentData = components[partName]

        if componentData then
            renderVehicleTuningPart(vehicle, partName, part, componentData)
        end
    end

    updateVehicleLightsState(vehicle)
end

local function updateVehicleDamage(vehicle)
    local parts = vehicleParts[vehicle]
    if not parts then return end

    for partName, _ in pairs(parts) do
        updatePartDamage(vehicle, partName)
    end
end

local function updateVehiclesDamage()
    for vehicle, parts in pairs(vehicleParts) do
        updateVehicleDamage(vehicle)
    end
end

addEventHandler('onClientPreRender', root, function()
    ambientColor = getMaterialDiffuseColor()
    
    for vehicle, parts in pairs(vehicleParts) do
        renderVehicleTuningParts(vehicle)
    end

    if getTickCount() - lastDamageUpdate > 300 then
        updateVehiclesDamage()
        lastDamageUpdate = getTickCount()
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

    -- update lights state
    updateVehicleLightsState(vehicle)

    -- update damage
    updateVehicleDamage(vehicle)
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
    for _, vehicle in ipairs(getElementsByType('vehicle', root, true)) do
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