addEvent('jobs:getPlayerJobData', true)
addEvent('jobs:buyUpgrade', true)

function getPlayerJobDataResult(dbResult, player, job)
    if not dbResult then return end
    local result = dbPoll(dbResult, 0)
    if not result then return end
    
    local data = result[1]
    data.job = job
    data.points = data.points or 0
    data.upgradePoints = data.upgradePoints or 0
    data.playerUpgrades = split(data.playerUpgrades or '', ',')
    data.topPlayers = data.topPlayers or ''

    triggerClientEvent(player, 'jobs:getPlayerJobDataResult', resourceRoot, data)
end

function getPlayerIncomeHistoryResult(dbResult, player, job)
    if not dbResult then return end
    local result = dbPoll(dbResult, 0)
    if not result then return end

    local data = result[1]
    data.last10days = split(data.last10days or '', ',')
    data.job = job

    triggerClientEvent(player, 'jobs:getPlayerIncomeHistoryResult', resourceRoot, data)
end

function getPlayerJobData(job)
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(getPlayerJobDataResult, {client, job}, connection, [[
        SELECT 
            d.*, 
            GROUP_CONCAT(u.upgrade) AS playerUpgrades, 
            (SELECT GROUP_CONCAT(CONCAT(top.user, ' ', top.username, ' ', IFNULL(top.avatar, 'null'), ' ', top.points) ORDER BY top.points DESC SEPARATOR ';') 
            FROM (SELECT jd.user, jd.points, u.username, u.avatar 
                FROM `m-jobs-data` jd 
                JOIN `m-users` u ON jd.user = u.uid 
                WHERE jd.job = ? 
                ORDER BY jd.points DESC 
                LIMIT 3) AS top) AS topPlayers
        FROM `m-jobs-data` d 
        LEFT JOIN `m-jobs-upgrades` u 
        ON d.user = u.user AND d.job = u.job 
        WHERE d.user = ? AND d.job = ?
    ]], job, uid, job)

    dbQuery(getPlayerIncomeHistoryResult, {client, job}, connection, [[
        SELECT
            GROUP_CONCAT(COALESCE(r.money, 0) ORDER BY dates.date DESC SEPARATOR ',') AS last10days
        FROM (
            SELECT DATE_SUB(CURDATE(), INTERVAL n DAY) AS date
            FROM (
                SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
                UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
                UNION ALL SELECT 8 UNION ALL SELECT 9
            ) AS numbers
        ) AS dates
        LEFT JOIN (
            SELECT DATE(`date`) AS date, SUM(money) AS money
            FROM `m-jobs-money-history`
            WHERE `user` = ? AND `job` = ?
            AND `date` >= DATE_SUB(CURDATE(), INTERVAL 9 DAY)
            GROUP BY DATE(`date`)
        ) AS r ON dates.date = r.date
        ORDER BY dates.date DESC;
    ]], uid, job)
end

addEventHandler('jobs:getPlayerJobData', resourceRoot, getPlayerJobData)

function buyUpgradeResult(dbResult, player, job, upgrade)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    if not dbResult then return end
    local result = dbPoll(dbResult, 0)
    if not result then return end

    local data = result[1]
    if not data then return end

    local cost = jobs[job].upgrades[upgrade].points

    if data.upgradePoints < cost then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie masz wystarczająco punktów do zakupu tego ulepszenia')
        return
    end

    dbExec(exports['m-mysql']:getConnection(), 'UPDATE `m-jobs-data` SET upgradePoints = ? WHERE user = ? AND job = ?', data.upgradePoints - cost, uid, job)
    dbExec(exports['m-mysql']:getConnection(), 'INSERT INTO `m-jobs-upgrades` (user, job, upgrade) VALUES (?, ?, ?)', uid, job, upgrade)

    triggerClientEvent(player, 'jobs:buyUpgradeResult', resourceRoot, job, upgrade, cost)
end

addEventHandler('jobs:buyUpgrade', resourceRoot, function(job, upgrade)
    upgrade = tonumber(upgrade)

    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    if not jobs[job] then
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Invalid job')
        return
    end

    if not jobs[job].upgrades[upgrade] then
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Invalid upgrade')
        return
    end

    -- using single query to check if player has enough points, if so insert
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(buyUpgradeResult, {client, job, upgrade}, connection, [[
        SELECT points, upgradePoints 
        FROM `m-jobs-data` 
        WHERE user = ? AND job = ?
    ]], uid, job)
end)

function giveMoney(player, amount)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local job = getElementData(player, 'player:job')
    if not job then return end
    if not jobs[job] then return end

    dbExec(connection, 'INSERT INTO `m-jobs-money-history` (user, job, money) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE money = money + ?', uid, job, amount, amount)
    givePlayerMoney(player, amount)
end

-- add 50$ on test command
addCommandHandler('teste', function(player)
    giveMoney(player, 50)
end)