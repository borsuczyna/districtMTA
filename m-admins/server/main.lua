local function dutyResponse(queryResult, player, serial, playerUID)
    local result = dbPoll(queryResult, 0)
    if #result == 0 or result[1].playerUid ~= playerUID then
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

function getActiveAdminsWithRank(rank)
    local admins = {}

    for i, player in ipairs(getElementsByType('player')) do
        if getElementData(player, 'player:rank') == rank then
            table.insert(admins, player)
        end
    end

    return admins
end

addCommandHandler('duty', function(player)
    local serial = getPlayerSerial(player)
    local playerUID = getElementData(player, 'player:uid')

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(dutyResponse, {player, serial, playerUID}, connection, 'SELECT * FROM `m-admins` WHERE serial = ? AND playerUid = ?', serial, playerUID)
end)