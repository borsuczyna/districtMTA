local goToPosition = false

function updateMovement()
    if not goToPosition then return end

    setElementRotation(localPlayer, 0, 0, goToPosition[4], 'default', true)

    if goToPosition[5] then return end

    local distance = getDistanceBetweenPoints2D(goToPosition[1], goToPosition[2], getElementPosition(localPlayer))
    if distance < 0.5 then
        setPedControlState(localPlayer, 'forwards', false)
        goToPosition[5] = true
    end
end

function goToPositionClick(button, state, x, y, wx, wy, wz, element)
    if button ~= 'left' or state ~= 'down' or not wx then return end

    local px, py, pz = getElementPosition(localPlayer)
    local rot = findRotation(px, py, wx, wy)
    setElementRotation(localPlayer, 0, 0, rot, 'default', true)
    setPedControlState(localPlayer, 'forwards', true)

    local hit, hx, hy, hz = processLineOfSight(px, py, pz, wx, wy, pz, true, false, false, true, false, false, false, false, localPlayer, true)

    goToPosition = {hx or wx, hy or wy, hz or wz, rot}
end