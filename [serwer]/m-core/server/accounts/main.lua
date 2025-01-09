addEvent('onAccountResponse', true)

local playerNameCache = {}

function sendAccountResponse(hash, response)
    if client then
        if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Trigger hack (**onAccountResponse**)')
    end
    triggerEvent('onAccountResponse', root, hash, response)
end

function encodePassword(password)
    return teaEncode(md5(password), 'm-core|' .. password .. '|hash')
end

function getPlayerNameByUid(uid)
    if playerNameCache[uid] and playerNameCache[uid].time + 10 * 60 * 1000 > getTickCount() then
        return playerNameCache[uid].name
    end

    local player = getPlayerByUid(uid)
    if player then
        local name = getPlayerName(player)
        playerNameCache[uid] = {name = name, time = getTickCount()}
        return name
    else
        local connection = exports['m-mysql']:getConnection()
        if not connection then return end

        local query = 'SELECT `username` FROM `m-users` WHERE `uid` = ?'
        local result = dbPoll(dbQuery(connection, query, uid), 5000)
        if not result then return end
        if #result == 0 then return end

        playerNameCache[uid] = {name = result[1].username, time = getTickCount()}
        return result[1] and result[1].username
    end
end