addEvent('reports:doReportAction', true)
addEvent('reports:requestReportsList', true)

local reports = {}
local REPORT_STATE = {
    PENDING = 0,
    ACCEPTED = 1,
    REJECTED = 2
}

local reportTimeouts = {}

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

    local admins = {}
    for i, player in ipairs(getElementsByType('player')) do
        if doesPlayerHavePermission(player, 'reports') then
            table.insert(admins, player)
        end
    end

    triggerClientEvent(admins, 'reports:addReport', resourceRoot, reportData)
end

addCommandHandler('report', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(player) then return end

    if (reportTimeouts[player] or 0) > getTickCount() then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Report można wysłać co 1 minutę')
        return
    end

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
    reportTimeouts[player] = getTickCount() + 60000
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
        exports['m-notis']:addNotification(report.reporter, 'success', 'Zgłoszenie', ('Twoje zgłoszenie zostało zaakceptowane przez %s'):format(htmlEscape(getPlayerName(client))))
        exports['m-logs']:sendLog('reports', 'success', ('Gracz `%s` zaakceptował zgłoszenie na gracza `%s` z powodem: `%s`'):format(htmlEscape(getPlayerName(client)), htmlEscape(getPlayerName(report.target)), report.reason))

        local admins = {}

        for i, player in ipairs(getElementsByType('player')) do
            if doesPlayerHavePermission(player, 'reports') and player ~= client then
                table.insert(admins, player)
            end
        end

        triggerClientEvent(admins, 'reports:rejectReport', resourceRoot, hash)
        triggerClientEvent(client, 'reports:acceptReport', resourceRoot, hash)
    elseif action == 'reject' then
        if report.state ~= REPORT_STATE.PENDING then
            exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Zgłoszenie zostało już zaakceptowane')
            return
        end
        
        table.remove(reports, index)
        exports['m-notis']:addNotification(client, 'success', 'Zgłoszenie', 'Zgłoszenie zostało odrzucone')
        exports['m-notis']:addNotification(report.reporter, 'error', 'Zgłoszenie', ('Twoje zgłoszenie zostało odrzucone przez %s'):format(htmlEscape(getPlayerName(client))))
        exports['m-logs']:sendLog('reports', 'error', ('Gracz `%s` odrzucił zgłoszenie na gracza `%s` z powodem: `%s`'):format(getPlayerName(client), getPlayerName(report.target), report.reason))

        local admins = {}

        for i, player in ipairs(getElementsByType('player')) do
            if doesPlayerHavePermission(player, 'reports') and player ~= client then
                table.insert(admins, player)
            end
        end

        triggerClientEvent(admins, 'reports:rejectReport', resourceRoot, hash)
        triggerClientEvent(client, 'reports:rejectReport', resourceRoot, hash)
    end
end)

addEventHandler('reports:requestReportsList', resourceRoot, function()
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `reports:requestReportsList` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if not doesPlayerHavePermission(client, 'reports') then return end

    triggerClientEvent(client, 'reports:addReports', resourceRoot, reports) 
end)