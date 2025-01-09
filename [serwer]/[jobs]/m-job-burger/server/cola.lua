addEvent('jobs:burger:cola')

function getColaKey(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    return ('player:%d:cola'):format(uid)
end

function getCola(player, objectHash)
    local key = getColaKey(player)
    if not key then return end
    
    local cookTime = settings.cookTime.cola
    local renewTime = cookTime + settings.cookTime.colaRenew
    local timeData = {
        start = getTickCount(),
        finish = getTickCount() + cookTime,
        renew = getTickCount() + renewTime
    }

    exports['m-jobs']:setLobbyData(player, key, timeData)
    triggerClientEvent(player, 'jobs:burger:cola', resourceRoot, objectHash, timeData)

    exports['m-jobs']:setPlayerLobbyTimer(client, client, 'jobs:burger:cola', cookTime)
    playClientSound(player, 'click')
end

function useCola(client, objectHash)
    local carrying = getPlayerCarryObject(client)
    if carrying then return end

    local key = getColaKey(client)
    if not key then return end

    local colaData = exports['m-jobs']:getLobbyData(client, key)

    if colaData and colaData.renew > getTickCount() then
        playClientSound(client, 'cant')
        exports['m-notis']:addNotification(client, 'warning', 'Cola', 'Cola jeszcze się nie schłodziła')
        return
    end

    getCola(client, objectHash)
end

addEventHandler('jobs:burger:cola', resourceRoot, function(hash, client)
    useCarryItem(client, 'cola')
end)