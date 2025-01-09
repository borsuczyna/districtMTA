canMove = true
goToPosition = false
goToAction = false

function clampMovePosition(x, y, z)
    local jobBounds = settings.getJobBounds()
    x = math.max(jobBounds.x[1], math.min(jobBounds.x[2], x))
    y = math.max(jobBounds.y[1], math.min(jobBounds.y[2], y))

    return x, y, z
end

function tryAction()
    if not goToAction then return end

    local objectHash, clickTrigger = unpack(goToAction)
    if clickTrigger.type == 'server' then
        triggerServerEvent('jobs:burger:clickElement', resourceRoot, clickTrigger.event, objectHash)
    else
        triggerEvent('jobs:burger:clickElement', resourceRoot, clickTrigger.event, objectHash)
    end
end

function setGoToPosition(x, y, z, rot, action)
    x, y, z = clampMovePosition(x, y, z)
    goToPosition = {x, y, z, rot, false}
    goToAction = action
end

function toggleMovement(state)
    canMove = state
    if not state then
        setPedControlState(localPlayer, 'forwards', false)
        setPedControlState(localPlayer, 'sprint', false)
        goToPosition = false
    end
end

function drawBoundLines()
    local jobBounds = settings.getJobBounds()
    local _, _, z = getElementPosition(localPlayer)
    local x1, y1, z1 = jobBounds.x[1], jobBounds.y[1], z
    local x2, y2, z2 = jobBounds.x[2], jobBounds.y[2], z

    dxDrawLine3D(x1, y1, z1, x2, y1, z1, tocolor(255, 0, 0), 1)
    dxDrawLine3D(x2, y1, z1, x2, y2, z1, tocolor(255, 0, 0), 1)
    dxDrawLine3D(x2, y2, z1, x1, y2, z1, tocolor(255, 0, 0), 1)
    dxDrawLine3D(x1, y2, z1, x1, y1, z1, tocolor(255, 0, 0), 1)
end

function updateMovement()
    -- drawBoundLines()
    if not goToPosition then return end

    local distance = getDistanceBetweenPoints2D(goToPosition[1], goToPosition[2], getElementPosition(localPlayer))
    setElementRotation(localPlayer, 0, 0, goToPosition[4], 'default', true)

    -- dxDrawLine3D(goToPosition[1], goToPosition[2], goToPosition[3], goToPosition[1], goToPosition[2], goToPosition[3] + 1, tocolor(255, 0, 0), 1)
    if goToPosition[5] then return end

    if distance < 0.3 then
        setPedControlState(localPlayer, 'forwards', false)
        setPedControlState(localPlayer, 'sprint', false)
        goToPosition[5] = true
        tryAction()
    else
        local x, y, z = getElementPosition(localPlayer)
        local rotation = findRotation(x, y, goToPosition[1], goToPosition[2])
        goToPosition[4] = rotation
    end
end

function goToPositionClick(button, state, x, y, wx, wy, wz, element)
    if not canMove then return end
    if button ~= 'left' or state ~= 'down' or not wx then return end

    local px, py, pz = getElementPosition(localPlayer)
    local upgrades = getElementData(localPlayer, 'player:job-upgrades-cache')

    setPedControlState(localPlayer, 'sprint', not not table.find(upgrades, 'sprinter'))
    setPedControlState(localPlayer, 'forwards', true)

    local hit, hx, hy, hz = processLineOfSight(px, py, pz, wx, wy, pz, true, false, false, true, false, false, false, false, localPlayer, true)
    local rot = findRotation(px, py, hx or wx, hy or wy)
    -- goToPosition = {hx or wx, hy or wy, hz or wz, rot}
    setGoToPosition(hx or wx, hy or wy, hz or wz, rot)
    goToAction = false
end