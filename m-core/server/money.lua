local _givePlayerMoney = givePlayerMoney

function givePlayerMoney(player, type, details, amount)
    if amount == 0 then return end
    
    amount = math.ceil(amount)
    addMoneyLog(player, type, details, amount)

    if amount > 0 then
        _givePlayerMoney(player, amount)
    else
        takePlayerMoney(player, -amount)
    end

    updatePlayerMoney(player)
end