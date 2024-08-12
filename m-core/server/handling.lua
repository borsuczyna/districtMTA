local updateElementDatas = {
    ['vehicle:engineCapacity'] = true,
}
local updateHandlingValues = {
    ['engineAcceleration'] = {
        base = {'dm', 1.2},
        multiplier = 0.3,
        maxMultiplier = 1.8
    },
    ['maxVelocity'] = {
        base = {'dm', 1.2},
        multiplier = 0.3,
        maxMultiplier = 1.8
    }
}

function updateVehicleHandling(vehicle)
    local dm = getElementData(vehicle, 'vehicle:engineCapacity')
    if not dm then return end

    local values = {
        dm = dm,
    }

    local model = getElementModel(vehicle)
    local handling = getOriginalHandling(model)

    for dataName, data in pairs(updateHandlingValues) do
        local diff = 1 - (data.base[2] - values[data.base[1]]) * data.multiplier
        diff = math.min(diff, data.maxMultiplier)
        
        setVehicleHandling(vehicle, dataName, handling[dataName] * diff)
    end
end

addEventHandler('onVehicleStartEnter', root, function(ped, seat, jacked)
    updateVehicleHandling(source)
end)

addEventHandler('onElementDataChange', root, function(dataName, oldValue)
    if getElementType(source) == 'vehicle' and updateElementDatas[dataName] then
        updateVehicleHandling(source)
    end
end)