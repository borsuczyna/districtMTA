local seed = 32130
local dailyRewards = {
    {type = 'money', text = '$%d w kasiorce', count = 100},
    {type = 'exp', text = '%d expa', count = 10},
    {type = 'custom kurwo', text = 'jebac cie chuj cie to %d xd', count = 10},
}

local specialDayRewards = {
    [6] = {type = 'money', text = '$%d w kasiorce', count = 10000, callback = function(player)
        print('special reward for day 6')
    end},
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
            givePlayerMoney(player, count)
        elseif reward.type == 'exp' then
            givePlayerExp(player, count)
        end

        exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Odebrano nagrodę dzienną: ' .. string.format(reward.text, count))
    end
end

function redeemDailyRewardResult(queryResult, player)
    local result, rows, lastId = dbPoll(queryResult, 0)

    local day = getPlayerDailyRewardDay(player)
    local reward = getDailyRewardAtDayData(day)
    if reward then
        givePlayerReward(player, reward)
    end

    setElementData(player, 'player:dailyRewardRedeem', getRealTime().timestamp + 86400)
    setElementData(player, 'player:dailyRewardDay', day + 1)

    -- exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Odebrano dzienną nagrodę')
    triggerClientEvent(player, 'dashboard:redeemDailyRewardResult', root, player)
end

function redeemDailyReward(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then
        exports['m-anticheat']:setPlayerTriggerLocked(player, true, 'Próba odebrania nagrody przed zalogowaniem')
        return
    end

    local canRedeem, time = canPlayerRedeemDailyReward(player)
    if canRedeem ~= true then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Możesz odebrać dzienną nagrodę za ' .. time)
        return false
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie udało się odebrać nagrody')
        return false
    end

    dbQuery(redeemDailyRewardResult, {player}, connection, 'UPDATE `m-users` SET `dailyRewardRedeem` = NOW() + INTERVAL 1 DAY, `dailyRewardDay` = `dailyRewardDay` + 1 WHERE `uid` = ?', uid)
end

function getPlayerLast10DailyRewards(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then
        exports['m-anticheat']:setPlayerTriggerLocked(player, true, 'Próba pobrania nagród przed zalogowaniem')
        return
    end

    local day = getPlayerDailyRewardDay(player)
    local redeemDay = getElementData(player, 'player:dailyRewardRedeem')
    local rewards = {}
    for i = 1, 10 do
        local rewardType = getDailyRewardAtDay(day - i)
        if rewardType then
            table.insert(rewards, {
                text = rewardType,
                date = redeemDay - (i * 86400)
            })
        else
            break
        end
    end

    return rewards
end