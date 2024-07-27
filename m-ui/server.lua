local requests = {}
local lastHashes = {}
local requestTimeout = 0

local function fetchRequest(client, triggerName, data)
    if not triggerEvent(triggerName, root, data.hash, client, unpack(data.arguments)) then
        triggerClientEvent(client, 'ui:fetchDataResponse', resourceRoot, data.hash)
    end
end

addEvent('ui:fetchData', true)
addEventHandler('ui:fetchData', resourceRoot, function(data)
    data = teaDecode(data, 'keep calm and play district mta')
    data = fromJSON(data)

    if not client then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    if lastHashes[data.hash] and getTickCount() - lastHashes[data.hash].tick < 600000 then
        exports['m-anticheat']:ban(client, ('Trigger hash resent ("%s", "%s")'):format(data.hash, data.parentResource .. ':' .. data.endpoint))
        return
    end

    local triggerName = data.parentResource .. ':' .. data.endpoint
    requests[data.hash] = client
    lastHashes[data.hash] = {client = client, tick = getTickCount()}

    if requestTimeout > 0 then
        setTimer(fetchRequest, requestTimeout, 1, client, triggerName, data)
    else
        fetchRequest(client, triggerName, data)
    end
end)

function respondToRequest(hash, response)
    if not requests[hash] then return end
    
    local client = requests[hash]
    requests[hash] = nil

    triggerClientEvent(client, 'ui:fetchDataResponse', resourceRoot, hash, response)
end

-- add for ACL admin only setrequesttimeout
addCommandHandler('setrequesttimeout', function(player, command, timeout)
    local account = getPlayerAccount(player)
    if not isObjectInACLGroup('user.' .. getAccountName(account), aclGetGroup('Admin')) then
        return outputChatBox('Brak uprawnień', player, 255, 0, 0)
    end

    if not tonumber(timeout) then
        return outputChatBox('Użycie: /setrequesttimeout <timeout>', player, 255, 0, 0)
    end

    requestTimeout = tonumber(timeout) or 500
    outputChatBox(('Zmieniono timeout zapytań do %dms'):format(requestTimeout), player, 0, 255, 0)
end)