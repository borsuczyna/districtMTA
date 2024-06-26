function assignPlayerData(player, data)
    setElementData(player, 'player:logged', true)
    setElementData(player, 'player:uid', data.uid)

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'UPDATE `m-users` SET lastActive = NOW() WHERE uid = ?', data.uid)
end

function savePlayerData(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local skin = getElementModel(player)
    local money = getPlayerMoney(player)

    dbQuery(function(qh)
        local result, modifiedRows = dbPoll(qh, 0)
        if not result then return end

        if modifiedRows == 0 then
            exports['m-logs']:sendLog('accounts', 'info', 'Nie było nic do zapisania dla gracza ' .. getPlayerName(player))
        else
            exports['m-logs']:sendLog('accounts', 'success', 'Zapisano dane gracza ' .. getPlayerName(player))
        end
    end, connection, 'UPDATE `m-users` SET skin = ?, money = ? WHERE uid = ?', skin, money, uid)
end

function saveAllPlayers()
    for i, player in ipairs(getElementsByType('player')) do
        savePlayerData(player)
    end

    exports['m-logs']:sendLog('accounts', 'info', 'Zapisano dane wszystkich graczy')
end

setTimer(saveAllPlayers, 300000, 0) -- 5 minutes