addEvent('onAccountResponse', true)

function sendAccountResponse(hash, response)
    if client then return end
    triggerEvent('onAccountResponse', root, hash, response)
end

function encodePassword(password)
    return teaEncode(md5(password), 'm-core|' .. password .. '|hash')
end

function getPlayerNameByUid(uid)
    local player = getPlayerByUid(uid)
    if player then
        return getPlayerName(player)
    else
        local connection = exports['m-mysql']:getConnection()
        if not connection then return end

        local query = 'SELECT `username` FROM `m-users` WHERE `uid` = ?'
        local result = dbPoll(dbQuery(connection, query, uid), 5000)
        if not result then return end

        return result[1] and result[1].username
    end
end