function createPunishment(player, bannedBy, type_, time, timeUnit, reason, additionalInfo)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-logs']:log('Błąd połączenia z bazą danych', 'error')
        return
    end

    if type(bannedBy) ~= 'string' then
        bannedBy = getPlayerName(bannedBy)
    end

    local uid = getElementData(player, 'player:uid') or 0
    local serial = getPlayerSerial(player)
    local fingerprint = exports['m-anticheat']:getPlayerDecodedFingerprint(player)
    local ip = getPlayerIP(player)

    local seconds = time
    if timeUnit == 'm' then
        seconds = time * 60
    elseif timeUnit == 'h' then
        seconds = time * 60 * 60
    elseif timeUnit == 'd' then
        seconds = time * 60 * 60 * 24
    end

    dbExec(connection, [[INSERT INTO `m-punishments` (`user`, `serial`, `fingerprint`, `ip`, `type`, `permanent`, `end`, `admin`, `reason`, `additionalInfo`)
        VALUES (?, ?, ?, ?, ?, ?, NOW() + INTERVAL ? SECOND, ?, ?, ?)]],
        uid, serial, fingerprint, ip, type_, seconds == 0, seconds, bannedBy, reason, toJSON(additionalInfo))

    banPlayer(player, true, false, true, bannedBy, 'Połącz się ponownie, aby poznać szczegóły bana', 5)
end

function tempBan(player, bannedBy, time, timeUnit, discordReason, reason)
    if type(bannedBy) ~= 'string' then
        bannedBy = getPlayerName(bannedBy)
    end

    local message = ('Zbanowano `%s` na %d%s przez `%s`: `%s`'):format(getPlayerName(player), time, timeUnit, bannedBy, discordReason)
    exports['m-logs']:sendLog('bans', 'error', message)
    
    createPunishment(player, bannedBy, 'ban', time, timeUnit, reason or discordReason, {discordReason})
end

function permBan(player, bannedBy, discordReason, reason)
    if type(bannedBy) ~= 'string' then
        bannedBy = getPlayerName(bannedBy)
    end
    
    local message = ('Zbanowano `%s` na zawsze przez `%s`: `%s`'):format(getPlayerName(player), bannedBy, discordReason)
    exports['m-logs']:sendLog('bans', 'error', message)

    createPunishment(player, bannedBy, 'ban', 0, nil, reason or discordReason, {discordReason})
end

function isPlayerBanned(serial, fingerprint, ip)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-logs']:log('Błąd połączenia z bazą danych', 'error')
        return
    end

    local result = dbPoll(dbQuery(connection, [[SELECT * FROM `m-punishments` WHERE (`serial` = ? OR `fingerprint` = ? OR `ip` = ?) AND (`permanent` = 1 OR `end` > NOW())]], serial, fingerprint, ip), 10000)
    return #result > 0 and result[1] or false
end

function checkBan(player, serial, fingerprint, ip)
    local banned = isPlayerBanned(serial, fingerprint, ip)
    if not banned then return end

    if player then
        local message = ('\n-----------------------\n--\n-- Jesteś zbanowany na tym serwerze\n-- Powód: %s\n-- Banujący: %s\n-- Data zakończenia: %s\n--\n-----------------------\n'):format(banned.reason, banned.admin, (banned.permanent == 1 and 'Nigdy' or banned['end']))
        outputConsole(message, player)
        banPlayer(player, true, false, true, banned.admin, 'Jesteś zbanowany na tym serwerze, aby poznać powód bana, sprawdź konsolę', 5)
    end

    return true
end

addEventHandler('onPlayerConnect', root, function(nick, ip, username, serial, versionNumber, versionString)
    local player = getPlayerFromName(nick)
    local banned = checkBan(player, serial, nil, ip)
    if banned then
        cancelEvent(true, 'Zostałeś zbanowany na tym serwerze')
    end
end)