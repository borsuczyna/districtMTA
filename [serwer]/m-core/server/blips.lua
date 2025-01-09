local blips = {}

function createPlayerBlip(player)
    local blip = createBlipAttachedTo(player, 0, 2, 255, 255, 255, 255, 0, 9999)
    blips[player] = blip
end

function destroyPlayerBlip(player)
    if blips[player] and isElement(blips[player]) then
        destroyElement(blips[player])
        blips[player] = nil
    end
end

addEventHandler('onResourceStart', resourceRoot, function()
    for i, player in ipairs(getElementsByType('player')) do
        createPlayerBlip(player)
    end
end)

addEventHandler('onPlayerJoin', root, function()
    createPlayerBlip(source)
end)

addEventHandler('onPlayerQuit', root, function()
    destroyPlayerBlip(source)
end)