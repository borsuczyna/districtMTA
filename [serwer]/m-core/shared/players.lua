function getPlayerFromPartialName(searchName)
    if not searchName or #searchName < 1 then return false end

    local players = getElementsByType('player')
    for i, player in ipairs(players) do
        local id = getElementData(player, 'player:id')
        if id and tonumber(searchName) == id then
            return player
        end

        local name = removeHex(getPlayerName(player)):lower()
        if name:find(searchName) then
            return player
        end
    end

    return false
end

function getPlayerById(id)
    for i, player in ipairs(getElementsByType('player')) do
        if getElementData(player, 'player:id') == id then
            return player
        end
    end
end

function getPlayerByUid(uid)
    if not uid then return false end
    uid = tonumber(uid)
    
    local players = getElementsByType('player')
    for i, player in ipairs(players) do
        if getElementData(player, 'player:uid') == uid then
            return player
        end
    end

    return false
end