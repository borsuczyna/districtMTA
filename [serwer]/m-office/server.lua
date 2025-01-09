addEvent('office:tickets')
addEvent('office:payTicket')
addEvent('office:jailTicket')

local timeouts = {}
local blip = createBlip(1481.279, -1806.924, 18.734, 15, 2, 255, 0, 0, 255, 0, 9999.0)
setElementData(blip, 'blip:hoverText', 'Urząd miasta')

local function isPlayerTimedOut(player)
    if not timeouts[player] then
        timeouts[player] = getTickCount()
        return false
    end

    if getTickCount() - timeouts[player] < 1000 then
        return true
    end

    timeouts[player] = getTickCount()
    return false
end

local function updatePlayerWantedLevel(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(function(query)
        local result = dbPoll(query, 0)
        if not result then return end

        local wantedLevel = result[1].count
        setPlayerWantedLevel(player, math.min(wantedLevel, 6))
    end, connection, 'SELECT COUNT(*) as count FROM `m-sapd-tickets` WHERE user = ? AND active = 1', uid)
end

local function getTicketsResponse(query, hash, player)
    local result = dbPoll(query, 0)
    if not result then
        exports['m-ui']:respondToRequest(hash, {status = 'success', tickets = {}})
        return
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', tickets = result})
end

addEventHandler('office:tickets', root, function(hash, player)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    dbQuery(getTicketsResponse, {hash, player}, connection, 'SELECT t.*, u.username as issuer FROM `m-sapd-tickets` t LEFT JOIN `m-users` u ON t.issuer = u.uid WHERE t.user = ? AND t.active = 1', uid)
end)

local function payTicketResponse(query, hash, player)
    local result = dbPoll(query, 0)
    if not result then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono mandatu.'})
        return
    end

    local ticket = result[1]
    if not ticket then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono mandatu.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    if getPlayerMoney(player, 'ticket') < ticket.amount * 100 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz wystarczającej ilości gotówki.'})
        return
    end

    dbExec(connection, 'UPDATE `m-sapd-tickets` SET active = 0 WHERE uid = ?', ticket.uid)
    exports['m-core']:givePlayerMoney(player, 'ticket', ('Opłata za mandat od %s z powodu %s'):format(htmlEscape(ticket.issuer or 'Fotoradar'), htmlEscape(ticket.reason)), -ticket.amount * 100)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Mandat został opłacony.'})
    
    updatePlayerWantedLevel(player)
end

addEventHandler('office:payTicket', root, function(hash, player, ticketId)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    dbQuery(payTicketResponse, {hash, player}, connection, 'SELECT t.*, u.username as issuer FROM `m-sapd-tickets` t LEFT JOIN `m-users` u ON t.issuer = u.uid WHERE t.user = ? AND t.uid = ? AND t.active = 1', uid, ticketId)
end)

local function jailTicketResponse(query, hash, player)
    local result = dbPoll(query, 0)
    if not result then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono mandatu.'})
        return
    end

    local ticket = result[1]
    if not ticket then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono mandatu.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    local minutes = ticket.amount / 100 * 20
    local endTime = getRealTime().timestamp + minutes * 60

    dbExec(connection, 'UPDATE `m-sapd-tickets` SET active = 0 WHERE uid = ?', ticket.uid)
    exports['m-faction-sapd']:putPlayerInJail(player, 'Urząd', endTime, 'Odsiadka za mandat')
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Rozpoczęto odsiadkę.'})
    
    updatePlayerWantedLevel(player)
end

addEventHandler('office:jailTicket', root, function(hash, player, ticketId)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak połączenia z bazą danych.'})
        return
    end

    dbQuery(jailTicketResponse, {hash, player}, connection, 'SELECT t.*, u.username as issuer FROM `m-sapd-tickets` t LEFT JOIN `m-users` u ON t.issuer = u.uid WHERE t.user = ? AND t.uid = ? AND t.active = 1', uid, ticketId)
end)

function htmlEscape(s)
    return s:gsub('[<>&"]', function(c)
        return c == '<' and '&lt;' or c == '>' and '&gt;' or c == '&' and '&amp;' or '&quot;'
    end)
end