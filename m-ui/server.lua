local requests = {}

addEvent('ui:fetchData', true)
addEventHandler('ui:fetchData', resourceRoot, function(data)
    if not client then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    local triggerName = data.parentResource .. ':' .. data.endpoint
    requests[data.hash] = client

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