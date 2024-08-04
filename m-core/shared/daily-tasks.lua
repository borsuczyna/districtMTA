dailyTasks = {
    [1] = {
        text = 'Graj przez 20 minut',
        progress = function(player)
            local sessionTime = getElementData(player, 'player:session') or 0
            return math.min(sessionTime, 20)
        end,
        max = 20,
        rewardText = '1000$',
        reward = function(player)
            givePlayerMoney(player, 'daily task', 'Zadanie dzienne', 1000)
        end,
    },
}