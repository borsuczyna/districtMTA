addEvent('houses:kickGuests')
addEventHandler('houses:kickGuests', resourceRoot, function(hash, player, houseUid)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    local canChange = house.owner == uid
    if not canChange then 
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś właścicielem tego domu.'})
        return
    end

    removePlayersFromHouse(houseUid, client)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Wyrzucono wszystkich gości'})
end)