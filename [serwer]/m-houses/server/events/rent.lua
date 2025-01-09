local function rentHouseForPlayer(player, houseUid, days, cost)
    days = tonumber(days)
    if days % 1 ~= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nieprawidłowa ilość dni.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return print(1) end

    local house = houses[houseUid]
    if not house then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wystąpił błąd podczas wynajmowania domu.'})
        return
    end

    local endRentTime = getRealTime().timestamp + days * 24 * 60 * 60
    if house.owner then
        endRentTime = house.rentDate.timestamp + days * 24 * 60 * 60
    else
        if #getPlayerOwnedHouses(player) >= 3 then
            exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Możesz wynająć maksymalnie 3 domy.'})
            return
        end
    end
    
    dbExec(connection, 'UPDATE `m-houses` SET `owner` = ?, `rentDate` = FROM_UNIXTIME(?) WHERE `uid` = ?', uid, endRentTime, houseUid)

    exports['m-core']:givePlayerMoney(player, 'house', 'Wynajem domu ' .. house.streetName .. ' na ' .. days .. ' dni', -cost * 100)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Wynajęto dom na ' .. days .. ' dni za $' .. formatNumber(cost) .. '.'})
    exports['m-logs']:sendLog('houses', 'info', ('Gracz %s wynajął dom %s na %s dni za %s$'):format(getPlayerName(player), house.streetName, days, cost))

    house.owner = uid
    house.ownerName = getPlayerName(player)
    house.rentDate = getRealTime(endRentTime)
    updateHouseRent(houseUid)

    return true
end

addEvent('houses:rentHouse')
addEventHandler('houses:rentHouse', resourceRoot, function(hash, player, houseUid, days)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    days = tonumber(days)
    if days % 1 ~= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nieprawidłowa ilość dni.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    if house.owner and house.owner ~= uid then
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
    local isNewRent = true
    if house.owner then
        endRentTime = house.rentDate.timestamp + days * 24 * 60 * 60
        isNewRent = false
    end

    if endRentTime > getRealTime().timestamp + 60 * 24 * 60 * 60 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie można wynająć domu na więcej niż 60 dni.'})
        return
    end
    
    local success = rentHouseForPlayer(player, houseUid, days, cost)
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wystąpił błąd podczas wynajmowania domu.'})
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Wynajęto dom na ' .. days .. ' dni za $' .. formatNumber(cost) .. '.'})

    if isNewRent then
        removePlayersFromHouse(houseUid)
        addDefaultHouseFurniture(houseUid)
    end
end)

addEvent('houses:cancelRentHouse')
addEventHandler('houses:cancelRentHouse', resourceRoot, function(hash, player, houseUid)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    if not house.owner or house.owner ~= uid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie wynajmujesz tego domu.'})
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wystąpił błąd podczas anulowania wynajmu domu.'})
        return
    end

    dbExec(connection, 'UPDATE `m-houses` SET `owner` = NULL, `rentDate` = "1970-01-01 00:00:00" WHERE `uid` = ?', houseUid)

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Anulowano wynajem domu.'})
    exports['m-logs']:sendLog('houses', 'info', ('Gracz %s anulował wynajem domu %s'):format(getPlayerName(player), house.streetName))
    removePlayersFromHouse(houseUid)
    removeAllHouseFurniture(houseUid)
    removeAllHouseTextures(houseUid)

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = 'UPDATE `m-houses` SET `owner` = NULL, `sharedPlayers` = "" WHERE `uid` = ?'
    dbExec(connection, query, houseUid)

    house.owner = nil
    house.ownerName = nil
    house.rentDate = getRealTime(0)
    house.sharedPlayers = {}
    house.sharedPlayerNames = {}
    updateHouseRent(houseUid)
end)