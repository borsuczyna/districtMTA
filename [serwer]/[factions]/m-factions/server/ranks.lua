function setPlayerRank(faction, userID, rank)
    local result = exports['m-mysql']:query('UPDATE `m-factions-members` SET `rank` = ? WHERE `faction` = ? AND `user` = ?', rank, faction, userID)
    
    if result and #result == 0 then
        result = exports['m-mysql']:query('INSERT INTO `m-factions-members` (`faction`, `user`, `rank`) VALUES (?, ?, ?)', faction, userID, rank)
    end

    return result
end

function getFactionRanks(faction)
    local queryResult = exports['m-mysql']:query('SELECT `uid`, `name`, `permissions` FROM `m-factions-ranks` WHERE `faction` = ?', faction)
    return queryResult
end

function addFactionRank(player, faction, rankName, permissions)
    local hasPermission, message = doesPlayerHaveAnyFactionPermission(player, faction, {'manageRanks', 'manageFaction'})
    if not hasPermission then
        return false, message
    end

    local checkQuery = exports['m-mysql']:query('SELECT `name` FROM `m-factions-ranks` WHERE `faction` = ? AND `name` = ?', faction, rankName)
    if checkQuery and #checkQuery > 0 then
        return false, 'Ranga o takiej nazwie już istnieje'
    end

    local result = exports['m-mysql']:query('INSERT INTO `m-factions-ranks` (`faction`, `name`, `permissions`) VALUES (?, ?, ?)', faction, rankName, permissions)
    
    if result then
        return true
    else
        return false, 'Wystąpił błąd podczas dodawania rangi'
    end
end

function removeFactionRank(player, faction, rankID)
    local hasPermission, message = doesPlayerHaveAnyFactionPermission(player, faction, {'manageRanks', 'manageFaction'})
    if not hasPermission then
        return false, message
    end

    local ranks = getFactionRanks(faction)
    if #ranks == 1 then
        return false, 'Nie można usunąć ostatniej rangi'
    end

    local result = exports['m-mysql']:query('DELETE FROM `m-factions-ranks` WHERE `uid` = ? AND `faction` = ?', rankID, faction)
    
    if result then
        local ranks = getFactionRanks(faction)
        exports['m-mysql']:query('UPDATE `m-factions-members` SET `rank` = ? WHERE `rank` = ? AND `faction` = ?', ranks[1].uid, rankID, faction)

        return true, ranks
    else
        return false, 'Wystąpił błąd podczas usuwania rangi'
    end
end

function editFactionRank(player, faction, rankID, rankName, permissions)
    local hasPermission, message = doesPlayerHaveAnyFactionPermission(player, faction, {'manageRanks', 'manageFaction'})
    if not hasPermission then
        return false, message
    end

    local checkQuery = exports['m-mysql']:query('SELECT `name` FROM `m-factions-ranks` WHERE `faction` = ? AND `name` = ? AND `uid` != ?', faction, rankName, rankID)
    if checkQuery and #checkQuery > 0 then
        return false, 'Ranga o takiej nazwie już istnieje'
    end

    local result = exports['m-mysql']:query('UPDATE `m-factions-ranks` SET `name` = ?, `permissions` = ? WHERE `uid` = ? AND `faction` = ?', rankName, permissions, rankID, faction)
    
    if result then
        return true
    else
        return false, 'Wystąpił błąd podczas edytowania rangi'
    end
end