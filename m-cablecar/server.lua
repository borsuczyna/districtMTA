function createCableCar(data)
    local newPos = data.start + cableCarOffset
    local cableCar = createObject(1337, newPos)
    setElementData(cableCar, 'element:model', 'cablecar')
    setElementData(cableCar, 'ride:volume', 0)
    assignLOD(cableCar)
    
    local railway = createObject(1337, newPos)
    setElementData(railway, 'element:model', 'cablecar-rail')
    assignLOD(railway)

    data.state = 'waiting'
    data.time = getTickCount()
    data.position = false -- false - start, true - finish
    data.objects = {
        car = cableCar,
        doors = {}
    }

    local function createDoor(doorData)
        local door = createObject(1337, Vector3(0, 0, 0))
        setElementData(door, 'element:model', 'cablecar-door')
        attachElements(door, cableCar, doorData[1], doorData.rotation)
        assignLOD(door)

        table.insert(data.objects.doors, {
            object = door,
            data = doorData
        })
    end

    for i, data in ipairs(doorsPositions) do
        createDoor(data)
    end

    local rotation = findRotation3D(data.start, data.finish)
    attachElements(railway, cableCar, 0, 0, 1.58, rotation.x, 0, 0)
    rotation.y = 0
    rotation.x = 0
    setElementRotation(cableCar, rotation)
end

function createCableCars()
    for i, way in ipairs(cableCars) do
        createCableCar(way)
    end
end

function playDoorAnimation(cableCar, door, positionId, currentPosition, time)
    local rx, ry, rz = getElementRotation(cableCar.objects.car)
    local position = door.data[positionId]
    local currentPos = Vector3(getElementPosition(door.object))

    detachElements(door.object)
    setElementPosition(door.object, currentPos)
    setElementRotation(door.object, Vector3(rx, ry, rz) + door.data.rotation)

    local x, y, z = getPositionFromElementOffset(cableCar.objects.car, position.x, position.y, position.z)
    setTimer(moveObject, 0, 1, door.object, time or 1000, x, y, z)
    
    if position then
        local rotation = door.data.rotation
        setTimer(attachElements, time or 1000, 1, door.object, cableCar.objects.car, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z)
    else
        print('Error: door position not found for id ' .. positionId)
    end
end

function moveCableCar(cableCar)
    local nextPosition = cableCar.position and cableCar.start or cableCar.finish
    local currentPos = Vector3(getElementPosition(cableCar.objects.car))
    local distance = getDistanceBetweenPoints3D(currentPos, nextPosition)
    local time = distance * 200

    nextPosition = nextPosition + cableCarOffset
    moveObject(cableCar.objects.car, time, nextPosition.x, nextPosition.y, nextPosition.z)
    setElementData(cableCar.objects.car, 'ride:volume', 2)
    setTimer(setElementData, time, 1, cableCar.objects.car, 'ride:volume', 0)

    cableCar.state = 'moving'
    cableCar.time = getTickCount() + time
    cableCar.position = not cableCar.position
end

function updateCableCar(cableCar)
    if cableCar.state == 'waiting' then
        if getTickCount() - cableCar.time > 10000 then
            cableCar.state = 'closing-doors'
            cableCar.time = getTickCount()
            
            local x, y, z = getElementPosition(cableCar.objects.car)
            local closePlayers = getElementsWithinRange(x, y, z, 30, 'player')
            triggerClientEvent(closePlayers, 'cablecar:playDoorSound', resourceRoot, x, y, z)

            for i, door in ipairs(cableCar.objects.doors) do
                playDoorAnimation(cableCar, door, 2, 1)
                setTimer(playDoorAnimation, 1000, 1, cableCar, door, 3, 2, 500)
                setTimer(function()
                    cableCar.state = 'waiting-to-move'
                    cableCar.time = getTickCount()
                end, 1500, 1)
            end
        end
    elseif cableCar.state == 'waiting-to-move' then
        if getTickCount() - cableCar.time > 1000 then
            moveCableCar(cableCar, 1)
        end
    elseif cableCar.state == 'moving' then
        if getTickCount() - cableCar.time > 0 then
            cableCar.state = 'opening-doors'
            cableCar.time = getTickCount()

            local x, y, z = getElementPosition(cableCar.objects.car)
            local openPlayers = getElementsWithinRange(x, y, z, 30, 'player')
            triggerClientEvent(openPlayers, 'cablecar:playDoorSound', resourceRoot, x, y, z)
            
            for i, door in ipairs(cableCar.objects.doors) do
                playDoorAnimation(cableCar, door, 2, 3)
                setTimer(playDoorAnimation, 1000, 1, cableCar, door, 1, 2, 500)
                setTimer(function()
                    cableCar.state = 'waiting'
                    cableCar.time = getTickCount()
                    cableCar.position = not cableCar.position
                end, 1500, 1)
            end
        end
    end
end

function updateCableCars()
    for i, way in ipairs(cableCars) do
        updateCableCar(way)
    end
end

addEventHandler('onResourceStart', resourceRoot, createCableCars)
setTimer(updateCableCars, 1000, 0)