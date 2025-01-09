addEvent('atm:fetchLogs')
addEvent('atm:deposit')
addEvent('atm:withdraw')
addEvent('atm:transfer')

local timeouts = {}

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

function fetchLogsResult(query, hash, player)
    local result = dbPoll(query, 0)
    if not result then return end

    exports['m-ui']:respondToRequest(hash, {status = 'success', logs = result})
end

addEventHandler('atm:fetchLogs', root, function(hash, player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end
    
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(fetchLogsResult, {hash, player}, connection, 'SELECT * FROM `m-money-logs` WHERE player = ? ORDER BY uid DESC LIMIT 500', uid)
end)

addEventHandler('atm:deposit', root, function(hash, player, amount)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end
    
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    amount = math.floor(tonumber(amount) * 100)
    if amount <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Kwota musi być większa od zera.'})
        return
    end

    local balance = getPlayerMoney(player)
    if balance < amount then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tyle gotówki.'})
        return
    end

    exports['m-core']:givePlayerMoney(player, 'atm', 'Depozyt w bankomacie', -amount)

    local bankMoney = getElementData(player, 'player:bankMoney') or 0
    setElementData(player, 'player:bankMoney', bankMoney + amount)
    exports['m-core']:updatePlayerMoney(player)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie zdeponowano ' .. addCents(amount) .. '.', balance = getElementData(player, 'player:bankMoney')})
end)

addEventHandler('atm:withdraw', root, function(hash, player, amount)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end
    
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    amount = math.floor(tonumber(amount) * 100)
    if amount <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Kwota musi być większa od zera.'})
        return
    end

    local bankMoney = getElementData(player, 'player:bankMoney') or 0
    if bankMoney < amount then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tyle gotówki na koncie.'})
        return
    end

    exports['m-core']:givePlayerMoney(player, 'atm', 'Wypłata z bankomatu', amount)

    setElementData(player, 'player:bankMoney', bankMoney - amount)
    exports['m-core']:updatePlayerMoney(player)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie wypłacono ' .. addCents(amount) .. '.', balance = getElementData(player, 'player:bankMoney')})
end)

function transferLookForPlayer(query, hash, player, target, amount)
    local result = dbPoll(query, 0)
    if not result then return end

    if #result == 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Podany gracz nie istnieje.'})
        return
    end

    local bankMoney = getElementData(player, 'player:bankMoney') or 0
    if bankMoney < amount then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tyle gotówki na koncie.'})
        return
    end

    setElementData(player, 'player:bankMoney', bankMoney - amount)
    exports['m-core']:updatePlayerMoney(player)
    exports['m-core']:addMoneyLog(player, 'transfer', 'Przelew do gracza ' .. result[1].username, -amount)

    local transferPlayer = exports['m-core']:getPlayerByUid(result[1].uid)
    if transferPlayer then
        setElementData(transferPlayer, 'player:bankMoney', (getElementData(transferPlayer, 'player:bankMoney') or 0) + amount)
        exports['m-core']:updatePlayerMoney(transferPlayer)
        exports['m-core']:addMoneyLog(transferPlayer, 'transfer', 'Przelew od gracza ' .. getPlayerName(player), amount)
    else
        exports['m-core']:givePlayerBankMoney(result[1].uid, 'transfer', 'Przelew od gracza ' .. getPlayerName(player), amount)
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie przelano ' .. addCents(amount) .. '.', balance = getElementData(player, 'player:bankMoney')})
end

addEventHandler('atm:transfer', root, function(hash, player, target, amount)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end
    
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    amount = math.floor(tonumber(amount) * 100)
    target = tonumber(target)

    if uid == target then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie możesz przelać pieniędzy sam do siebie.'})
        return
    end
    
    if amount <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Kwota musi być większa od zera.'})
        return
    end

    local bankMoney = getElementData(player, 'player:bankMoney') or 0
    if bankMoney < amount then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tyle gotówki na koncie.'})
        return
    end

    dbQuery(transferLookForPlayer, {hash, player, target, amount}, connection, 'SELECT `username`, `uid` FROM `m-users` WHERE uid = ?', target)
end)

function addCents(amount)
    return '$' .. string.format('%0.2f', amount / 100)
end