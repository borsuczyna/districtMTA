USER_LOG = {
    ACCOUNT = 1,
    VEHICLES = 2,
    ADMIN = 3
}

function addUserLog(player, type, message, details)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local logType = getLogType(type)
    if not logType then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'INSERT INTO `m-users-logs` (`player`, `type`, `log`, `details`) VALUES (?, ?, ?, ?)', uid, logType, message, details)
end

function addMoneyLog(player, type, details, amount)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    addMoneyLogByUid(uid, type, details, amount)
end

function addMoneyLogByUid(uid, type, details, amount)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    if type ~= 'job' then
        dbExec(connection, 'INSERT INTO `m-money-logs` (`player`, `type`, `details`, `money`) VALUES (?, ?, ?, ?)', uid, type, details, amount)
    else
        -- it can stack, get last log and if it's the same type, just update it
        dbQuery(function(qh)
            local result = dbPoll(qh, 0)
            if result and #result > 0 then
                local lastLog = result[1]
                if lastLog then
                    if lastLog['type'] == type then
                        dbExec(connection, 'UPDATE `m-money-logs` SET `money` = `money` + ? WHERE `uid` = ?', amount, lastLog.uid)
                        return
                    end
                end
            end

            dbExec(connection, 'INSERT INTO `m-money-logs` (`player`, `type`, `details`, `money`) VALUES (?, ?, ?, ?)', uid, type, details, amount)
        end, connection, 'SELECT * FROM `m-money-logs` WHERE `player` = ? ORDER BY `uid` DESC LIMIT 1', uid)
    end
end

function getLogType(name)
    return USER_LOG[name]
end