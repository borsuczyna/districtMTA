addEventHandler('onVehicleDamage', root, function(loss)
    if not source or not isElement(source) or getElementType(source) ~= 'vehicle' then return end
    local health = getElementHealth(source)
    local matrix = getElementMatrix(source)
    local newHealth = health - loss

    if newHealth <= 315 then
        if matrix[3][3] < 0 then
            setElementHealth(source, 315)
        end
        
        if loss >= 100 then
            setVehicleEngineState(source, false)
        end

        setElementHealth(source, 315)
        cancelEvent()
    end
end)

function respawnVehicleInner(source, wheels, panels, doors, lights)
    respawnVehicle(source)

    for i = 0, 3 do
        setVehicleWheelStates(source, i, wheels[i + 1])
    end

    for i = 0, 6 do
        setVehiclePanelState(source, i, panels[i + 1])
    end

    for i = 0, 5 do
        setVehicleDoorState(source, i, doors[i + 1])
    end

    for i = 0, 3 do
        setVehicleLightState(source, i, lights[i + 1])
    end
end

addEventHandler('onVehicleExplode', root, function()
    local x, y, z = getElementPosition(source)
    local rx, ry, rz = getElementRotation(source)
    local wheels = {0, 0, 0, 0}
    local panels = iter(0, 6, function(i)
        return getVehiclePanelState(source, i)
    end)
    local doors = iter(0, 5, function(i)
        return getVehicleDoorState(source, i)
    end)
    local lights = iter(0, 3, function(i)
        return getVehicleLightState(source, i)
    end)

    setVehicleRespawnPosition(source, x, y, z, rx, ry, rz)
    setTimer(respawnVehicleInner, 500, 1, source, wheels, panels, doors, lights)
end)

function iter(s, e, func)
    local t = {}
    for i = s, e do
        table.insert(t, func(i))
    end
    return t
end