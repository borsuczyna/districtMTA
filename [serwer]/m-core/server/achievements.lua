local achievementsPercents = {}
local achievements = {
    -- Osiągnięcia:
    -- - Pierwszy tysiąc
    -- - Pierwsze 10,000
    -- - Pierwsze 100,000
    -- - Pierwsze 1,000,000
    [1] = {
        title = 'Pierwszy tysiąc',
        description = 'Zdobądź swój pierwszy $1,000',
        check = function(player)
            return getPlayerMoney(player) >= 100000
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Pierwszy tysiąc'), 25000)
        end,
    },
    [2] = {
        title = 'Pierwsze $10,000',
        description = 'Zdobądź swoje pierwsze $10,000',
        check = function(player)
            return getPlayerMoney(player) >= 1000000
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Pierwsze 10,000'), 50000)
        end,
    },
    [3] = {
        title = 'Gruba kasa',
        description = 'Zdobądź swój pierwszy $100,000',
        check = function(player)
            return getPlayerMoney(player) >= 10000000
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Pierwsze 100,000'), 100000)
        end,
    },
    [4] = {
        title = 'Milioner',
        description = 'Zdobądź swój pierwszy $1,000,000',
        check = function(player)
            return getPlayerMoney(player) >= 100000000
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Pierwsze 1,000,000'), 500000)
        end,
    },
    -- Nowe osiągnięcia:
    -- - 5 poziom
    [5] = {
        title = '5 poziom',
        description = 'Osiągnij 5 poziom',
        check = function(player)
            return getElementData(player, 'player:level') >= 5
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('5 poziom'), 50000)
        end,
    },
    -- Nowe osiągnięcia:
    -- - Gracz - graj przez godzine bez przerwy
    -- - Zachłanny - graj przez 5 godzin bez przerwy
    -- - Uzależniony - graj przez 10 godzin bez przerwy
    -- - Doba. - graj przez 24 godziny bez przerwy
    [6] = {
        title = 'Gracz',
        description = 'Graj przez godzinę bez przerwy',
        check = function(player)
            return getElementData(player, 'player:session') >= 60
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Gracz'), 50000)
        end,
    },
    [7] = {
        title = 'Zachłanny',
        description = 'Graj przez 5 godzin bez przerwy',
        check = function(player)
            return getElementData(player, 'player:session') >= 300
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Zachłanny'), 100000)
        end,
    },
    [8] = {
        title = 'Uzależniony',
        description = 'Graj przez 10 godzin bez przerwy',
        check = function(player)
            return getElementData(player, 'player:session') >= 600
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Uzależniony'), 200000)
        end,
    },
    [9] = {
        title = 'Doba.',
        description = 'Graj przez 24 godziny bez przerwy',
        check = function(player)
            return getElementData(player, 'player:session') >= 1440
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Doba.'), 500000)
        end,
    },
    -- Nowicjusz – Spędź 10 godzin na serwerze.
    -- Zaznajomiony – Spędź 25 godzin na serwerze.
    -- Zaawansowany – Spędź 50 godzin na serwerze.
    -- Weteran – Spędź 100 godzin na serwerze.
    -- Legenda – Spędź 500 godzin na serwerze.
    -- Mistrz serwera – Spędź 1000 godzin na serwerze
    [10] = {
        title = 'Nowicjusz',
        description = 'Spędź 10 godzin na serwerze',
        check = function(player)
            return getElementData(player, 'player:time') >= 600
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Nowicjusz'), 50000)
        end,
    },
    [11] = {
        title = 'Zaznajomiony',
        description = 'Spędź 25 godzin na serwerze',
        check = function(player)
            return getElementData(player, 'player:time') >= 1500
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Zaznajomiony'), 100000)
        end,
    },
    [12] = {
        title = 'Zaawansowany',
        description = 'Spędź 50 godzin na serwerze',
        check = function(player)
            return getElementData(player, 'player:time') >= 3000
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Zaawansowany'), 200000)
        end,
    },
    [13] = {
        title = 'Weteran',
        description = 'Spędź 100 godzin na serwerze',
        check = function(player)
            return getElementData(player, 'player:time') >= 6000
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Weteran'), 500000)
        end,
    },
    [14] = {
        title = 'Legenda',
        description = 'Spędź 500 godzin na serwerze',
        check = function(player)
            return getElementData(player, 'player:time') >= 30000
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Legenda'), 1000000)
        end,
    },
    [15] = {
        title = 'Mistrz serwera',
        description = 'Spędź 1000 godzin na serwerze',
        check = function(player)
            return getElementData(player, 'player:time') >= 60000
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Mistrz serwera'), 2000000)
        end,
    },
    -- Pierwszy zakup – Kup swój pierwszy pojazd w salonie.
    -- Kolekcjoner – Kup 5 pojazdów w salonie.
    -- Miłośnik samochodów – Kup 10 pojazdów w salonie.
    -- element data: player:boughtCars (int)
    [16] = {
        title = 'Pierwszy zakup',
        description = 'Kup swój pierwszy pojazd w salonie',
        check = function(player)
            return (getElementData(player, 'player:boughtCars') or 0) >= 1
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Pierwszy zakup'), 50000)
        end,
    },
    [17] = {
        title = 'Kolekcjoner',
        description = 'Kup 5 pojazdów w salonie',
        check = function(player)
            return (getElementData(player, 'player:boughtCars') or 0) >= 5
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Kolekcjoner'), 100000)
        end,
    },
    [18] = {
        title = 'Miłośnik samochodów',
        description = 'Kup 10 pojazdów w salonie',
        check = function(player)
            return (getElementData(player, 'player:boughtCars') or 0) >= 10
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Miłośnik samochodów'), 200000)
        end,
    },
    -- Odbiorca nagrody – Odbierz swoją pierwszą dzienną nagrodę.
    -- Stały odbiorca – Odbierz 7 nagród dziennych z rzędu.
    -- Nagrody się sypią – Odbierz 30 nagród dziennych.
    -- Codzienna rutyna – Odbierz 100 nagród dziennych.
    -- use element data player:dailyRewardDay >= given day + 1
    [19] = {
        title = 'Odbiorca nagrody',
        description = 'Odbierz swoją pierwszą dzienną nagrodę',
        check = function(player)
            return getElementData(player, 'player:dailyRewardDay') >= 2
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Odbiorca nagrody'), 50000)
        end,
    },
    [20] = {
        title = 'Stały odbiorca',
        description = 'Odbierz 7 nagród dziennych z rzędu',
        check = function(player)
            return getElementData(player, 'player:dailyRewardDay') >= 8
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Stały odbiorca'), 100000)
        end,
    },
    [21] = {
        title = 'Nagrody się sypią',
        description = 'Odbierz 30 nagród dziennych',
        check = function(player)
            return getElementData(player, 'player:dailyRewardDay') >= 31
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Nagrody się sypią'), 300000)
        end,
    },
    [22] = {
        title = 'Codzienna rutyna',
        description = 'Odbierz 100 nagród dziennych',
        check = function(player)
            return getElementData(player, 'player:dailyRewardDay') >= 101
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Codzienna rutyna'), 1000000)
        end,
    },
    -- now player:catchedFishes
    -- Wędkarz – Złów swoją pierwszą rybę.
    -- Rybak – Złów 30 ryb.
    -- Wędkarz profesjonalista – Złów 100 ryb.
    -- Rybok - Złów 500 ryb.
    [23] = {
        title = 'Wędkarz',
        description = 'Złów swoją pierwszą rybę',
        check = function(player)
            return (getElementData(player, 'player:catchedFishes') or 0) >= 1
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Wędkarz'), 50000)
        end,
    },
    [24] = {
        title = 'Rybak',
        description = 'Złów 30 ryb',
        check = function(player)
            return (getElementData(player, 'player:catchedFishes') or 0) >= 30
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Rybak'), 100000)
        end,
    },
    [25] = {
        title = 'Wędkarz profesjonalista',
        description = 'Złów 100 ryb',
        check = function(player)
            return (getElementData(player, 'player:catchedFishes') or 0) >= 100
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Wędkarz profesjonalista'), 200000)
        end,
    },
    [26] = {
        title = 'Rybak',
        description = 'Złów 500 ryb',
        check = function(player)
            return (getElementData(player, 'player:catchedFishes') or 0) >= 500
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Rybak'), 500000)
        end,
    },
    -- AFK - Spędź 10 minut w trybie AFK.
    -- Znudzony - Spędź godzin e w trybie AFK.
    -- Zmęczony - Spędź 2 godziny w trybie AFK.
    -- Stypa - Spędź 5 godzin w trybie AFK.
    [27] = {
        title = 'AFK',
        description = 'Spędź 10 minut w trybie AFK',
        check = function(player)
            return getElementData(player, 'player:afkTime') >= 10
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('AFK'), 15000)
        end,
    },
    [28] = {
        title = 'Znudzony',
        description = 'Spędź godzinę w trybie AFK',
        check = function(player)
            return getElementData(player, 'player:afkTime') >= 60
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Znudzony'), 20000)
        end,
    },
    [29] = {
        title = 'Zmęczony',
        description = 'Spędź 2 godziny w trybie AFK',
        check = function(player)
            return getElementData(player, 'player:afkTime') >= 120
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Zmęczony'), 30000)
        end,
    },
    [30] = {
        title = 'Stypa',
        description = 'Spędź 5 godzin w trybie AFK',
        check = function(player)
            return getElementData(player, 'player:afkTime') >= 300
        end,
        reward = function(player)
            givePlayerMoney(player, 'achievement', ('Zdobycie osiągnięcia "%s"'):format('Stypa'), 50000)
        end,
    },
}

