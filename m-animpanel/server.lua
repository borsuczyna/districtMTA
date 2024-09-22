local playingPlayersAnimations = {}

function stopAnimation(player)
    if playingPlayersAnimations[player] then
        for _, anim in ipairs(playingPlayersAnimations[player]) do
            setPedAnimation(player, nil)
        end

        playingPlayersAnimations[player] = nil
        unbindKey(player, 'enter', 'down', stopAnimation)
    end
end

addEvent('animpanel:playAnimation', true)
addEventHandler('animpanel:playAnimation', resourceRoot, function(category, index)
    local animation = getAnimation(category, tonumber(index) + 1)
    if not animation then return end

    local arg = clone(animation)
    table.remove(arg, 1)

    if category ~= 'Samochód' and getPedOccupiedVehicle(client) then
        exports['m-notis']:addNotification(client, 'error', 'Animacje', 'Nie możesz użyć tej animacji będąc w pojeździe.')
        return
    elseif category == 'Samochód' and not getPedOccupiedVehicle(client) then
        exports['m-notis']:addNotification(client, 'error', 'Animacje', 'Nie możesz użyć tej animacji nie będąc w pojeździe.')
        return
    end

    if not playingPlayersAnimations[client] then
        playingPlayersAnimations[client] = {}
    end
    table.insert(playingPlayersAnimations[client], arg)

    setPedAnimation(client, arg[1], arg[2], arg[3] and arg[3] or -1, not arg[4], false, false, true)
    bindKey(client, 'enter', 'down', stopAnimation, client)
end)