local connection, settings;
local settings = {
    host = 'localhost',
    user = 'root',
    password = 'sherlockholmesxd123',
    database = 'mtaserver',
    timeout = 10000,
}

function connectDatabase()
    connection = dbConnect('mysql', 'dbname='..settings.database..';host='..settings.host..';unix_socket=/var/run/mysqld/mysqld.sock;', settings.user, settings.password)

    if not connection then
        outputDebugString('Failed to connect to the database')
        outputServerLog('Failed to connect to the database')
    else
        outputDebugString('Connected to the database')
        outputServerLog('Connected to the database')

        setTimer(alive, 30000, 0)
    end
end

function alive()
    if connection then
        local result = dbPoll(dbQuery(connection, 'SELECT 1'), settings.timeout)
        if not result then
            outputDebugString('[CRITICAL] Lost connection to the database')
            outputServerLog('[CRITICAL] Lost connection to the database')
            connectDatabase()
        end
    else
        connectDatabase()
    end
end

function query(queryString, ...)
    if connection then
        local query = dbQuery(connection, queryString, ...)
        if query then
            return dbPoll(query, settings.timeout)
        end
    end
    return false
end

function execute(queryString, ...)
    if connection then
        return dbExec(connection, queryString, ...)
    end
    return false
end

function getConnection()
    return connection
end

addEventHandler('onResourceStart', resourceRoot, function()
    connectDatabase()
end)
