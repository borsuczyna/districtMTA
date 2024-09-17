local time = getTickCount()
local blockedVehicles = {
    509, 481, 510
}

function changeFuel(vehicle)
    if not getVehicleEngineState(vehicle) then return end
    
    local model = getElementModel(vehicle)
    if model and table.find(blockedVehicles, model) then return end

    local uid = getElementData(vehicle, 'vehicle:uid')
    local vx, vy, vz = getElementVelocity(vehicle)
    local speed = ((vx ^ 2 + vy ^ 2 + vz ^ 2) ^ (0.5)) * 180

    if uid then
        local fuel = getElementData(vehicle, 'vehicle:fuel') or 100
        local lpgFuel = getElementData(vehicle, 'vehicle:lpgFuel') or 100
        local lpgState = getElementData(vehicle, 'vehicle:lpgState')

        if lpgState then
            if lpgFuel <= 0 then
                setVehicleEngineState(vehicle, false)
            end

            lpgFuel = lpgFuel - speed / 18000
            lpgFuel = math.max(lpgFuel, 0)
            setElementData(vehicle, 'vehicle:lpgFuel', lpgFuel)
        else
            if fuel <= 0 then
                setVehicleEngineState(vehicle, false)
            end

            fuel = fuel - speed / 18000
            fuel = math.max(fuel, 0)
            setElementData(vehicle, 'vehicle:fuel', fuel)
        end
    end

    local mileage = getElementData(vehicle, 'vehicle:mileage') or 0
    mileage = mileage + speed / 5000
    
    setElementData(vehicle, 'vehicle:mileage', mileage)
end

function updateFuel()
    for i, vehicle in pairs(getElementsByType('vehicle')) do
        changeFuel(vehicle)
    end
end

setTimer(updateFuel, 500, 0)