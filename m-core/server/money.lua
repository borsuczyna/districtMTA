local _givePlayerMoney = givePlayerMoney

function givePlayerMoney(player, type, details, amount)
    if amount < 1 then return end

    addMoneyLog(player, type, details, amount)
    _givePlayerMoney(player, amount)
end