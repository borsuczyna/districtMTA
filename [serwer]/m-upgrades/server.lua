local _addVehicleUpgrade = addVehicleUpgrade
local _removeVehicleUpgrade = removeVehicleUpgrade

local function addVehicleCustomUpgrade(vehicle, slotName, upgrade)
    local parts = getVehicleCustomUpgrades(vehicle)
    parts[slotName] = upgrade
    setElementData(vehicle, 'vehicle:custom-upgrades', parts)
end

function doesVehicleHaveCustomUpgradeOnSlot(vehicle, slotName)
    local parts = getVehicleCustomUpgrades(vehicle)
    return (not not parts[slotName])
end

function addVehicleUpgrade(vehicle, model)
    local slotName = type(model) == 'string' and getUpgradeSlotByModel(model) or getOriginalUpgradeSlotName(model)
    if not slotName then return false end

    local originalUpgrade = getVehicleOriginalUpgradeOnSlot(vehicle, slotName)
    if originalUpgrade then return false end

    local customUpgrade = getVehicleCustomUpgradeOnSlot(vehicle, slotName)
    if customUpgrade then return false end

    if type(model) == 'number' then
        return _addVehicleUpgrade(vehicle, model)
    end

    local vehicleModel = getElementModel(vehicle)
    local components = componentsPositions[vehicleModel]
    if not components then return false end

    local componentData = components[slotName]
    if not componentData then return false end

    addVehicleCustomUpgrade(vehicle, slotName, model)
    return true
end

function removeVehicleUpgradeOnSlot(vehicle, slotName)
    local slotId = upgradesOriginalSlots[slotName]
    if slotId then
        local upgrade = getVehicleOriginalUpgradeOnSlot(vehicle, slotName)
        if upgrade then
            return _removeVehicleUpgrade(vehicle, upgrade)
        end
    end

    local parts = getVehicleCustomUpgrades(vehicle)
    if not parts[slotName] then return false end

    parts[slotName] = nil
    setElementData(vehicle, 'vehicle:custom-upgrades', parts)
    return true
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

function forceVehicleUpgrade(vehicle, model)
    local slotName = type(model) == 'string' and getUpgradeSlotByModel(model) or getOriginalUpgradeSlotName(model)
    if not slotName then return false end

    removeVehicleUpgradeOnSlot(vehicle, slotName)
    return addVehicleUpgrade(vehicle, model)
end

-- test
local player = getPlayerFromName('fuckltc')

-- addVehicleUpgrade(vehicle, 1002)
-- addVehicleUpgrade(vehicle, 'tuning/spoiler')

-- bindKey(player, '1', 'down', function()
--     local vehicle = getPedOccupiedVehicle(player)
--     removeVehicleUpgradeOnSlot(vehicle, 'spoiler')
-- end)

-- bindKey(player, '2', 'down', function()
--     local vehicle = getPedOccupiedVehicle(player)
--     forceVehicleUpgrade(vehicle, 'tuning/spoiler')
-- end)

-- bindKey(player, '3', 'down', function()
--      local vehicle = getPedOccupiedVehicle(player)
--      forceVehicleUpgrade(vehicle, 'tuning/pbar')
--  end)