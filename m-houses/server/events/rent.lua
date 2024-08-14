local function rentHouseForPlayer(player, houseUid, days, cost)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wystąpił błąd podczas wynajmowania domu.'})
        return
    end

    local endRentTime = getRealTime().timestamp + days * 24 * 60 * 60
    dbExec(connection, 'UPDATE `m-houses` SET `owner` = ?, `rentDate` = FROM_UNIXTIME(?) WHERE `uid` = ?', uid, endRentTime, houseUid)

    takePlayerMoney(player, cost)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Wynajęto dom na ' .. days .. ' dni za $' .. formatNumber(cost) .. '.'})

    house.owner = uid
    house.ownerName = getPlayerName(player)
    house.rentDate = getRealTime(endRentTime)
    updateHouseRent(houseUid)

    return true
end

addEvent('houses:rentHouse')
addEventHandler('houses:rentHouse', resourceRoot, function(hash, player, houseUid, days)
    days = tonumber(days)

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    if house.owner then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Ten dom jest już wynajęty.'})
        return
    end

    if days < 1 or days > 65 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nieprawidłowa ilość dni.'})
        return
    end

    local cost = house.price * days
    if getPlayerMoney(player) < cost then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz wystarczająco pieniędzy. ($' .. formatNumber(cost) .. ')'})
        return
    end

    local endRentTime = getRealTime().timestamp + days * 24 * 60 * 60
    if endRentTime > getRealTime().timestamp + 60 * 24 * 60 * 60 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie można wynająć domu na więcej niż 60 dni.'})
        return
    end
    
    local success = rentHouseForPlayer(player, houseUid, days, cost)
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wystąpił błąd podczas wynajmowania domu.'})
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Wynajęto dom na ' .. days .. ' dni za $' .. formatNumber(cost) .. '.'})
end)