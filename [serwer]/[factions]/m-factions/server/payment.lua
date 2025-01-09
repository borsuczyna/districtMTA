addEvent('factions:payOutPayment')

local function onMarkerHit(hitElement, matchingDimension)
    if not matchingDimension or getElementType(hitElement) ~= 'player' then return end
    local player = hitElement

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local faction = getPlayerFaction(player)
    if not faction then
        exports['m-notis']:addNotification(player, 'warning', 'Wypłaty frakcyjne', 'Nie jesteś członkiem żadnej frakcji.')
        return
    end

    triggerClientEvent(player, 'factions:openPaymentPanel', resourceRoot, {
        payment = getElementData(player, 'player:payDutyTime') * payPerMinute,
        faction = faction
    })
end

local function onMarkerLeave(leaveElement, matchingDimension)
    if not matchingDimension or getElementType(leaveElement) ~= 'player' then return end
    local player = leaveElement

    triggerClientEvent(player, 'factions:closePaymentPanel', resourceRoot)
end

function createPaymentMarker(position)
    local marker = createMarker(position[1], position[2], position[3] - 0.95, 'cylinder', 1, 0, 100, 255, 150)
    setElementData(marker, 'marker:title', 'Frakcje')
    setElementData(marker, 'marker:desc', 'Wypłaty frakcyjne')

    addEventHandler('onMarkerHit', marker, onMarkerHit)
    addEventHandler('onMarkerLeave', marker, onMarkerLeave)
end

addEventHandler('factions:payOutPayment', root, function(hash, player)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś zalogowany.'})
        return
    end

    local playerFaction = getPlayerFaction(player)
    if not playerFaction then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś członkiem żadnej frakcji.'})
        return
    end

    local payDutyTime = getElementData(player, 'player:payDutyTime')
    if not payDutyTime then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś zatrudniony w żadnej frakcji.'})
        return
    end

    local payAmount = payDutyTime * payPerMinute
    if payAmount <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz nic do wypłacenia.'})
        return
    end

    exports['m-core']:givePlayerMoney(player, 'factions', ('Wypłata z frakcji %s'):format(playerFaction), payAmount)
    setElementData(player, 'player:payDutyTime', 0)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = ('Wypłacono %s'):format(addCents(payAmount))})
end)

function addCents(amount)
    return '$' .. string.format('%0.2f', amount / 100)
end