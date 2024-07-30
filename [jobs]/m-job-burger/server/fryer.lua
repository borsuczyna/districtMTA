addEvent('jobs:burger:fryer')
addEvent('jobs:burger:fryerBurn')

function getFryerKey(player, fryerId)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    return ('player:%d:fryer:%d'):format(uid, fryerId)
end

function getPlayerFryerData(player, fryerId)
    local key = getFryerKey(player, fryerId)
    if not key then return end

    return exports['m-jobs']:getLobbyData(player, key)
end

function useFryer(client, objectHash, fryerId)
    local fryerData = getPlayerFryerData(client, fryerId)
    local key = getFryerKey(client, fryerId)
    
    if not fryerData then
        local cookTime = settings.cookTime.burger
        local burnTime = cookTime + settings.burgerBurnTime
        exports['m-jobs']:setPlayerLobbyTimer(client, client, 'jobs:burger:grill', cookTime, grillId)
        local burnTimer = exports['m-jobs']:setPlayerLobbyTimer(client, client, 'jobs:burger:grillBurn', burnTime, grillId, objectHash)

        exports['m-jobs']:setLobbyData(client, key, {
            start = getTickCount(),
            finish = getTickCount() + cookTime,
            burn = getTickCount() + burnTime,
            burnTimer = burnTimer
        })

        triggerClientEvent(client, 'jobs:burger:grill', resourceRoot, grillId, objectHash, {
            start = getTickCount(),
            finish = getTickCount() + cookTime,
            burn = getTickCount() + burnTime
        })
    else
        local carryData = getPlayerCarryObject(client)
        if carryData then return end

        
    end
end

-- addEventHandler('jobs:burger:fryer', resourceRoot, function(hash, client, fryerId)
--     triggerClientEvent(client, 'jobs:burger:fryerFinish', resourceRoot, fryerId)
-- end)

addEventHandler('jobs:burger:fryerBurn', resourceRoot, function(hash, client, fryerId, objectHash)
    triggerClientEvent(client, 'jobs:burger:fryerBurn', resourceRoot, fryerId, objectHash)
end)