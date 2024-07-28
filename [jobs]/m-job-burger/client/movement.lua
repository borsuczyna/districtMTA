goToPosition = false
goToAction = false

function tryAction()
    if not goToAction then return end

    local objectHash, clickTrigger = unpack(goToAction)
    if clickTrigger.type == 'server' then
        triggerServerEvent('jobs:burger:clickElement', resourceRoot, clickTrigger.event, objectHash)
    else
        triggerEvent('jobs:burger:clickElement', resourceRoot, clickTrigger.event, objectHash)
    end
end

function updateMovement()
    if not goToPosition then return end

    setElementRotation(localPlayer, 0, 0, goToPosition[4], 'default', true)

    if goToPosition[5] then return end

    local distance = getDistanceBetweenPoints2D(goToPosition[1], goToPosition[2], getElementPosition(localPlayer))
    if distance < 0.65 then
        setPedControlState(localPlayer, 'forwards', false)
        goToPosition[5] = true
        tryAction()
    end
end

function goToPositionClick(button, state, x, y, wx, wy, wz, element)
    if button ~= 'left' or state ~= 'down' or not wx then return end

    local px, py, pz = getElementPosition(localPlayer)
    setPedControlState(localPlayer, 'forwards', true)

    local hit, hx, hy, hz = processLineOfSight(px, py, pz, wx, wy, pz, true, false, false, true, false, false, false, false, localPlayer, true)
    local rot = findRotation(px, py, hx or wx, hy or wy)
    goToPosition = {hx or wx, hy or wy, hz or wz, rot}
    goToAction = false
end