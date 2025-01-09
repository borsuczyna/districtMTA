local pendingTrades = {}
local trades = {}
local tradeTimers = {}
local timeouts = {}

addEvent('inventory:addToOffer')
addEvent('inventory:removeFromOffer')
addEvent('inventory:cancelTrading')
addEvent('inventory:acceptTrading')
addEvent('inventory:tradeWith')

addCommandHandler('trade', function(player, command, playerToFind, ...)
    if not getElementData(player, 'player:uid') or not getElementData(player, 'player:spawn') then return end
    
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    tradeWith(player, foundPlayer)
end)

addCommandHandler('accept', function(player, command, id)
    if not getElementData(player, 'player:uid') or not getElementData(player, 'player:spawn') then return end
    id = tonumber(id)

    if getElementData(player, 'player:trade') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Jesteś już w trakcie wymiany')
        return
    end

    if not id then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Użycie: /accept <id>')
        return
    end

    if not pendingTrades[id] then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono zaproszenia do wymiany')
        return
    end

    local trade = pendingTrades[id]
    if trade.time < getTickCount() then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Zaproszenie do wymiany wygasło')
        pendingTrades[id] = nil
        return
    end

    if trade.player1 ~= player then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie jesteś zaproszony do tej wymiany')
        return
    end

    if getElementData(trade.player2, 'player:trade') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Gracz jest już w trakcie wymiany')
        return
    end

    setElementData(player, 'player:trade', trade.player2)
    setElementData(trade.player2, 'player:trade', player)

    exports['m-notis']:addNotification(player, 'info', 'Wymiana', ('Zaakceptowałeś zaproszenie do wymiany od gracza %s'):format(htmlEscape(getPlayerName(trade.player2))))
    exports['m-notis']:addNotification(trade.player2, 'info', 'Wymiana', ('Gracz %s zaakceptował zaproszenie do wymiany'):format(htmlEscape(getPlayerName(player))))

    pendingTrades[id] = nil
    trades[player] = {
        player = trade.player2,
        items = {},
        accepted = false,
    }
    trades[trade.player2] = {
        player = player,
        items = {},
        accepted = false,
    }

    triggerClientEvent(player, 'trade:show', resourceRoot, trade.player2)
    triggerClientEvent(trade.player2, 'trade:show', resourceRoot, player)
end)

addEventHandler('inventory:addToOffer', root, function(hash, player, itemHash, amount)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    -- local have, item = doesPlayerHaveItem(player, item)
    local item = getPlayerItemByHash(player, itemHash)
    if not item then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tego przedmiotu'})
        return
    end

    if amount <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nieprawidłowa ilość przedmiotów'})
        return
    end

    if item.amount < amount then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tyle przedmiotów'})
        return
    end

    if (item.metadata or {}).equipped then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie możesz wymieniać założonych przedmiotów'})
        return
    end

    local tradeWith = trades[player].player
    if not tradeWith then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś w trakcie wymiany'})
        return
    end

    local tradeItems = trades[player].items
    if not tradeItems[item.hash] then
        tradeItems[item.hash] = {
            amount = 0,
            metadata = item.metadata,
        }
    end

    if tradeItems[item.hash].amount + amount > item.amount then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz tyle przedmiotów'})
        return
    end

    local currentAmount = (tradeItems[item.hash] and tradeItems[item.hash].amount or 0)
    -- tradeItems[item.item] = math.min(math.max(tradeItems[item.item] + amount, 0), item.amount)
    tradeItems[item.hash] = {
        item = item.item,
        amount = math.min(math.max(currentAmount + amount, 0), item.amount),
        metadata = item.metadata,
    }

    trades[player].accepted = false
    trades[tradeWith].accepted = false
    
    updateTrade(player, tradeWith)

    exports['m-ui']:respondToRequest(hash, {status = 'success'})
end)

addEventHandler('inventory:removeFromOffer', root, function(hash, player, itemHash, amount)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local tradeWith = trades[player].player
    if not tradeWith then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś w trakcie wymiany'})
        return
    end

    local tradeItems = trades[player].items
    if not tradeItems[itemHash] then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz tego przedmiotu w ofercie'})
        return
    end

    if amount <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nieprawidłowa ilość przedmiotów'})
        return
    end

    tradeItems[itemHash].amount = math.max(tradeItems[itemHash].amount - amount, 0)
    if tradeItems[itemHash].amount == 0 then
        tradeItems[itemHash] = nil
    end

    trades[player].accepted = false
    trades[tradeWith].accepted = false

    updateTrade(player, tradeWith)

    exports['m-ui']:respondToRequest(hash, {status = 'success'})
end)

