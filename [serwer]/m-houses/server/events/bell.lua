local lastRing = {}

addEvent('houses:ringBell')
addEventHandler('houses:ringBell', resourceRoot, function(hash, player, houseUid)
    if lastRing[player] and getTickCount() - lastRing[player] < 60000 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Dzwonkiem można dzwonić co minutę.'})
        return
    end

    lastRing[player] = getTickCount()

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local house = houses[houseUid]
    if not house then return end
    
    local playersInside = getPlayersInHouse(houseUid)
    triggerClientEvent(playersInside, 'houses:ringBell', resourceRoot, house.position, player)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zadzwoniono do drzwi.'})
end)