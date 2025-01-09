addEvent('dashboard:fetchData')
addEvent('dashboard:vehicleDetails', true)
addEvent('dashboard:redeemDailyReward')
addEvent('dashboard:fetchDailyReward', true)
addEvent('dashboard:claimDailyTask')
addEvent('dashboard:fetchPaymentUrl')

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

function fetchDataResult(queryHandle, data, client, hash, requestId)
    local result = dbPoll(queryHandle, 0)
    if not result then
        -- exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Nie udało się pobrać danych')
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie udało się pobrać danych'})
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
        
        local missions = {}
        local playerMission = exports['m-missions']:getPlayerMission(client) or 1
        for k,v in pairs(exports['m-missions']:getMissionList()) do
            table.insert(missions, {
                id = k,
                title = v[2],
                description = playerMission > k and v[3] or 'Nie wykonano',
                icon = v[4],
                passed = playerMission > k
            })
        end

        result[1].missions = missions
    end

    -- triggerClientEvent(client, 'dashboard:fetchDataResult', resourceRoot, data, result)
    exports['m-ui']:respondToRequest(hash, {status = 'success', data = result})

    table.removeValue(requests, requestId)
end

addEventHandler('dashboard:fetchData', resourceRoot, function(hash, player, data)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    if data == 'achievements' then
        local achievements = exports['m-core']:getPlayerAchievements(player)
        -- triggerClientEvent(player, 'dashboard:fetchDataResult', resourceRoot, data, achievements)
        exports['m-ui']:respondToRequest(hash, {status = 'success', data = achievements})
        return
    end

    local requestId = data .. '-' .. uid
    if table.find(requests, requestId) then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie udało się pobrać danych')
        return
    end
    
    local query, queryArgs = false, false
    if data == 'punishments' then
        query = 'SELECT * FROM `m-punishments` WHERE user = ?'
        queryArgs = {uid}
    elseif data == 'vehicles' then
        exports['m-core']:getPlayerVehicles(player, hash, nil, true, true)
        return
    elseif data == 'account' then
        query = [[
            SELECT u.`username`, u.`registerDate`, u.`lastActive`, COUNT(v.`uid`) AS vehiclesCount
            FROM `m-users` u
            LEFT JOIN `m-vehicles` v ON v.`owner` = u.`uid`
            WHERE u.`uid` = ?
        ]]

        queryArgs = {uid}
    elseif data == 'discord' then
        query = 'SELECT `discordAccount`, `discordCode` FROM `m-users` WHERE `uid` = ?'
        queryArgs = {uid}
    elseif data == 'logs' then
        query = 'SELECT * FROM `m-users-logs` WHERE player = ? ORDER BY uid DESC LIMIT 200'
        queryArgs = {uid}
    elseif data == 'money-logs' then
        query = 'SELECT * FROM `m-money-logs` WHERE player = ? ORDER BY uid DESC LIMIT 500'
        queryArgs = {uid}
    end

    if not query then return end

    table.insert(requests, requestId)
    dbQuery(fetchDataResult, {data, player, hash, requestId}, connection, query, unpack(queryArgs or {}))
end)

addEventHandler('dashboard:vehicleDetails', resourceRoot, function(id)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `dashboard:vehicleDetails` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local vehicle = exports['m-core']:getVehicleByUid(tonumber(id))
    if not vehicle then
        triggerClientEvent(client, 'dashboard:vehicleDetailsResult', resourceRoot, id, false)
        return
    end

    local fuel = getElementData(vehicle, 'vehicle:fuel')
    local maxFuel = getElementData(vehicle, 'vehicle:maxFuel')
    local mileage = getElementData(vehicle, 'vehicle:mileage')
    local x, y, z = getElementPosition(vehicle)
    local lastDriver = getElementData(vehicle, 'vehicle:lastDriver')

    triggerClientEvent(client, 'dashboard:vehicleDetailsResult', resourceRoot, id, {
        fuel = fuel,
        maxFuel = maxFuel,
        mileage = mileage,
        position = {x, y, z},
        lastDriver = exports['m-core']:getPlayerNameByUid(tonumber(lastDriver)) or 'Brak'
    })
end)

addEventHandler('dashboard:redeemDailyReward', resourceRoot, function(hash, player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    exports['m-core']:redeemDailyReward(player, hash)
end)

addEventHandler('dashboard:fetchDailyReward', resourceRoot, function()
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `dashboard:fetchDailyReward` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

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

addEventHandler('dashboard:claimDailyTask', resourceRoot, function(hash, player, date)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    exports['m-core']:claimDailyTask(hash, player, date)
end)