addEventHandler('inventory:cancelTrading', root, function(hash, player)
    local tradeWith = trades[player] and trades[player].player or false
    if not tradeWith then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś w trakcie wymiany'})
        return
    end

    setElementData(player, 'player:trade', false)
    setElementData(tradeWith, 'player:trade', false)

    trades[player] = nil
    trades[tradeWith] = nil

    if tradeTimers[player] and isTimer(tradeTimers[player]) then
        killTimer(tradeTimers[player])
        tradeTimers[player] = nil
    end

    triggerClientEvent(player, 'trade:hide', resourceRoot)
    triggerClientEvent(tradeWith, 'trade:hide', resourceRoot)

    exports['m-ui']:respondToRequest(hash, {status = 'success'})
end)

addEventHandler('inventory:acceptTrading', root, function(hash, player)
    local tradeWith = trades[player] and trades[player].player or false
    if not tradeWith then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś w trakcie wymiany'})
        return
    end

    trades[player].accepted = not trades[player].accepted

    if trades[player].accepted and trades[tradeWith].accepted then
        trades[player].acceptedTime = getRealTime().timestamp
        trades[tradeWith].acceptedTime = getRealTime().timestamp
    else
        trades[player].acceptedTime = false
        trades[tradeWith].acceptedTime = false

        if tradeTimers[player] and isTimer(tradeTimers[player]) then
            killTimer(tradeTimers[player])
            tradeTimers[player] = nil
        end
    end

    updateTrade(player, tradeWith)

    exports['m-ui']:respondToRequest(hash, {status = 'success'})
end)

function tradeWith(player, foundPlayer)
    if timeouts[player] and getTickCount() - timeouts[player] < 10000 then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Zaczekaj chwilę zanim ponownie zaprosisz gracza do wymiany')
        return
    end

    if getElementData(foundPlayer, 'player:uid') == getElementData(player, 'player:uid') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie możesz wymieniać się z samym sobą')
        return
    end

    local x, y, z = getElementPosition(player)
    local x2, y2, z2 = getElementPosition(foundPlayer)

    if getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 10 then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Gracz jest zbyt daleko')
        return
    end

    if getElementData(foundPlayer, 'player:trade') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Gracz jest już w trakcie wymiany')
        return
    end

    if getElementData(player, 'player:trade') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Jesteś już w trakcie wymiany')
        return
    end

    local id = getElementData(player, 'player:id')
    pendingTrades[id] = {
        player1 = foundPlayer,
        player2 = player,
        time = getTickCount() + 60000,
    }

    timeouts[player] = getTickCount()

    exports['m-notis']:addNotification(player, 'info', 'Wymiana', 'Zaproszenie do wymiany zostało wysłane')
    exports['m-notis']:addNotification(foundPlayer, 'info', 'Wymiana', ('Otrzymałeś zaproszenie do wymiany od gracza %s, wpisz /accept %d aby zaakceptować'):format(htmlEscape(getPlayerName(player)), id))
    return true
end

addEventHandler('inventory:tradeWith', root, function(hash, player, uid)
    local foundPlayer = exports['m-core']:getPlayerByUid(uid)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    tradeWith(player, foundPlayer)
    exports['m-ui']:respondToRequest(hash, {status = 'success'})
end)

