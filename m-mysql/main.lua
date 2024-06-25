local connection, settings;
local settings = {
    host = 'sql.22.svpj.link',
    user = 'db_104668',
    password = 'qtMAtF0j6BPL',
    database = 'db_104668',
    timeout = 10000,
}

function connectDatabase()
    connection = dbConnect('mysql', 'dbname='..settings.database..';host='..settings.host, settings.user, settings.password)

    if not connection then
        outputDebugString('[CRITICAL] Failed to connect to the database')
        outputServerLog('[CRITICAL] Failed to connect to the database')
    else
        outputDebugString('Connected to the database')
        outputServerLog('Connected to the database')

        -- Check if the connection is alive every 30 seconds
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

function getConnection()
    return connection
end

addEventHandler('onResourceStart', resourceRoot, function()
    connectDatabase()
end)