addEvent('dashboard:fetchData', true)
addEvent('dashboard:vehicleDetails', true)
addEvent('dashboard:redeemDailyReward', true)
addEvent('dashboard:fetchDailyReward', true)

local requests = {}

function table.find(tab, val)
    for i, v in ipairs(tab) do
        if v == val then
            return i
        end
    end
    return false
end

function table.removeValue(tab, val)
    local index = table.find(tab, val)
    if index then
        table.remove(tab, index)
    end
end

function fetchDataResult(queryHandle, data, client, requestId)
    local result = dbPoll(queryHandle, 0)
    if not result then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Nie udało się pobrać danych')
        return
    end

    triggerClientEvent(client, 'dashboard:fetchDataResult', resourceRoot, data, result)

    table.removeValue(requests, requestId)
end

addEventHandler('dashboard:fetchData', resourceRoot, function(data)
	if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local requestId = data .. '-' .. uid
    if table.find(requests, requestId) then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Nie udało się pobrać danych')
        return
    end
    
    local query, queryArgs = false, false
    if data == 'punishments' then
        query = 'SELECT * FROM `m-punishments` WHERE user = ?'
        queryArgs = {uid}
    elseif data == 'vehicles' then
        query = [[
            SELECT v.*, u.username AS ownerName, ud.username AS lastDriverName
            FROM `m-vehicles` v
            JOIN `m-users` u ON u.`uid` = v.`owner`
            LEFT JOIN `m-users` ud ON ud.`uid` = v.`lastDriver`
            WHERE v.`owner` = ? OR FIND_IN_SET(?, v.`sharedPlayers`)
        ]]

        queryArgs = {uid, uid}
    end

    if not query then return end

    table.insert(requests, requestId)
    dbQuery(fetchDataResult, {data, client, requestId}, connection, query, unpack(queryArgs or {}))
end)

addEventHandler('dashboard:vehicleDetails', resourceRoot, function(id)
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local vehicle = exports['m-core']:getVehicleByUid(tonumber(id))
    if not vehicle then
        triggerClientEvent(client, 'dashboard:vehicleDetailsResult', resourceRoot, id, false)
        return
    end

    local fuel = getElementData(vehicle, 'vehicle:fuel')
    local mileage = getElementData(vehicle, 'vehicle:mileage')
    local x, y, z = getElementPosition(vehicle)
    local lastDriver = getElementData(vehicle, 'vehicle:lastDriver')

    triggerClientEvent(client, 'dashboard:vehicleDetailsResult', resourceRoot, id, {
        fuel = fuel,
        mileage = mileage,
        position = {x, y, z},
        lastDriver = exports['m-core']:getPlayerNameByUid(tonumber(lastDriver)) or 'Brak'
    })
end)

addEventHandler('dashboard:redeemDailyReward', resourceRoot, function()
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    exports['m-core']:redeemDailyReward(client)
end)

addEventHandler('dashboard:fetchDailyReward', resourceRoot, function()
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local dailyRewardDay = exports['m-core']:getPlayerDailyRewardDay(client)
    local yestarday = exports['m-core']:getDailyRewardAtDay(dailyRewardDay - 1)
    local today = exports['m-core']:getDailyRewardAtDay(dailyRewardDay)
    local last10Days = exports['m-core']:getPlayerLast10DailyRewards(client)

    triggerClientEvent(client, 'dashboard:fetchDailyRewardResult', resourceRoot, yestarday, today, last10Days)
end)