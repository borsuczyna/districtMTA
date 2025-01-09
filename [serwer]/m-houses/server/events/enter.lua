addEvent('houses:enterHouse')
addEventHandler('houses:enterHouse', resourceRoot, function(hash, player, houseUid)
    local limited, time = isPlayerRateLimited(player)
    if limited then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = ('Zbyt szybko wykonujesz akcje, odczekaj %s sekund.'):format(time)})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end

    local canEnter = not house.owner or house.owner == uid or table.find(house.sharedPlayers, uid) or not house.locked
    local isInside = getElementData(player, 'player:house')
    if not canEnter and not isInside then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz dostępu do tego domu.'})
        return
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success'})
    enterHouse(player, houseUid)
end)