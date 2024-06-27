local ids = {}

function findFreeId()
    local id = 1
    while getPlayerById(id) do
        id = id + 1
    end
    return id
end

function assignPlayerId()
    local id = findFreeId()
    ids[id] = source
    setElementData(source, 'player:id', id)
end

function getPlayerId(player)
    return getElementData(player, 'player:id')
end

function removePlayerId()
    local id = getElementData(source, 'player:id')
    ids[id] = nil
end

addEventHandler('onPlayerJoin', root, assignPlayerId)
addEventHandler('onPlayerQuit', root, removePlayerId)

addEventHandler('onResourceStart', resourceRoot, function()
    local players = getElementsByType('player')
    for i, player in ipairs(players) do
        if not getPlayerId(player) then
            assignPlayerId(player)
        end
    end
end)