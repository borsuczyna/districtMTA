function getHouseTextures(houseId)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = dbQuery(connection, 'SELECT * FROM `m-house-textures` WHERE `houseId` = ?', houseId)
    local result = dbPoll(query, -1)

    return result
end

function removeAllHouseTextures(houseId)
    local data = houses[houseId]
    if not data then return end

    data.textures = {}

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'DELETE FROM `m-house-textures` WHERE `houseId` = ?', houseId)
end