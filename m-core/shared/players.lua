function getPlayerFromPartialName(name)
    local players = getElementsByType('player')
    for i, player in ipairs(players) do
        local name = removeHex(getPlayerName(player)):lower()
        if name:find(name) then
            return player
        end

        local id = getElementData(player, 'player:id')
        if tonumber(name) == id then
            return player
        end
    end

    return false
end

function getPlayerById(id)
    return isElement(ids[id]) and ids[id] or false
end

function getPlayerByUid(uid)
    if not uid then return false end
    
    local players = getElementsByType('player')
    for i, player in ipairs(players) do
        if getElementData(player, 'player:uid') == uid then
            return player
        end
    end

    return false
end