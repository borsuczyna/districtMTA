addEvent('dashboard:fetchData', true)
addEvent('dashboard:vehicleDetails', true)
addEvent('dashboard:redeemDailyReward', true)
addEvent('dashboard:fetchDailyReward', true)
addEvent('dashboard:claimDailyTask', true)

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

    if data == 'account' then
        local rank = getElementData(client, 'player:rank') or 0
        if rank > 0 then
            result[1].rank = exports['m-admins']:getRankName(rank)
            result[1].rankColor = {exports['m-admins']:getRankColor(rank)}
        else
            result[1].rank = 'Gracz'
            result[1].rankColor = {180, 180, 180}
        end

        local level = getElementData(client, 'player:level') or 1
        result[1].uid = getElementData(client, 'player:uid')
        result[1].timePlayed = getElementData(client, 'player:time')
        result[1].timeAfk = getElementData(client, 'player:afkTime')
        result[1].organization = getElementData(client, 'player:organization') or 'Brak'
        result[1].level = level
        result[1].exp = getElementData(client, 'player:exp') or 0
        result[1].nextLevelExp = exports['m-core']:getNextLevelExp(level)
        result[1].money = getPlayerMoney(client)
        result[1].bankMoney = getElementData(client, 'player:bankMoney') or 0
    end

    triggerClientEvent(client, 'dashboard:fetchDataResult', resourceRoot, data, result)

    table.removeValue(requests, requestId)
end

addEventHandler('dashboard:fetchData', resourceRoot, function(data)
	if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    if data == 'achievements' then
        local achievements = exports['m-core']:getPlayerAchievements(client)
        triggerClientEvent(client, 'dashboard:fetchDataResult', resourceRoot, data, achievements)
        return
    end

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
    elseif data == 'account' then
        query = [[
            SELECT u.`username`, u.`registerDate`, u.`lastActive`, COUNT(v.`uid`) AS vehiclesCount
            FROM `m-users` u
            LEFT JOIN `m-vehicles` v ON v.`owner` = u.`uid`
            WHERE u.`uid` = ?
        ]]

        queryArgs = {uid}
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
    exports['m-core']:getPlayerLast10DailyRewards(client)
    exports['m-core']:getPlayerLast10DaysDailyTasks(client)

    triggerClientEvent(client, 'dashboard:fetchDailyRewardResult', resourceRoot, yestarday, today)
end)

addEventHandler('dashboard:claimDailyTask', resourceRoot, function(date)
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    exports['m-core']:claimDailyTask(client, date)
end)