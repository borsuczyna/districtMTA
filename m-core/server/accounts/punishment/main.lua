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
    local ip = getPlayerIP(player)

    local seconds = time
    if timeUnit == 'm' then
        seconds = time * 60
    elseif timeUnit == 'h' then
        seconds = time * 60 * 60
    elseif timeUnit == 'd' then
        seconds = time * 60 * 60 * 24
    end

    dbExec(connection, [[INSERT INTO `m-punishments` (`user`, `serial`, `ip`, `type`, `permanent`, `end`, `admin`, `reason`, `additionalInfo`)
        VALUES (?, ?, ?, ?, ?, NOW() + INTERVAL ? SECOND, ?, ?, ?)]],
        uid, serial, ip, type_, seconds == 0, seconds, bannedBy, reason, toJSON(additionalInfo))
end

function deletePunishment(player, type_)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-logs']:log('Błąd połączenia z bazą danych', 'error')
        return
    end

    local uid = getElementData(player, 'player:uid') or 0
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)

    dbExec(connection, [[UPDATE `m-punishments` SET `active` = 0 WHERE (`user` = ? OR `serial` = ? OR `ip` = ?) AND `type` = ? AND `active` = 1]],
        uid, serial, ip, type_)
end