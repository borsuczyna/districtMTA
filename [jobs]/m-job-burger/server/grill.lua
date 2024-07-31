addEvent('jobs:burger:grill')
addEvent('jobs:burger:grillBurn')

function getGrillKey(player, grillId)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    return ('player:%d:grill:%d'):format(uid, grillId)
end

function getPlayerGrillData(player, grillId)
    local key = getGrillKey(player, grillId)
    if not key then return end

    return exports['m-jobs']:getLobbyData(player, key)
end

function useGrill(client, objectHash, grillId)
    local grillData = getPlayerGrillData(client, grillId)
    local key = getGrillKey(client, grillId)
    
    local carryData = getPlayerCarryObject(client)
    
    if not grillData then
        if not carryData or carryData.model ~= 'burger/meat' then return end

        stopPlayerCarryObject(client)
        
        local multiplier = getPlayerCookMultiplier(client)
        local cookTime = settings.cookTime.burger / multiplier
        local burnTime = cookTime + settings.burnTime
        exports['m-jobs']:setPlayerLobbyTimer(client, client, 'jobs:burger:grill', cookTime, grillId)
        local burnTimer = exports['m-jobs']:setPlayerLobbyTimer(client, client, 'jobs:burger:grillBurn', burnTime, grillId, objectHash)

        local timeData = {
            start = getTickCount(),
            finish = getTickCount() + cookTime,
            burn = getTickCount() + burnTime,
            burnTimer = burnTimer
        }

        exports['m-jobs']:setLobbyData(client, key, timeData)
        triggerClientEvent(client, 'jobs:burger:grill', resourceRoot, grillId, objectHash, timeData)
    else
        if carryData then return end
        if grillData.finish > getTickCount() then
            playClientSound(client, 'cant')
            exports['m-notis']:addNotification(client, 'warning', 'Grill', 'Burger nie jest jeszcze gotowy')
            return
        end

        exports['m-jobs']:killPlayerLobbyTimer(client, client, grillData.burnTimer)

        triggerClientEvent(client, 'jobs:burger:grill', resourceRoot, grillId)
        
        local burned = grillData.burn < getTickCount()
        local options = {}

        if burned then
            options = {
                effect = {
                    name = 'fire',
                    density = 0.3,
                }
            }
        end

        makePlayerCarryObject(client, burned and 'burger/meat-overcooked' or 'burger/meat-cooked', nil, options)
        exports['m-jobs']:setLobbyData(client, key, nil)
        playClientSound(client, 'click')
    end
end

function useBun(client, objectHash)
    local carryData = getPlayerCarryObject(client)
    if not carryData or carryData.model ~= 'burger/meat-cooked' then return end

    stopPlayerCarryObject(client)
    makePlayerCarryObject(client, 'burger/burger-in-packaging')
    playClientSound(client, 'click')
end

addEventHandler('jobs:burger:grill', resourceRoot, function(hash, client, grillId)
    triggerClientEvent(client, 'jobs:burger:grilled', resourceRoot, grillId)
end)

addEventHandler('jobs:burger:grillBurn', resourceRoot, function(hash, client, grillId, objectHash)
    triggerClientEvent(client, 'jobs:burger:grillBurn', resourceRoot, grillId, objectHash)
end)