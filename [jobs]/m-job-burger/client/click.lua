addEvent('jobs:burger:clickElement')

function onClickObjectInteraction(button, state, x, y, wx, wy, wz, element)
    if not canMove then return end
    if button ~= 'left' or state ~= 'down' or not element then return end

    local objectHash = exports['m-jobs']:getObjectHash(element)
    if not objectHash then return end

    local clickTrigger = exports['m-jobs']:getLobbyObjectCustomData(objectHash, 'clickTrigger')
    if not clickTrigger then return end

    local px, py, pz = getElementPosition(localPlayer)
    local x, y, z = getElementPosition(element)
    local hit, hx, hy, hz = processLineOfSight(px, py, pz, x, y, z, true, false, false, true, false, false, false, false, localPlayer, true)
    local rot = findRotation(px, py, x, y)
    setGoToPosition(hx or x, hy or y, hz or z, rot)
    goToAction = {objectHash, clickTrigger}
end

addEventHandler('jobs:burger:clickElement', resourceRoot, function(event, objectHash)
    
end)