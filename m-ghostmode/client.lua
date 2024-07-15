-- function setGhostMode(player)
--     local vehicle = getPedOccupiedVehicle(player)

--     if vehicle then
--         local ghostmode = getElementData(vehicle, 'vehicle:ghostmode')

--         if ghostmode then
--             for _, vehicle in pairs(getElementsByType('vehicle')) do
--                 setElementCollidableWith(vehicle, player, false)
--             end
--         else
--             for _, vehicle in pairs(getElementsByType('vehicle')) do
--                 setElementCollidableWith(vehicle, player, true)
--             end
--         end
--     else
--         local ghostmode = getElementData(player, 'player:ghostmode')

--         if ghostmode then
--             for _, player in pairs(getElementsByType('player')) do
--                 setElementCollidableWith(player, localPlayer, false)
--             end
--         else
--             for _, player in pairs(getElementsByType('player')) do
--                 setElementCollidableWith(player, localPlayer, true)
--             end
--         end
--     end
-- end

-- addEvent('ghostmode:set', true)
-- addEventHandler('ghostmode:set', root, setGhostMode)

-- function onElementStreamIn()
--     local elementType = getElementType(source)

--     if elementType == 'vehicle' or elementType == 'player' then
--         local player = localPlayer
--         local vehicle = getPedOccupiedVehicle(player)

--         if vehicle then
--             setElementCollidableWith(source, vehicle, not isDisabled)
--         else
--             setElementCollidableWith(source, player, not isDisabled)
--         end
--     end
-- end

-- addEventHandler('onClientElementStreamIn', root, onElementStreamIn)