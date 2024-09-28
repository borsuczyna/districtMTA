addEvent('bw:respawn')

local bwTimes = {}

addEventHandler('onPlayerWasted', root, function()
    bwTimes[source] = getTickCount() + 50000
end)

addEventHandler('bw:respawn', root, function(hash, player)
    if not bwTimes[player] or bwTimes[player] > getTickCount() then
        exports['m-ui']:respondToRequest(hash, {status = 'error'})
        return
    end

    spawnPlayer(player, Vector3(getElementPosition(player)), 0, getElementModel(player))
    exports['m-ui']:respondToRequest(hash, {status = 'success'})
end)