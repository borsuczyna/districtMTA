local achievementsPercents = {}
local achievements = {
    [1] = {
        title = 'Pierwszy tysiąc',
        description = 'Zdobądź swoój pierwszy $1,000',
        check = function(player)
            return getPlayerMoney(player) >= 1000
        end,
        reward = function(player)
            givePlayerMoney(player, 'daily reward', 'Nagroda dzienna', 1000)
        end,
    }
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
WHERE 
    uid IN (?)]], table.concat(ids, ', '))
end

addEventHandler('onResourceStart', resourceRoot, function()
    updateAchievementsPercent()
    setTimer(updateAchievementsPercent, 60000 * 5, 0)
end)

for k,v in ipairs(getElementsByType('player')) do
    updatePlayerAchievement(v, 1)
end