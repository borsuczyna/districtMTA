addEvent('ui:fetchData', true)
addEvent('ui:logError')

local requests = {}
local lastHashes = {}
local requestTimeout = 0

local function fetchRequest(client, triggerName, data)
    if not triggerEvent(triggerName, root, data.hash, client, unpack(data.arguments)) then
        triggerClientEvent(client, 'ui:fetchDataResponse', resourceRoot, data.hash)
    end
end

local function generateHash()
    local chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
    local hash = ''
    for i = 1, 24 do
        local charPos = math.random(1, #chars)
        hash = hash .. chars:sub(charPos, charPos)
        if i % 6 == 0 and i < 24 then
            hash = hash .. '-'
        end
    end
    return hash
end

addEventHandler('ui:fetchData', resourceRoot, function(data)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `ui:fetchData` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    data = teaDecode(data, 'keep calm and play district mta')
    data = fromJSON(data)

    if not client then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    if lastHashes[data.hash] and getTickCount() - lastHashes[data.hash].tick < 600000 then
        exports['m-anticheat']:ban(client, 'Trigger hack', ('Trigger hash resent ("%s", "%s")'):format(data.hash, data.parentResource .. ':' .. data.endpoint))
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

addEventHandler('ui:logError', resourceRoot, function(hash, player, message)
    if #toJSON(message) > 1000 then return end
    
    local uid = getElementData(player, 'player:uid') or -1
    local errorHash = generateHash()

    respondToRequest(hash, {status = 'success', errorHash = errorHash})
    
    exports['m-notis']:addNotification(player, 'error', 'Błąd interfejsu', ('Wystąpił błąd w interfejsie.<br>Informacje o błędzie zostały wysłane do serwera.<br>Numer zgłoszenia: <a class="error-hash" href="#" onclick="copyErrorHash(\'%s\')">%s</a>'):format(errorHash, errorHash))
    exports['m-mysql']:execute('INSERT INTO `m-ui-errors` SET `hash` = ?, `player` = ?, `message` = ?', errorHash, uid, toJSON(message))
end)

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