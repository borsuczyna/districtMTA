function getVehicleRPM(vehicle)
    if not vehicle then return 0 end
    if not getVehicleEngineState(vehicle) then return 0 end

    local speed = getVehicleSpeed(vehicle)
    local gear = getVehicleCurrentGear(vehicle)
    local driver = getVehicleOccupant(vehicle, 0)

    if driver and speed < 2 and getPedControlState(driver, 'accelerate') and getPedControlState(driver, 'brake_reverse') then
        return math.random(8000, 9500)
    end

    if gear == 0 then
        local rpm = math.floor(speed * 160 + 0.5)
        if rpm < 650 then
            return math.random(650, 750)
        elseif rpm >= 9000 then
            return math.random(9000, 9900)
        end
    end

    local rpm = math.floor((speed / gear) * 160 + 0.5)
    if rpm < 650 then
        return math.random(650, 750)
    elseif rpm >= 9000 then
        return math.random(9000, 9900)
    end

    return rpm
end

function getVehicleSpeed(vehicle)
    local vx, vy, vz = getElementVelocity(vehicle)
    return math.sqrt(vx^2 + vy^2 + vz^2) * 180
end