function finalizeTrade(playerA, playerB)
    local uidA = getElementData(playerA, 'player:uid')
    local uidB = getElementData(playerB, 'player:uid')

    triggerClientEvent(playerA, 'trade:hideInventory', resourceRoot)
    triggerClientEvent(playerB, 'trade:hideInventory', resourceRoot)
    
    if not uidA or not uidB then return end

    exports['m-notis']:addNotification({playerA, playerB}, 'success', 'Wymiana', 'Wymiana zakończona pomyślnie')

    local beforeItemsACache = toJSON(getPlayerInventory(playerA))
    local beforeItemsBCache = toJSON(getPlayerInventory(playerB))

    local itemsA = trades[playerA].items
    local itemsB = trades[playerB].items
    local itemsACache = toJSON(itemsA)
    local itemsBCache = toJSON(itemsB)

    for hash, item in pairs(itemsA) do
        local itemData = getPlayerItemByHash(playerA, hash)
        if not itemData or itemData.amount < item.amount then
            exports['m-notis']:addNotification(playerA, 'error', 'Błąd', 'Nie posiadasz tego przedmiotu')
        elseif (itemData.metadata or {}).equipped then
            exports['m-notis']:addNotification(playerA, 'error', 'Błąd', 'Nie możesz wymieniać założonych przedmiotów')
        else
            transferItem(playerA, playerB, hash, item.amount)
        end
    end

    for hash, item in pairs(itemsB) do
        local itemData = getPlayerItemByHash(playerB, hash)
        if not itemData or itemData.amount < item.amount then
            exports['m-notis']:addNotification(playerB, 'error', 'Błąd', 'Nie posiadasz tego przedmiotu')
        elseif (itemData.metadata or {}).equipped then
            exports['m-notis']:addNotification(playerB, 'error', 'Błąd', 'Nie możesz wymieniać założonych przedmiotów')
        else
            transferItem(playerB, playerA, hash, item.amount)
        end
    end

    local afterItemsACache = toJSON(getPlayerInventory(playerA))
    local afterItemsBCache = toJSON(getPlayerInventory(playerB))

    exports['m-mysql']:execute(
        'INSERT INTO `m-trade-logs` (userA, userB, beforeItemsA, beforeItemsB, itemsA, itemsB, afterItemsA, afterItemsB) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        getElementData(playerA, 'player:uid'),
        getElementData(playerB, 'player:uid'),
        beforeItemsACache,
        beforeItemsBCache,
        itemsACache,
        itemsBCache,
        afterItemsACache,
        afterItemsBCache
    )

    local diff = ''
    
    for hash, item in pairs(itemsA) do
        -- diff = diff .. ('+ %s x%d\n'):format(getItemName(item), amount)
        diff = diff .. ('+ %s x%d (%s)\n'):format(getItemName(item.item), item.amount, hash)
    end

    for hash, item in pairs(itemsB) do
        -- diff = diff .. ('- %s x%d\n'):format(getItemName(item), amount)
        diff = diff .. ('- %s x%d (%s)\n'):format(getItemName(item.item), item.amount, hash)
    end

    exports['m-logs']:sendLog('trade', 'info', ('Gracz 🟢 (%d) %s wymienił się z graczem 🔴 (%d) %s:```diff\n%s```'):format(uidA, getPlayerName(playerA), uidB, getPlayerName(playerB), diff))

    -- reset trades
    setElementData(playerA, 'player:trade', false)
    setElementData(playerB, 'player:trade', false)

    trades[playerA] = nil
    trades[playerB] = nil
end

function updateAcceptance(player, tradeWith)
    local bothAccepted = trades[player].accepted and trades[tradeWith].accepted
    if not bothAccepted then
        if tradeTimers[player] and isTimer(tradeTimers[player]) then
            killTimer(tradeTimers[player])
            tradeTimers[player] = nil
        end
        return
    end

    if not tradeTimers[player] then
        tradeTimers[player] = setTimer(finalizeTrade, 15000, 1, player, tradeWith)
    end
end

function updateTrade(player, tradeWith)
    local items = trades[player].items
    local tradeItemsWith = trades[tradeWith].items
    local accepted = (trades[player].accepted and trades[tradeWith].accepted) and trades[player].acceptedTime or false

    triggerClientEvent(player, 'trade:update', resourceRoot, items, tradeItemsWith, accepted, {trades[player].accepted, trades[tradeWith].accepted})
    triggerClientEvent(tradeWith, 'trade:update', resourceRoot, tradeItemsWith, items, accepted, {trades[tradeWith].accepted, trades[player].accepted})

    updateAcceptance(player, tradeWith)
end

addEventHandler('onResourceStart', resourceRoot, function()
    for i, player in ipairs(getElementsByType('player')) do
        setElementData(player, 'player:trade', false)
    end
end)

addEventHandler('onPlayerQuit', root, function()
    local id = getElementData(source, 'player:id')
    if pendingTrades[id] then
        pendingTrades[id] = nil
    end
end)

function htmlEscape(s)
    return s:gsub('[<>&"]', function(c)
        return c == '<' and '&lt;' or c == '>' and '&gt;' or c == '&' and '&amp;' or '&quot;'
    end)
end