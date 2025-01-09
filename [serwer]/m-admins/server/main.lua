local function dutyResponse(queryResult, player, serial, playerUID)
    local result = dbPoll(queryResult, 0)
    if #result == 0 or result[1].playerUid ~= playerUID then
        exports['m-notis']:addNotification(player, 'error', 'Służba administracyjna', 'Nie posiadasz uprawnień')
        return
    end

    if getElementData(player, 'player:rank') then
        if isPedWearingJetpack(player) then
            exports['m-notis']:addNotification(player, 'error', 'Służba administracyjna', 'Nie możesz się teraz wylogować ze służby')
            return
        end
        
        exports['m-notis']:addNotification(player, 'success', 'Służba administracyjna', 'Wylogowano ze służby administracyjnej')
        removeElementData(player, 'player:rank')
        takeWeapon(player, 22)

        unbindKey(player, 'y', 'down', 'chatbox', 'Admin')
    else
        exports['m-notis']:addNotification(player, 'success', 'Służba administracyjna', 'Zalogowano do służby administracyjnej')
        setElementData(player, 'player:rank', result[1].rank)
        giveWeapon(player, 22, 99999, true)

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

function getGroundPosition()
    local playerPos = Vector3(getElementPosition(localPlayer))
    local x, y, z = playerPos.x, playerPos.y, playerPos.z
    local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(x, y, z + 10, x, y, z - 10, true, false, false, true, false, true, false)
    
    if hit then
        return hitZ
    end
end