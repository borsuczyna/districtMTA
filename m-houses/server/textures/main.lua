function getHouseTextures(houseId)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = dbQuery(connection, 'SELECT * FROM `m-house-textures` WHERE `houseId` = ?', houseId)
    local result = dbPoll(query, -1)

    return result
end