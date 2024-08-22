addEventHandler('onClientColShapeHit', resourceRoot, function(element)
    if element ~= localPlayer or not getElementData(source, 'scooter:rental') or getPedOccupiedVehicle(localPlayer) then return end
    setScooterUIVisible(true)
end)

addEventHandler('onClientColShapeLeave', resourceRoot, function(element)
    if element ~= localPlayer or not getElementData(source, 'scooter:rental') then return end
    setScooterUIVisible(false)
end)

local function toggleScooterFold()
    local rented = getElementData(localPlayer, 'scooter:rented')
    if not rented or not isElement(rented) then return end
    if not isPedOnGround(localPlayer) then return end

    if getElementType(rented) == 'object' then
        triggerServerEvent('scooter:fold', resourceRoot)
    elseif not getPedOccupiedVehicle(localPlayer) and getDistanceBetweenPoints3D(Vector3(getElementPosition(rented)), Vector3(getElementPosition(localPlayer))) < 2 then
        triggerServerEvent('scooter:fold', resourceRoot)
    end
end

bindKey('H', 'down', toggleScooterFold)
addEventHandler('controller:buttonPressed', root, function(button)
    if button == 2 then toggleScooterFold() end
    if button == 1 then toggleScooterJump('lctrl', 'down') end
end)

addEventHandler('controller:buttonReleased', root, function(button)
    if button == 1 then toggleScooterJump('lctrl', 'up') end
end)

addEventHandler('onClientVehicleStartEnter', root, function(player, seat)
	local rented = getElementData(localPlayer, 'scooter:rented')
    if not rented or not isElement(rented) then return end
    if getElementType(rented) == 'object' and player == localPlayer then return cancelEvent() end
end)