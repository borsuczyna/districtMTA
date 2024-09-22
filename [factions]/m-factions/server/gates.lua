local gates = {}

local function toggleGateOpen(player, matchingDimension)
    if getElementType(player) ~= 'player' or not matchingDimension then return end

    local faction = getElementData(source, 'gate:faction')
    local access = doesPlayerHaveAnyFactionPermission(player, faction, {'gate', 'manageFaction'})
    if not access then return end

    local object = getElementData(source, 'gate:object')
    local state = getElementData(source, 'gate:state')
    if state == 2 then return end

    local position = getElementData(source, 'gate:position')
    local openBy = getElementData(source, 'gate:openBy')
    local x, y, z, rx, ry, rz = unpack(position)
    local tx, ty, tz = x + openBy[1], y + openBy[2], z + openBy[3]
    local time = getElementData(source, 'gate:time') or 1000
    local disableCollision = getElementData(source, 'gate:disableCollision')

    if state == 1 then
        moveObject(object, time, tx, ty, tz, openBy[4], openBy[5], openBy[6])
    else
        moveObject(object, time, x, y, z, -openBy[4], -openBy[5], -openBy[6])
    end

    if disableCollision then
        setElementCollisionsEnabled(object, false)
        setTimer(setElementCollisionsEnabled, time, 1, object, true)
    end

    setElementData(source, 'gate:state', 2)
    setTimer(setElementData, time, 1, source, 'gate:state', state == 1 and 3 or 1)
end

function createGate(faction, model, position, openBy, colShapeSize, time, disableCollision)
    local object = createObject(type(model) == 'string' and 1337 or model, position[1], position[2], position[3], position[4], position[5], position[6])
    local colShape = createColSphere(position[1], position[2], position[3], colShapeSize)
    
    addDestroyOnRestartElement(object, sourceResource)
    addDestroyOnRestartElement(colShape, sourceResource)

    setElementData(colShape, 'gate:faction', faction)
    setElementData(colShape, 'gate:object', object)
    setElementData(colShape, 'gate:position', position)
    setElementData(colShape, 'gate:openBy', openBy)
    setElementData(colShape, 'gate:time', time)
    setElementData(colShape, 'gate:disableCollision', disableCollision)
    setElementData(colShape, 'gate:state', 1)

    if type(model) == 'string' then
        setElementData(object, 'element:model', model)
    end

    addEventHandler('onColShapeHit', colShape, toggleGateOpen)
end