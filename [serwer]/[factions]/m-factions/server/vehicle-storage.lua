local vehicleStorages = {}
local vehicleMarkers = {}
local playersStorageVehicles = {}

function setStorageVehicle(player, vehicle)
    if not isElement(vehicle) then return end
    if not isElement(player) then return end

    playersStorageVehicles[player] = vehicle
end

function updateVehicleStorage(vehicle)
    if vehicleMarkers[vehicle] and isElement(vehicleMarkers[vehicle]) then return end
    if not getElementData(vehicle, 'vehicle:faction') then return end

    local model = getElementModel(vehicle)
    local storage = vehicleStorages[model]
    if not storage then return end

    local x, y, z = unpack(storage.position)
    local marker = createMarker(0, 0, 0, 'cylinder', 1.5, 0, 100, 255, 0)
    attachElements(marker, vehicle, x, y, z)
    setElementData(marker, 'marker:title', storage.name)
    setElementData(marker, 'marker:desc', 'Wyposażenie pojazdu')
    setElementData(marker, 'marker:shelf-faction', storage.faction)
    setElementData(marker, 'marker:shelf-items', storage.data)
    setElementData(marker, 'marker:shelf-storage', model)
    setElementData(marker, 'marker:shelf-vehicle', vehicle)
    addDestroyOnRestartElement(marker, storage.parent)

    addEventHandler('onMarkerHit', marker, onShelfMarkerHit)
    addEventHandler('onMarkerLeave', marker, onShelfMarkerLeave)

    vehicleMarkers[vehicle] = marker
end

function destroyVehicleStorage(vehicle)
    if not vehicleMarkers[vehicle] then return end

    destroyElement(vehicleMarkers[vehicle])
    vehicleMarkers[vehicle] = nil
end

function updateVehiclesStorages()
    local vehicles = getElementsByType('vehicle')
    for i, vehicle in ipairs(vehicles) do
        updateVehicleStorage(vehicle)
    end
end

function createVehicleStorage(model, name, position, faction, data)
    vehicleStorages[model] = {
        name = name,
        position = position,
        faction = faction,
        data = data,
        parent = sourceResource,
        parentName = getResourceName(sourceResource),
    }

    updateVehiclesStorages()
end

addEventHandler('onResourceStart', resourceRoot, updateVehiclesStorages)
addEventHandler('onElementStartSync', root, function()
    if getElementType(source) == 'vehicle' then
        updateVehicleStorage(source)
    end
end)

addEventHandler('onElementDestroy', root, function()
    if getElementType(source) == 'vehicle' then
        destroyVehicleStorage(source)
    end
end)

-- on resource stop
addEventHandler('onResourceStop', root, function(resource)
    local resourceName = getResourceName(resource)

    for model, storage in pairs(vehicleStorages) do
        if storage.parentName == resourceName then
            vehicleStorages[model] = nil
        end
    end
end)

-- use
function useStorageItem(hash, player, faction, storageModel, category, index)
    local storage = vehicleStorages[storageModel]
    if not storage then return end

    local data = storage.data
    local categoryData = data[tonumber(category) + 1]
    if not categoryData then return end

    local itemData = categoryData.items[tostring(index) + 1]
    if not itemData then return end

    if not playersStorageVehicles[player] then return end

    giveStorageItem(player, faction, hash, itemData, playersStorageVehicles[player])
end

function useStretcher(player, vehicle)
    exports['m-faction-ers']:useStretcher(player, vehicle)
end

function usePlank(player, vehicle)
    exports['m-faction-ers']:usePlank(player, vehicle)
end

function useR1Bag(player, vehicle)
    exports['m-faction-ers']:useR1Bag(player, vehicle)
end