function getPlayerAchievements(player)
    local achievementsData = getElementData(player, 'player:achievements')
    if not achievementsData then return end

    local data = {}

    for k,v in ipairs(achievementsData) do
        local achievement = achievements[v.id]
        if not achievement then return end

        table.insert(data, v.id)
    end

    local achievementsList = {}

    for k,v in ipairs(achievements) do
        table.insert(achievementsList, {
            title = v.title,
            description = v.description,
            achieved = achievementsPercents[k] or 0,
        })
    end

    return {
        data = data,
        achievements = achievementsList,
    }
end

function didPlayerFinishAchievement(player, id)
    local achievementsData = getElementData(player, 'player:achievements')
    if not achievementsData then return end

    for k,v in ipairs(achievementsData) do
        if v.id == id then
            return true
        end
    end

    return false
end

function updatePlayerAchievement(player, id)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    if didPlayerFinishAchievement(player, id) then return end

    local achievement = achievements[id]
    if not achievement then return end

    if not achievement.check(player) then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbExec(connection, 'INSERT INTO `m-achievements` SET user = ?, achievement = ?', uid, id)
    dbExec(connection, 'INSERT INTO `m-achievements-count` SET uid = ?, achieved = 1 ON DUPLICATE KEY UPDATE achieved = achieved + 1', id)

    -- update element data
    local achievementsData = getElementData(player, 'player:achievements') or {}
    table.insert(achievementsData, {
        id = id,
    })

    setElementData(player, 'player:achievements', achievementsData)

    achievement.reward(player)
    exports['m-notis']:addNotification(player, 'success', 'Osiągnięcie', 'Zdobyłeś osiągnięcie "'..achievement.title..'"')
