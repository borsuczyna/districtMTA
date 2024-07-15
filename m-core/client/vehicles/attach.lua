addEventHandler('onClientRender', root, function()
    local players = getElementsByType('player', root, true)

    for _, player in ipairs(players) do
        local vehicle = getElementData(player, 'player:attachedVehicle')
        if not vehicle or not isElement(vehicle) then return end

        local rot = getElementData(player, 'player:attachedVehicleRot')
        local rx, ry, rz = getElementRotation(vehicle)
        local prx, pry, prz = getElementRotation(player)

        setElementRotation(player, rx, ry, rz + rot)
    end
end)