USER_LOG = {
    ACCOUNT = 1,
    VEHICLES = 2,
    ADMIN = 3
}

function addUserLog(type, message, details)
    local logType = getLogType(type)
    if not logType then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'INSERT INTO `m-users-logs` (`type`, `log`, `details`) VALUES (?, ?, ?)', logType, message, details)
end

function getLogType(name)
    return USER_LOG[name]
end