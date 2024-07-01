local function dutyResponse(queryResult, player, serial, fingerprint)
    local result = dbPoll(queryResult, 0)
    if #result == 0 then
        exports['m-notis']:addNotification(player, 'error', 'Służba administracyjna', 'Nie posiadasz uprawnień')
        return
    end

    if fingerprint ~= result[1].fingerprint then
        local message = ('Probably serial changer (invalid fingerprint): %s, %s, %s'):format(getPlayerName(player), serial, fingerprint)
        setPlayerTriggerLocked(player, true, message)

        exports['m-notis']:addNotification(player, 'error', 'Służba administracyjna', 'Nie posiadasz uprawnień')
        return
    end

    if getElementData(player, 'player:rank') then
        exports['m-notis']:addNotification(player, 'success', 'Służba administracyjna', 'Wylogowano ze służby administracyjnej')
        removeElementData(player, 'player:rank')
    else
        exports['m-notis']:addNotification(player, 'success', 'Służba administracyjna', 'Zalogowano do służby administracyjnej')
        setElementData(player, 'player:rank', result[1].rank)
    end
end

addCommandHandler('duty', function(player)
    local serial = getPlayerSerial(player)
    local fingerprint = exports['m-anticheat']:getPlayerFingerprint(player)
    if not fingerprint then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(dutyResponse, {player, serial, fingerprint}, connection, 'SELECT * FROM `m-admins` WHERE serial = ? OR fingerprint = ?', serial, fingerprint)
end)