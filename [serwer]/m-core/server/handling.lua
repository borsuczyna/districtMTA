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
local mechanicTuning = {
    ['vehicle:mk1'] = {
        ['engineAcceleration'] = 1.2,
        ['maxVelocity'] = 1.2
    },
    ['vehicle:mk2'] = {
        ['engineAcceleration'] = 1.4,
        ['maxVelocity'] = 1.4
    },
    ['vehicle:mk3'] = {
        ['engineAcceleration'] = 1.6,
        ['maxVelocity'] = 1.6
    },
    ['vehicle:rwd'] = {
        ['driveType'] = 'awd',
    },
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
        
        -- setVehicleHandling(vehicle, dataName, handling[dataName] * diff)
        handling[dataName] = handling[dataName] * diff
    end

    -- foreach all mechanicTuning and check if vehicle has this eldata
    for elData, tuning in pairs(mechanicTuning) do
        if getElementData(vehicle, elData) then
            for dataName, value in pairs(tuning) do
                -- setVehicleHandling(vehicle, dataName, handling[dataName] * value)
                -- handling[dataName] = handling[dataName] * value

                if type(value) == 'string' then
                    handling[dataName] = value
                else
                    handling[dataName] = handling[dataName] * value
                end
            end
        end
    end

    -- apply new handling
    for dataName, value in pairs(handling) do
        setVehicleHandling(vehicle, dataName, value)
    end
end

addEventHandler('onVehicleStartEnter', root, function(ped, seat, jacked)
    updateVehicleHandling(source)
end)

addEventHandler('onElementDataChange', root, function(dataName, oldValue)
    if source and getElementType(source) == 'vehicle' and (updateElementDatas[dataName] or mechanicTuning[dataName]) then
        updateVehicleHandling(source)
    end
end)