end

function updatePlayerPassedAchievements(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    -- use updatePlayerAchievement
    for k,v in ipairs(achievements) do
        updatePlayerAchievement(player, k)
    end
end

function assignPlayerAchievementsCallback(queryResult, player)
    local result, rows, lastId = dbPoll(queryResult, 0)
    if not result then return end

    local achievements = {}

    for k,v in ipairs(result) do
        table.insert(achievements, {
            id = v.achievement,
        })
    end

    setElementData(player, 'player:achievements', achievements)
end

function updatePlayerAchievements(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(assignPlayerAchievementsCallback, {player}, connection, 'SELECT * FROM `m-achievements` WHERE user = ?', uid)
end

function updateAchievementsPercentCallback(queryResult)
    local result, rows, lastId = dbPoll(queryResult, 0)
    if not result then return end

    for k,v in ipairs(result) do
        achievementsPercents[v.achievement] = tonumber(v.achievement_percentage)
    end
end

function updateAchievementsPercent()
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local ids = {}

    for k,v in ipairs(achievements) do
        table.insert(ids, k)
    end

    dbQuery(updateAchievementsPercentCallback, {}, connection, [[SELECT 
    uid AS achievement,
    achieved,
    (achieved / (SELECT COUNT(*) FROM `m-users`)) * 100 AS achievement_percentage
FROM 
    `m-achievements-count`
]])
end

addEventHandler('onResourceStart', resourceRoot, function()
    updateAchievementsPercent()
    setTimer(updateAchievementsPercent, 60000 * 5, 0)
end)

setTimer(function()
    for k,v in ipairs(getElementsByType('player')) do
        updatePlayerPassedAchievements(v)
    end
end, 5000, 0)