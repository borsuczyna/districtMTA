local requests = {}
local lastHashes = {}

addEvent('ui:fetchData', true)
addEventHandler('ui:fetchData', resourceRoot, function(data)
    data = teaDecode(data, 'keep yourself and play district mta')
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

    if not triggerEvent(triggerName, root, data.hash, client, unpack(data.arguments)) then
        triggerClientEvent(client, 'ui:fetchDataResponse', resourceRoot, data.hash)
    end
end)

function respondToRequest(hash, response)
    if not requests[hash] then return end
    
    local client = requests[hash]
    requests[hash] = nil

    triggerClientEvent(client, 'ui:fetchDataResponse', resourceRoot, hash, response)
end