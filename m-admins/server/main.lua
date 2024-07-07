local function dutyResponse(queryResult, player, serial)
    local result = dbPoll(queryResult, 0)
    if #result == 0 then
        exports['m-notis']:addNotification(player, 'error', 'Służba administracyjna', 'Nie posiadasz uprawnień')
        return
    end

    if getElementData(player, 'player:rank') then
        exports['m-notis']:addNotification(player, 'success', 'Służba administracyjna', 'Wylogowano ze służby administracyjnej')
        removeElementData(player, 'player:rank')

        unbindKey(player, 'y', 'down', 'chatbox', 'Admin')
    else
        exports['m-notis']:addNotification(player, 'success', 'Służba administracyjna', 'Zalogowano do służby administracyjnej')
        setElementData(player, 'player:rank', result[1].rank)

        bindKey(player, 'y', 'down', 'chatbox', 'Admin')
    end

    triggerClientEvent(player, 'admin:toggleLogs', resourceRoot)
    triggerClientEvent(player, 'admin:toggleReports', resourceRoot)
end

addCommandHandler('duty', function(player)
    local serial = getPlayerSerial(player)

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(dutyResponse, {player, serial}, connection, 'SELECT * FROM `m-admins` WHERE serial = ?', serial)
end)