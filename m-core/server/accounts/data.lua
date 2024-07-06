function assignPlayerData(player, data)
    setElementData(player, 'player:logged', true)
    setElementData(player, 'player:uid', data.uid)
    setElementData(player, 'player:skin', data.skin)
    setElementData(player, 'player:level', data.level)
    setElementData(player, 'player:exp', data.exp)
    setElementData(player, 'player:premium-end', data.premiumEnd)
    setPlayerName(player, data.username)
    setElementModel(player, data.skin)
    setPlayerMoney(player, data.money)
    
    updatePlayerMute(player)
    updatePlayerLicense(player)

    toggleControl(player, 'fire', false)
    toggleControl(player, 'aim_weapon', false)

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'UPDATE `m-users` SET lastActive = NOW() WHERE uid = ?', data.uid)
end

function buildSavePlayerQuery(player)
    local uid = getElementData(player, 'player:uid')

    local skin = getElementData(player, 'player:skin')
    local money = getPlayerMoney(player)

    local saveData = {
        skin = skin,
        money = money,
        level = getElementData(player, 'player:level'),
        exp = getElementData(player, 'player:exp'),
    }

    local query = 'UPDATE `m-users` SET ' .. table.concat(mapk(saveData, function(value, key)
        return '`' .. key .. '` = ?'
    end), ', ') .. ' WHERE `uid` = ?'
    local values = mapk(saveData, function(value)
        return value
    end)
    table.insert(values, uid)

    return query, values, uid
end

function savePlayerData(player, noLogs)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query, values, uid = buildSavePlayerQuery(player)
    dbExec(connection, query, unpack(values))
end

function saveAllPlayers()
    local startTime = getTickCount()
    for i, player in ipairs(getElementsByType('player')) do
        savePlayerData(player, true)
    end

    exports['m-logs']:sendLog('accounts', 'info', 'Zapisano dane wszystkich graczy (' .. getTickCount() - startTime .. 'ms)')
end

addEventHandler('onPlayerQuit', root, function()
    savePlayerData(source)
end)

setTimer(saveAllPlayers, 300000, 0) -- 5 minutes