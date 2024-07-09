function getPlayerDailyRewardDay(player)
    local player = player or localPlayer
    return getElementData(player, 'player:dailyRewardDay') or 1
end

function canPlayerRedeemDailyReward(player)
    local player = player or localPlayer
    local date = getElementData(player, 'player:dailyRewardRedeem')

    if date < getRealTime().timestamp then
        return true
    else
        local timeLeft = date - getRealTime().timestamp
        local time = {}

        time.d = math.floor(timeLeft / 86400)
        timeLeft = timeLeft - time.d * 86400

        time.h = math.floor(timeLeft / 3600)
        timeLeft = timeLeft - time.h * 3600

        time.m = math.floor(timeLeft / 60)
        timeLeft = timeLeft - time.m * 60

        time.s = timeLeft

        local timeStr = {}
        if time.h > 0 then
            table.insert(timeStr, string.format('%02d', time.h))
        end

        if time.m > 0 then
            table.insert(timeStr, string.format('%02d', time.m))
        end

        if time.s > 0 then
            table.insert(timeStr, string.format('%02d', time.s))
        end

        return date, table.concat(timeStr, ':')
    end
end