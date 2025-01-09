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
        local multiplier = getPlayerCookMultiplier(client)
        local cookTime = settings.cookTime.fries / multiplier
        local burnTime = cookTime + settings.burnTime
        exports['m-jobs']:setPlayerLobbyTimer(client, client, 'jobs:burger:fryer', cookTime, fryerId)
        local burnTimer = exports['m-jobs']:setPlayerLobbyTimer(client, client, 'jobs:burger:fryerBurn', burnTime, fryerId, objectHash)

        local timeData = {
            start = getTickCount(),
            finish = getTickCount() + cookTime,
            burn = getTickCount() + burnTime,
            burnTimer = burnTimer
        }

        exports['m-jobs']:setLobbyData(client, key, timeData)
        triggerClientEvent(client, 'jobs:burger:fryer', resourceRoot, fryerId, objectHash, timeData)
    else
        local carryData = getPlayerCarryObject(client)
        if carryData then return end

        if fryerData.finish > getTickCount() then
            playClientSound(client, 'cant')
            exports['m-notis']:addNotification(client, 'warning', 'Frytkownica', 'Frytki nie są jeszcze gotowe')
            return
        end

        exports['m-jobs']:killPlayerLobbyTimer(client, client, fryerData.burnTimer)

        triggerClientEvent(client, 'jobs:burger:fryer', resourceRoot, fryerId)

        local burned = fryerData.burn < getTickCount()
        local options = {}

        if burned then
            options = {
                effect = {
                    name = 'fire',
                    density = 0.3,
                },
            }
        end

        makePlayerCarryObject(client, burned and 'burger/fries-box-burned' or 'burger/fries-box', nil, options)
        exports['m-jobs']:setLobbyData(client, key, nil)
        playClientSound(client, 'click')
    end
end

addEventHandler('jobs:burger:fryer', resourceRoot, function(hash, client, fryerId)
    triggerClientEvent(client, 'jobs:burger:fryerFinish', resourceRoot, fryerId)
end)

addEventHandler('jobs:burger:fryerBurn', resourceRoot, function(hash, client, fryerId, objectHash)
    triggerClientEvent(client, 'jobs:burger:fryerBurn', resourceRoot, fryerId, objectHash)
end)