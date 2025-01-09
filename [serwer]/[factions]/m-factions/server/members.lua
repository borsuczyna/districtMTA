function editPlayerInFaction(player, faction, userID, rank)
    local hasPermission, message = doesPlayerHaveAnyFactionPermission(player, faction, {'editMember', 'manageFaction'})
    if not hasPermission then
        return false, message
    end

    local checkQuery = exports['m-mysql']:query('SELECT `user` FROM `m-factions-members` WHERE `faction` = ? AND `user` = ?', faction, userID)
    if not checkQuery or #checkQuery == 0 then
        return false, 'Gracz nie jest we frakcji'
    end

    local result = exports['m-mysql']:query('UPDATE `m-factions-members` SET `rank` = ? WHERE `faction` = ? AND `user` = ?', rank, faction, userID)
    
    if result then
        return true
    else
        return false, 'Wystąpił błąd podczas aktualizacji rangi gracza'
    end
end

function addPlayerToFaction(player, faction, userID, rank)
    local hasPermission, message = doesPlayerHaveAnyFactionPermission(player, faction, {'addMember', 'manageFaction'})
    if not hasPermission then
        return false, message
    end

    local checkQuery = exports['m-mysql']:query('SELECT `user` FROM `m-factions-members` WHERE `faction` = ? AND `user` = ?', faction, userID)
    if checkQuery and #checkQuery > 0 then
        return false, 'Gracz jest już we frakcji'
    end

    local result = exports['m-mysql']:query('INSERT INTO `m-factions-members` (`faction`, `user`, `rank`) VALUES (?, ?, ?)', faction, userID, rank)
    
    if result then
        return true
    else
        return false, 'Wystąpił błąd podczas dodawania gracza do frakcji'
    end
end

function removePlayerFromFaction(player, faction, userID)
    local hasPermission, message = doesPlayerHaveAnyFactionPermission(player, faction, {'removeMember', 'manageFaction'})
    if not hasPermission then
        return false, message
    end

    local checkQuery = exports['m-mysql']:query('SELECT `user` FROM `m-factions-members` WHERE `faction` = ? AND `user` = ?', faction, userID)
    if not checkQuery or #checkQuery == 0 then
        return false, 'Gracz nie jest we frakcji'
    end

    local result = exports['m-mysql']:query('DELETE FROM `m-factions-members` WHERE `faction` = ? AND `user` = ?', faction, userID)
    
    if result then
        return true
    else
        return false, 'Wystąpił błąd podczas usuwania gracza z frakcji'
    end
end

function getFactionMembers(faction)
    local queryResult = exports['m-mysql']:query([[ 
        SELECT m.user, m.rank, u.username AS playerName, r.name AS rankName 
        FROM `m-factions-members` m 
        LEFT JOIN `m-users` u ON u.uid = m.user 
        LEFT JOIN `m-factions-ranks` r ON r.uid = m.rank 
        WHERE m.faction = ? 
    ]], faction)
    
    local players = {}

    if queryResult and #queryResult > 0 then
        for _, row in ipairs(queryResult) do
            table.insert(players, {
                user = row.user,
                rank = row.rank,
                playerName = row.playerName,
                rankName = row.rankName
            })
        end
    end

    return players
end

function getPlayersDutyTime(faction)
    -- first, get all players from faction and left join with m-users.dutyTime and m-users.username
    local queryResult = exports['m-mysql']:query([[ 
        SELECT m.user, u.username AS playerName, u.dutyTime AS dutyTime, u.payDutyTime AS payTime, r.name AS rankName, m.rank AS rank
        FROM `m-factions-members` m 
        LEFT JOIN `m-users` u ON u.uid = m.user 
        LEFT JOIN `m-factions-ranks` r ON r.uid = m.rank 
        WHERE m.faction = ? 
    ]], faction)

    -- now, get all online players and their duty time
    local onlinePlayers = getElementsByType('player')
    local players = {}

    for _, row in ipairs(queryResult) do
        players[row.user] = {
            playerName = row.playerName,
            dutyTime = row.dutyTime,
            payTime = row.payTime,
            rank = row.rank,
            rankName = row.rankName,
            online = false
        }
    end

    for _, player in ipairs(onlinePlayers) do
        local userID = getElementData(player, 'player:uid')
        if userID and players[userID] then
            players[userID].online = true
            players[userID].dutyTime = getElementData(player, 'player:dutyTime')
            players[userID].payTime = getElementData(player, 'player:payDutyTime')
        end
    end

    local result = {}

    for userID, data in pairs(players) do
        table.insert(result, {
            user = userID,
            playerName = data.playerName,
            rank = data.rank,
            rankName = data.rankName,
            dutyTime = data.dutyTime,
            payTime = data.payTime,
            online = data.online
        })
    end

    return result
end