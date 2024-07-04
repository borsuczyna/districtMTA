function removeLicense(player, admin, timeValue, unit, discordReason, reason)
    if type(admin) ~= 'string' then
        admin = getPlayerName(admin)
    end

    local vehicle = getPedOccupiedVehicle(player)
    local seat = getPedOccupiedVehicleSeat(player)

    if vehicle and seat == 0 then
        removePedFromVehicle(player)
    end
    
    local messageToPlayer = ('Twoje prawo jazdy zostało zabrane na %d%s przez %s z powodu: %s'):format(timeValue, unit, admin, reason)
    createPunishment(player, admin, 'license', timeValue, unit, reason or discordReason, {discordReason})

    exports['m-notis']:addNotification(player, 'error', 'Prawo jazdy', messageToPlayer)
end

function getPlayerLicense(player)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-logs']:log('Błąd połączenia z bazą danych', 'error')
        return
    end

    local uid = getElementData(player, 'player:uid') or 0
    local serial = getPlayerSerial(player)
    local fingerprint = exports['m-anticheat']:getPlayerDecodedFingerprint(player)
    local ip = getPlayerIP(player)

    local result = dbPoll(dbQuery(connection, [[
        SELECT *, UNIX_TIMESTAMP(`end`) AS `end_timestamp`
        FROM `m-punishments`
        WHERE (`user` = ? OR `serial` = ? OR `fingerprint` = ? OR `ip` = ?)
        AND `type` = "license"
        AND `end` > NOW()
        AND `active` = 1
    ]], uid, serial, fingerprint, ip), 10000)

    return #result > 0 and result[1] or false
end

function isPlayerHaveLicense(player)
    local license = getPlayerLicense(player)
    if not license then
        return
    end

    if getRealTime().timestamp >= license['end_timestamp'] then
        return true
    end

    local timeLeft = license['end_timestamp'] - getRealTime().timestamp
    local time = {}

    time.d = math.floor(timeLeft / 86400)
    timeLeft = timeLeft - time.d * 86400

    time.h = math.floor(timeLeft / 3600)
    timeLeft = timeLeft - time.h * 3600

    time.m = math.floor(timeLeft / 60)
    timeLeft = timeLeft - time.m * 60

    time.s = timeLeft

    local timeStr = {}
    if time.d > 0 then
        table.insert(timeStr, ('%d dni'):format(time.d))
    end

    if time.h > 0 then
        table.insert(timeStr, ('%d godzin'):format(time.h))
    end

    if time.m > 0 then
        table.insert(timeStr, ('%d minut'):format(time.m))
    end

    if time.s > 0 then
        table.insert(timeStr, ('%d sekund'):format(time.s))
    end

    return table.concat(timeStr, ', '), license['admin'], license['reason']
end