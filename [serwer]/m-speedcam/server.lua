local radars = {
    {1987.114, -1805.536, 13.547, 140, 70},
}

local function onSpeedCameraHit(hitElement, matchingDimension)
    if getElementType(hitElement) ~= 'vehicle' then return end
    local driver = getVehicleOccupant(hitElement)
    if not driver then return end

    local speed = math.floor(getElementSpeed(hitElement))
    local limit = getElementData(source, 'speedcamera:limit')
    if speed <= limit then return end

    -- outputChatBox('You were caught speeding! Your speed: ' .. speed .. ' km/h, limit: ' .. limit .. ' km/h', driver, 255, 0, 0)

    if not getElementData(hitElement, 'vehicle:uid') then 
        return 
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end
    local query = [[
        INSERT INTO `m-sapd-tickets` (`user`, `issuer`, `amount`, `reason`)
        VALUES (?, ?, ?, ?)
    ]]

    dbExec(connection, query, getElementData(driver, 'player:uid'), 0, 100, ('Przekroczenie prędkości o %d km/h pojazdem %s.'):format(speed - limit, exports['m-models']:getVehicleName(hitElement)))
    exports['m-notis']:addNotification(driver, 'warning', 'Mandat', ('Otrzymano mandat w wysokości $100 za przekroczenie prędkości o %d km/h'):format(speed - limit))
    setPlayerWantedLevel(driver, math.min(getPlayerWantedLevel(driver) + 1, 6))

    local x, y, z = getElementPosition(hitElement)
    triggerClientEvent('speedcam:playSound', resourceRoot, driver, x, y, z)
end

local function createSpeedCamera(data)
    local object = createObject(3798, data[1], data[2], data[3] - 1, 0, 0, data[4])
    setElementData(object, 'element:model', 'speedcamera')
    
    local cx, cy, cz = getPositionFromElementOffset(object, 0, 10, 0)
    local col = createColSphere(cx, cy, cz, 8)
    addEventHandler('onColShapeHit', col, onSpeedCameraHit)
    setElementData(col, 'speedcamera:limit', data[5], false)
end

addEventHandler('onResourceStart', resourceRoot, function()
    for i, data in ipairs(radars) do
        createSpeedCamera(data)
    end
end)

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function getElementSpeed(element)
    local x, y, z = getElementVelocity(element)
    return (x^2 + y^2 + z^2) ^ 0.5 * 180
end