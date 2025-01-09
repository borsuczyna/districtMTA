addEvent('tuning:preview', true)
addEvent('tuning:removePreview', true)
addEvent('tuning:updateOriginalTuning', true)
addEvent('tuning:exitGarage', true)
addEvent('tuning:enterGarage', true)

local interiorGarage = nil
vehicleTuningCategories = nil
originalTuning = nil

local function destroyTuningGarage()
    if isElement(interiorGarage) then
        destroyElement(interiorGarage)
    end
end

local function createTuningGarage()
    destroyTuningGarage()

    local uid = getElementData(localPlayer, 'player:uid')
    interiorGarage = createObject(1337, 984.125, -1248.064, 54.678)
    setElementData(interiorGarage, 'element:model', 'car_repair_shop_interior')
    setElementDimension(interiorGarage, 11000 + uid)
end

addEventHandler('tuning:preview', root, function(key, index)
    if not vehicleTuningCategories then return end

    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    index = tonumber(index) + 1
    local data = table.findCallback(vehicleTuningCategories, function(v)
        return v.key == key
    end)

    if not data then return end

    data = data.items[index]
    if not data then return end

    data.preview(vehicle)
end)

addEventHandler('tuning:removePreview', root, function(key)
    if not vehicleTuningCategories then return end

    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    local data = table.findCallback(vehicleTuningCategories, function(v)
        return v.key == key
    end)

    if not data then return end

    data.remove(vehicle)
end)

addEventHandler('tuning:updateOriginalTuning', root, function()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    vehicleTuningCategories = getVehicleUpgradeCategories(vehicle, compatibleParts)
    originalTuning = getVehicleOriginalUpgrades(vehicle)
end)

local function exitGarage()
    destroyTuningGarage()
    fadeCamera(true, 0.5)
    showChat(true)
    setElementData(localPlayer, 'player:hiddenHUD', false)
    triggerServerEvent('tuning:exitGarage', resourceRoot)
    setCameraTarget(localPlayer)

    local vehicle = getPedOccupiedVehicle(localPlayer)
    for _,slot in pairs(exports['m-upgrades']:getUpgradeSlots()) do
        restoreVehicleUpgrade(vehicle, slot)
    end
end

local function enterGarage()
    setTuningUIVisible(true)
    fadeCamera(true, 0.5)
    showChat(false)
    createTuningGarage()
    setCameraTarget(localPlayer)
    setElementData(localPlayer, 'player:hiddenHUD', true)

    setTimer(function()
        zoomToComponent(getPedOccupiedVehicle(localPlayer), {-1.2, 1.3, 1.1, -0.4, 0.4, 0.2})
    end, 250, 1)
end

addEventHandler('tuning:exitGarage', root, function()
    setTuningUIVisible(false)
    exports['m-loading']:setLoadingVisible(true, 'Wczytywanie...', 1000)
    fadeCamera(false, 0.5)
    setTimer(exitGarage, 1000, 1)
end)

function enterTuningGarage()
    fadeCamera(false, 0.5)
    exports['m-loading']:setLoadingVisible(true, 'Wczytywanie interioru...', 1000)
    setTimer(enterGarage, 1000, 1)
end

addEventHandler('tuning:enterGarage', root, enterTuningGarage)