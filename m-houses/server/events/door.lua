addEvent('houses:toggleDoorLock')
addEventHandler('houses:toggleDoorLock', resourceRoot, function(hash, player, houseUid)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    local canChange = house.owner == uid or table.find(house.sharedPlayers, uid)
    if not canChange then 
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś właścicielem tego domu.'})
        return
    end

    house.locked = not house.locked

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Wystąpił błąd'})
        return
    end

    dbExec(connection, 'UPDATE `m-houses` SET `locked` = ? WHERE `uid` = ?', house.locked and 1 or 0, houseUid)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = house.locked and 'Zamknięto drzwi' or 'Otworzono drzwi'})
end)