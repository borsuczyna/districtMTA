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

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'INSERT INTO `m-money-logs` (`player`, `type`, `details`, `money`) VALUES (?, ?, ?, ?)', uid, type, details, amount)
end

function getLogType(name)
    return USER_LOG[name]
end