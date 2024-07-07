addEventHandler('onClientColShapeHit', resourceRoot, function(element)
    if element ~= localPlayer or not getElementData(source, 'scooter:rental') or getPedOccupiedVehicle(localPlayer) then return end
    setScooterUIVisible(true)
end)

addEventHandler('onClientColShapeLeave', resourceRoot, function(element)
    if element ~= localPlayer or not getElementData(source, 'scooter:rental') then return end
    setScooterUIVisible(false)
end)

bindKey('H', 'down', function()
    local rented = getElementData(localPlayer, 'scooter:rented')
    if not rented or not isElement(rented) then return end
    if not isPedOnGround(localPlayer) then return end

    if getElementType(rented) == 'object' then
        triggerServerEvent('scooter:fold', resourceRoot)
    elseif not getPedOccupiedVehicle(localPlayer) and getDistanceBetweenPoints3D(Vector3(getElementPosition(rented)), Vector3(getElementPosition(localPlayer))) < 2 then
        triggerServerEvent('scooter:fold', resourceRoot)
    end
end)

addEventHandler('onClientVehicleStartEnter', root, function(player, seat)
	local rented = getElementData(localPlayer, 'scooter:rented')
    if not rented or not isElement(rented) then return end
    if getElementType(rented) == 'object' and player == localPlayer then return cancelEvent() end
end)