function pseudoMathRandom(a, b, seed)
    local x = math.sin(seed) * 10000
    return math.floor((x - math.floor(x)) * (b - a + 1) + a)
end

function getTodaysDailyTask()
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        return false
    end

    local query = dbQuery(connection, 'SELECT `task` FROM `m-daily-tasks` WHERE `date` = CURDATE()')
    if not query then
        return false
    end

    local result = dbPoll(query, 510000)
    if result and #result > 0 then
        return dailyTasks[result[1].task], result[1].task
    else
        local seed = getRealTime().timestamp
        local taskId = pseudoMathRandom(1, #dailyTasks, seed)
        local task = dailyTasks[taskId]
        dbExec(connection, 'INSERT INTO `m-daily-tasks` (`date`, `task`) VALUES (CURDATE(), ?)', taskId)
        return task, taskId
    end
end

function getPlayerTodaysDailyTaskProgress(player)
    local task = getTodaysDailyTask()
    if not task then
        return false
    end

    return task.progress(player), task.max
end

function updatePlayerDailyTaskProgress(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return false end

    local task, taskId = getTodaysDailyTask()

    local progress, max = getPlayerTodaysDailyTaskProgress(player)
    if progress then
        local connection = exports['m-mysql']:getConnection()
        if not connection then
            return false
        end

        dbExec(connection, 'INSERT INTO `m-daily-tasks-history` (`user`, `date`, `task`, `progress`) VALUES (?, CURDATE(), ?, ?) ON DUPLICATE KEY UPDATE `progress` = ?', uid, taskId, progress, progress)
    end
end

function getPlayerLast10DaysDailyTasksResult(queryResult, player)
    local result, rows, lastId = dbPoll(queryResult, 0)
    if not result then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie udało się pobrać historii zadań')
        return false
    end

    local tasks = {}

    for _,item in pairs(result) do
        table.insert(tasks, {
            task = toJSON(dailyTasks[item.task]),
            progress = item.progress,
            claimed = item.claimed,
            date = item.date
        })
    end

    triggerClientEvent(player, 'dashboard:getPlayerLast10DaysDailyTasksResult', root, tasks)
end

function getPlayerLast10DaysDailyTasks(player)
    updatePlayerDailyTaskProgress(player)

    local uid = getElementData(player, 'player:uid')
    if not uid then
        exports['m-anticheat']:setPlayerTriggerLocked(player, true, 'Próba pobrania historii zadań przed zalogowaniem')
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie udało się pobrać historii zadań')
        return false
    end

    dbQuery(getPlayerLast10DaysDailyTasksResult, {player}, connection, 'SELECT * FROM `m-daily-tasks-history` WHERE `user` = ? ORDER BY `date` DESC LIMIT 10', uid)
end

function claimDailyTaskResult(queryResult, hash, player)
    local result, rows, lastId = dbPoll(queryResult, 0)
    if not result then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie udało się pobrać historii zadań'})
        return false
    end

    if not result[1] then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie udało się pobrać historii zadań'})
        return false
    end

    if result[1].claimed == 1 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nagroda za te zadanie dzienne została już odebrana'})
        return false
    end

    local taskData = dailyTasks[result[1].task]
    if not taskData then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie udało się pobrać tego zadania'})
        return false
    end

    if result[1].progress < taskData.max then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie możesz odebrać nagrody za to zadanie, ponieważ nie zostało ono ukończone'})
        return false
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie udało się odebrać nagrody'})
        return false
    end

    dbExec(connection, 'UPDATE `m-daily-tasks-history` SET `claimed` = 1 WHERE `uid` = ?', result[1].uid)
    exports['m-ui']:respondToRequest(hash, {status = 'success', title = 'Sukces', message = 'Nagroda za zadanie dzienne została odebrana'})
    taskData.reward(player)
end

function claimDailyTask(hash, player, date)
    local uid = getElementData(player, 'player:uid')
    if not uid then return false end

    updatePlayerDailyTaskProgress(player)

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Nie udało się odebrać nagrody'})
        return false
    end

    dbQuery(claimDailyTaskResult, {hash, player}, connection, 'SELECT `uid`, `claimed`, `progress`, `task` FROM `m-daily-tasks-history` WHERE `user` = ? AND `date` = DATE(?)', uid, date)
end