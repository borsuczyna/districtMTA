addEvent('reports:doReportAction', true)
addEvent('reports:requestReportsList', true)

local reports = {}
local REPORT_STATE = {
    PENDING = 0,
    ACCEPTED = 1,
    REJECTED = 2
}

local function generateHash()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local hash = ''
    for i = 1, 16 do
        local c = math.random(1, #chars)
        hash = hash .. chars:sub(c, c)
    end
    return hash
end

local function createReport(player, target, reason)
    local reportData = {
        reporter = player,
        target = target,
        reason = reason,
        time = getRealTime().timestamp,
        hash = generateHash(),
        state = REPORT_STATE.PENDING
    }

    table.insert(reports, reportData)

    for i, player in ipairs(getElementsByType('player')) do
        if doesPlayerHavePermission(player, 'reports') then
            triggerClientEvent(player, 'reports:addReport', resourceRoot, reportData)
        end
    end
end

addCommandHandler('report', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(player) then return end

    local reason = table.concat({...}, ' ')
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local foundUid = getElementData(foundPlayer, 'player:uid')
    if not foundUid then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Podany gracz nie jest zalogowany')
        return
    end
    
    local foundPlayerName = getPlayerName(foundPlayer)
    local foundId = getElementData(foundPlayer, 'player:id')
    
    exports['m-notis']:addNotification(player, 'success', 'Report', ('Wysłano zgłoszenie na gracza (%d) %s'):format(foundId, foundPlayerName))
    createReport(player, foundPlayer, reason)
    exports['m-logs']:sendLog('reports', 'info', ('Gracz `%s` zgłosił gracza `%s` z powodem: `%s`'):format(getPlayerName(player), foundPlayerName, reason))
end)

addEventHandler('reports:doReportAction', resourceRoot, function(hash, action)
    if not doesPlayerHavePermission(client, 'reports') then return end

    local report, index = nil
    for i, r in ipairs(reports) do
        if r.hash == hash then
            report = r
            index = i
            break
        end
    end

    if not report then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Nie znaleziono zgłoszenia')
        return
    end
    
    if action == 'accept' then
        if report.state ~= REPORT_STATE.PENDING then
            exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Zgłoszenie zostało już zaakceptowane')
            return
        end
        
        table.remove(reports, index)
        exports['m-notis']:addNotification(client, 'success', 'Zgłoszenie', 'Zgłoszenie zostało zaakceptowane')
        exports['m-notis']:addNotification(report.reporter, 'success', 'Zgłoszenie', 'Twoje zgłoszenie zostało zaakceptowane')
        exports['m-logs']:sendLog('reports', 'success', ('Gracz `%s` zaakceptował zgłoszenie na gracza `%s` z powodem: `%s`'):format(getPlayerName(client), getPlayerName(report.target), report.reason))

        for i, player in ipairs(getElementsByType('player')) do
            if doesPlayerHavePermission(player, 'reports') then
                triggerClientEvent(player, client == player and 'reports:acceptReport' or 'reports:removeReport', resourceRoot, hash)
            end
        end
    end
end)

addEventHandler('reports:requestReportsList', resourceRoot, function()
    if not doesPlayerHavePermission(client, 'reports') then return end

    triggerClientEvent(client, 'reports:addReports', resourceRoot, reports) 
end)