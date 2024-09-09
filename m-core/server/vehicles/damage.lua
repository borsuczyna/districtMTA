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

function respawnVehicleInner(source, panels, doors, lights, occupants)
    respawnVehicle(source)
    
    setVehicleWheelStates(source, 0, 0, 0, 0)

    for i = 0, 6 do
        setVehiclePanelState(source, i, panels[i + 1])
    end

    for i = 0, 5 do
        setVehicleDoorState(source, i, doors[i + 1])
    end

    for i = 0, 3 do
        setVehicleLightState(source, i, lights[i + 1])
    end

    for seat, occupantData in pairs(occupants) do
        local player = occupantData.player
        local position = occupantData.position
        local rotation = occupantData.rotation

        spawnPlayer(player, position.x, position.y, position.z, rotation)
        warpPedIntoVehicle(player, source, seat)
    end
end

addEventHandler('onVehicleExplode', root, function()
    local x, y, z = getElementPosition(source)
    local rx, ry, rz = getElementRotation(source)

    local panels = iter(0, 6, function(i)
        return getVehiclePanelState(source, i)
    end)
    local doors = iter(0, 5, function(i)
        return getVehicleDoorState(source, i)
    end)
    local lights = iter(0, 3, function(i)
        return getVehicleLightState(source, i)
    end)

    local occupants = {}

    for seat = 0, getVehicleMaxPassengers(source) do
        local player = getVehicleOccupant(source, seat)

        if player then
            local px, py, pz = getElementPosition(player)
            local playerPosition = { x = px, y = py, z = pz }
            local playerRotation = getPedRotation(player)

            occupants[seat] = { player = player, position = playerPosition, rotation = playerRotAtion }
        end
    end
    
    setVehicleRespawnPosition(source, x, y, z, rx, ry, rz)
    setTimer(respawnVehicleInner, 500, 1, source, panels, doors, lights, occupants)
end)

function iter(s, e, func)
    local t = {}
    for i = s, e do
        table.insert(t, func(i))
    end
    return t
end