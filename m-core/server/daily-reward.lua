local seed = 32130
local dailyRewards = {
    {type = 'money', text = '$%d', count = 100},
    {type = 'exp', text = '%d exp', count = 10},
}

local specialDayRewards = {
    -- [6] = {type = 'money', text = '$%d w kasiorce', count = 10000, callback = function(player)
    --     print('special reward for day 6')
    -- end},
}

function pseudoMathRandom(a, b, seed)
    local x = math.sin(seed) * 10000
    return math.floor((x - math.floor(x)) * (b - a + 1) + a)
end

function getRewardCountAtDay(count, day)
    return math.floor(count * (1 + (day * day / 700)))
end

function getDailyRewardAtDayData(day)
    if day < 1 then return false end

    local specialReward = specialDayRewards[day]
    if specialReward then
        return specialReward
    end

    return dailyRewards[pseudoMathRandom(1, #dailyRewards, seed + day)]
end

function getDailyRewardAtDay(day)
    local reward = getDailyRewardAtDayData(day)
    if not reward then return false end

    return string.format(reward.text, getRewardCountAtDay(reward.count, day))
end

function givePlayerReward(player, reward)
    local count = getRewardCountAtDay(reward.count, getPlayerDailyRewardDay(player))

    if reward.callback then
        reward.callback(player)
    else
        if reward.type == 'money' then
            givePlayerMoney(player, 'daily reward', 'Nagroda dzienna', count*100)
        elseif reward.type == 'exp' then
            givePlayerExp(player, count)
        end
    end
end

function redeemDailyRewardResult(queryResult, player, hash)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie udało się odebrać nagrody, spróbuj ponownie'})
        return false
    end

    local uid = getElementData(player, 'player:uid')
    local result, rows, lastId = dbPoll(queryResult, 0)

    local day = getPlayerDailyRewardDay(player)
    local reward = getDailyRewardAtDayData(day)
    local rewardText = getDailyRewardAtDay(day)
    if reward then
        givePlayerReward(player, reward)
    end

    setElementData(player, 'player:dailyRewardRedeem', getRealTime().timestamp + 86400)
    setElementData(player, 'player:dailyRewardDay', day + 1)

    dbExec(connection, 'INSERT INTO `m-daily-rewards-history` (`user`, `reward`, `date`) VALUES (?, ?, NOW());', uid, rewardText)
    exports['m-ui']:respondToRequest(hash, {status = 'success', title = 'Sukces', message = 'Odebrano nagrodę dzienną: ' .. rewardText})
end

function redeemDailyReward(player, hash)
    local uid = getElementData(player, 'player:uid')
    if not uid then
        exports['m-anticheat']:setPlayerTriggerLocked(player, true, 'Próba odebrania nagrody przed zalogowaniem')
        return
    end

    local canRedeem, time = canPlayerRedeemDailyReward(player)
    if canRedeem ~= true then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Możesz odebrać dzienną nagrodę za ' .. time})
        return false
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie udało się odebrać nagrody, spróbuj ponownie'})
        return false
    end

    local day = getPlayerDailyRewardDay(player) + 1
    dbQuery(redeemDailyRewardResult, {player, hash}, connection, 'UPDATE `m-users` SET `dailyRewardRedeem` = NOW() + INTERVAL 1 DAY, `dailyRewardDay` = ? WHERE `uid` = ?', day, uid)
end

function getPlayerLast10DailyRewardsResult(queryResult, player)
    local result, rows, lastId = dbPoll(queryResult, 0)
    if not result then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie udało się pobrać historii nagród')
        return false
    end

    triggerClientEvent(player, 'dashboard:getPlayerLast10DailyRewardsResult', root, result)
end

function getPlayerLast10DailyRewards(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then
        exports['m-anticheat']:setPlayerTriggerLocked(player, true, 'Próba pobrania nagród przed zalogowaniem')
        return
    end

    local day = getPlayerDailyRewardDay(player)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie udało się pobrać historii nagród')
        return false
    end

    dbQuery(getPlayerLast10DailyRewardsResult, {player}, connection, 'SELECT * FROM `m-daily-rewards-history` WHERE `user` = ? ORDER BY `date` DESC LIMIT 10;', uid)
end