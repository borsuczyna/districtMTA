function tempBan(player, bannedBy, time, timeUnit, discordReason, reason)
    if type(bannedBy) ~= 'string' then
        bannedBy = getPlayerName(bannedBy)
    end

    local message = ('Zbanowano `%s` na %d%s przez `%s`: `%s`'):format(getPlayerName(player), time, timeUnit, bannedBy, discordReason)
    exports['m-logs']:sendLog('bans', 'error', message)
    
    createPunishment(player, bannedBy, 'ban', time, timeUnit, reason or discordReason, {discordReason})
    banPlayer(player, true, false, true, bannedBy, 'Połącz się ponownie, aby poznać szczegóły bana', 5)
end

function permBan(player, bannedBy, discordReason, reason)
    if type(bannedBy) ~= 'string' then
        bannedBy = getPlayerName(bannedBy)
    end
    
    local message = ('Zbanowano `%s` na zawsze przez `%s`: `%s`'):format(getPlayerName(player), bannedBy, discordReason)
    exports['m-logs']:sendLog('bans', 'error', message)

    createPunishment(player, bannedBy, 'ban', 0, nil, reason or discordReason, {discordReason})
    banPlayer(player, true, false, true, bannedBy, 'Połącz się ponownie, aby poznać szczegóły bana', 5)
end

function isPlayerBanned(serial, ip)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-logs']:log('Błąd połączenia z bazą danych', 'error')
        return
    end

    local result = dbPoll(dbQuery(connection, [[SELECT * FROM `m-punishments` WHERE (`serial` = ? OR `ip` = ?) AND (`permanent` = 1 OR `end` > NOW()) AND `type`="ban" AND `active`=1]], serial, ip), 10000)
    return #result > 0 and result[1] or false
end

function checkBan(player, serial, ip)
    local banned = isPlayerBanned(serial, ip)
    if not banned then return end

    if player then
        local message = ('\n-----------------------\n--\n-- Jesteś zbanowany na tym serwerze\n-- Powód: %s\n-- Banujący: %s\n-- Data zakończenia: %s\n--\n-----------------------\n'):format(banned.reason, banned.admin, (banned.permanent == 1 and 'Nigdy' or banned['end']))
        outputConsole(message, player)
        banPlayer(player, true, false, true, banned.admin, 'Jesteś zbanowany na tym serwerze, aby poznać powód bana, sprawdź konsolę', 5)
    end

    return true
end

function unbanPlayer(admin, serial, ip)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-logs']:log('Błąd połączenia z bazą danych', 'error')
        return
    end

    if type(admin) ~= 'string' then
        admin = getPlayerName(admin)
    end

    local result = dbExec(connection, [[UPDATE `m-punishments` SET `active`=0 WHERE (`serial` = ? OR `ip` = ?) AND `type`="ban" AND `active`=1]], serial, ip)
    if not result then
        exports['m-logs']:log('Błąd podczas odbanowywania gracza', 'error')
        return
    end

    local message = ('Admin `%s` odbanował gracza o serialu `%s` oraz IP `%s`'):format(admin, serial or "-", ip or "-")
    exports['m-logs']:sendLog('bans', 'success', message)
    return true
end

addEventHandler('onPlayerConnect', root, function(nick, ip, username, serial, versionNumber, versionString)
    local player = getPlayerFromName(nick)
    local banned = checkBan(player, serial, nil, ip)
    if banned then
        cancelEvent(true, 'Zostałeś zbanowany na tym serwerze')
    end
end)