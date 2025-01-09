function getPlayerPermissions(player, faction)
    local playerUID = getElementData(player, 'player:uid')
    if not playerUID then return {} end

    local memberQuery = exports['m-mysql']:query('SELECT `rank` FROM `m-factions-members` WHERE `faction` = ? AND `user` = ?', faction, playerUID)
    if not memberQuery or #memberQuery == 0 then
        return {}
    end

    local playerRank = memberQuery[1].rank
    local rankQuery = exports['m-mysql']:query('SELECT `permissions` FROM `m-factions-ranks` WHERE `faction` = ? AND `uid` = ?', faction, playerRank)
    if not rankQuery or #rankQuery == 0 then
        return {}
    end

    return split(rankQuery[1].permissions, ',')
end

function doesPlayerHaveFactionPermission(player, faction, permission)
    local permissions = getPlayerPermissions(player, faction)

    if table.find(permissions, permission) then
        return true
    else
        return false, 'Nie posiadasz permisji'
    end
end

function doesPlayerHaveAnyFactionPermission(player, faction, permissions)
    local playerPermissions = getPlayerPermissions(player, faction)

    for i, permission in ipairs(permissions) do
        if table.find(playerPermissions, permission) then
            return true
        end
    end

    return false, 'Nie posiadasz żadnej z wymaganych permisji'
end

function getPlayerFaction(player)
    local playerUID = getElementData(player, 'player:uid')
    if not playerUID then return false end

    local memberQuery = exports['m-mysql']:query('SELECT `faction` FROM `m-factions-members` WHERE `user` = ?', playerUID)
    if not memberQuery or #memberQuery == 0 then
        return false
    end

    return memberQuery[1].faction
end