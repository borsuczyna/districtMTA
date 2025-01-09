addEvent('inv:elementCollision', true)
addEventHandler('inv:elementCollision', root, function(player, state)
    if player ~= localPlayer then
        setElementCollisionsEnabled(player, not state)
    end
end)