dailyTasks = {
    -- Graj przez 30 minut
    [1] = {
        text = 'Graj przez 30 minut',
        progress = function(player)
            local sessionTime = getElementData(player, 'player:session') or 0
            return math.min(sessionTime, 30)
        end,
        max = 30,
        rewardText = '$100',
        reward = function(player)
            givePlayerMoney(player, 'daily-task', ('Nagroda za ukończenie zadania dziennego: %s'):format('Graj przez 30 minut'), 10000)
        end,
    },
    -- Złów 5 ryb
    [2] = {
        text = 'Złów 5 ryb',
        progress = function(player)
            return getElementData(player, 'player:catchedFishes') or 0
        end,
        max = 5,
        rewardText = '$150',
        reward = function(player)
            givePlayerMoney(player, 'daily-task', ('Nagroda za ukończenie zadania dziennego: %s'):format('Złów 5 ryb'), 15000)
        end,
    },
    -- Spędź 15 minut AFK
    [3] = {
        text = 'Spędź 15 minut AFK',
        progress = function(player)
            local afkTime = getElementData(player, 'player:afkNow') or 0
            return math.min(afkTime, 15)
        end,
        max = 15,
        rewardText = '$50',
        reward = function(player)
            givePlayerMoney(player, 'daily-task', ('Nagroda za ukończenie zadania dziennego: %s'):format('Spędź 15 minut AFK'), 5000)
        end,
    },
    -- Dostarcz 5 zamówień w pracy burgerowni
    [4] = {
        text = 'Dostarcz 5 zamówień w pracy burgerowni',
        progress = function(player)
            return getElementData(player, 'player:deliveredBurgerOrders') or 0
        end,
        max = 5,
        rewardText = '$200',
        reward = function(player)
            givePlayerMoney(player, 'daily-task', ('Nagroda za ukończenie zadania dziennego: %s'):format('Dostarcz 5 zamówień w pracy burgerowni'), 20000)
        end,
    },
    -- Dostarcz 5 przesyłek na pracy kuriera
    [5] = {
        text = 'Dostarcz 5 przesyłek na pracy kuriera',
        progress = function(player)
            return getElementData(player, 'player:deliveredCourierPackages') or 0
        end,
        max = 5,
        rewardText = '$300',
        reward = function(player)
            givePlayerMoney(player, 'daily-task', ('Nagroda za ukończenie zadania dziennego: %s'):format('Dostarcz 5 przesyłek na pracy kuriera'), 30000)
        end,
    },
    -- Dostarcz 5 paczek na pracy magazyniera
    [6] = {
        text = 'Dostarcz 5 paczek na pracy magazyniera',
        progress = function(player)
            return getElementData(player, 'player:packagesDelivered') or 0
        end,
        max = 5,
        rewardText = '$200',
        reward = function(player)
            givePlayerMoney(player, 'daily-task', ('Nagroda za ukończenie zadania dziennego: %s'):format('Dostarcz 5 paczek na pracy magazyniera'), 20000)
        end,
    },
    -- Wywieź 100kg śmieci na pracy śmieciarza
    [7] = {
        text = 'Wywieź 100kg śmieci na pracy śmieciarza',
        progress = function(player)
            return getElementData(player, 'player:trashDelivered') or 0
        end,
        max = 100,
        rewardText = '$400',
        reward = function(player)
            givePlayerMoney(player, 'daily-task', ('Nagroda za ukończenie zadania dziennego: %s'):format('Wywieź 100kg śmieci na pracy śmieciarza'), 40000)
        end,
    },
}