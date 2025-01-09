local accountConnectionReward = {
    exp = 50,
    money = 250,
}

local function givePlayerRewardOffline(uid)
    exports['m-mysql']:execute(
        'UPDATE `m-users` SET `exp` = `exp` + ?, `money` = `money` + ? WHERE `uid` = ?',
        accountConnectionReward.exp,
        accountConnectionReward.money,
        uid
    )

    exports['m-core']:addMoneyLog(player, 'discord-connect', 'Połączenie konta z discordem', accountConnectionReward.money)
end

local function givePlayerRewardOnline(player)
    exports['m-core']:givePlayerExp(player, accountConnectionReward.exp)
    exports['m-core']:givePlayerMoney(player, 'discord-connect', 'Połączenie konta z discordem', accountConnectionReward.money)
    exports['m-notis']:addNotification(player, 'success', 'Połączenie konta z discordem', 'Połączono konto z discordem! Nagroda została przyznana.')
end

function handleConnectAccount(data)
    local player = exports['m-core']:getPlayerByUid(tonumber(data.accountUid))
    if not player then
        givePlayerRewardOffline(tonumber(data.accountUid))
        return
    end

    givePlayerRewardOnline(player)
end