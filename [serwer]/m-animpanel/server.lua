local playingPlayersAnimations = {}

function stopAnimation(player)
    if playingPlayersAnimations[player] then
        for _, anim in ipairs(playingPlayersAnimations[player]) do
            setPedAnimation(player, nil)
        end

        playingPlayersAnimations[player] = nil
        unbindKey(player, 'space', 'down', stopAnimation)
    end
end

addEvent('animpanel:playAnimation', true)
addEventHandler('animpanel:playAnimation', resourceRoot, function(category, index)
    local animation = getAnimation(category, tonumber(index) + 1)
    if not animation then return end

    local arg = clone(animation)
    table.remove(arg, 1)

    local vehicle = getPedOccupiedVehicle(client)

    if vehicle then
        if category ~= 'Samochód' then
            return exports['m-notis']:addNotification(client, 'error', 'Animacje', 'Nie możesz użyć teraz tej animacji w pojeździe.')
        end
    end

    if vehicle and getVehicleType(vehicle) ~= 'Automobile' then
        return exports['m-notis']:addNotification(client, 'error', 'Animacje', 'Nie możesz użyć teraz tej animacji.')
    end

    if not playingPlayersAnimations[client] then
        playingPlayersAnimations[client] = {}
    end
    table.insert(playingPlayersAnimations[client], arg)

    setPedAnimation(client, arg[1], arg[2], arg[3] and arg[3] or -1, not arg[4], false, false, true)
    bindKey(client, 'space', 'down', stopAnimation, client)
end)