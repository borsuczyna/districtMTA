function doesPlayerHavePremium(player)
    local premiumEnd = getElementData(player, 'player:premium-end')
    if not premiumEnd then
        return false
    end

    if getRealTime().timestamp >= tonumber(premiumEnd) then
        removeElementData(player, 'player:premium-end')
        return false
    end

    return true
end

print(doesPlayerHavePremium(source))