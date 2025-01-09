function givePlayerExp(player, amount)
    local exp = getElementData(player, 'player:exp') or 0
    local level = getElementData(player, 'player:level') or 1
    local nextLevelExp = getNextLevelExp(level)
    
    exp = exp + amount
    while exp >= nextLevelExp do
        exp = exp - nextLevelExp
        level = level + 1
        nextLevelExp = getNextLevelExp(level)
    end

    setElementData(player, 'player:exp', exp)
    setElementData(player, 'player:level', level)
end