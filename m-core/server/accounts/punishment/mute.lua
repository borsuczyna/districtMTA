function mutePlayer(player, admin, timeValue, unit, discordReason, reason)
    if type(admin) ~= 'string' then
        admin = getPlayerName(admin)
    end

    local messageToPlayer = ('Zostałeś wyciszony na %d%s przez %s z powodu: %s'):format(timeValue, unit, admin, reason)
    createPunishment(player, admin, 'mute', timeValue, unit, reason or discordReason, {discordReason})
    updatePlayerMute(player)

    exports['m-notis']:addNotification(player, 'error', 'Wyciszenie', messageToPlayer)
end

function unmutePlayer(player, admin)
    if type(admin) ~= 'string' then
        admin = getPlayerName(admin)
    end

    local messageToPlayer = ('Zostałeś odciszony przez %s'):format(admin)
    deletePunishment(player, 'mute')
    updatePlayerMute(player)

    exports['m-notis']:addNotification(player, 'success', 'Odciszenie', messageToPlayer)
end

function getPlayerMute(player)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-logs']:log('Błąd połączenia z bazą danych', 'error')
        return
    end

    local uid = getElementData(player, 'player:uid') or 0
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)

    local result = dbPoll(dbQuery(connection, [[
        SELECT *, UNIX_TIMESTAMP(`end`) AS `end_timestamp`
        FROM `m-punishments`
        WHERE (`user` = ? OR `serial` = ? OR `ip` = ?)
        AND `type` = "mute"
        AND `end` > NOW()
        AND `active` = 1
    ]], uid, serial, ip), 10000)

    return #result > 0 and result[1] or false
end

function updatePlayerMute(player)
    local isMuted = getPlayerMute(player)
    if not isMuted then
        removeElementData(player, 'player:mute')
        return
    end

    setElementData(player, 'player:mute', isMuted['end_timestamp'])
    setElementData(player, 'player:muteAdmin', isMuted['admin'])
    setElementData(player, 'player:muteReason', isMuted['reason'])
end

function isPlayerMuted(player)
    local mute = getElementData(player, 'player:mute')
    if not mute then
        return false
    end

    if getRealTime().timestamp >= tonumber(mute) then
        removeElementData(player, 'player:mute')
        return false
    end

    local timeLeft = mute - getRealTime().timestamp
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

    return table.concat(timeStr, ', '), getElementData(player, 'player:muteAdmin'), getElementData(player, 'player:muteReason')
end