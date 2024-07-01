local receivedFingerprints = {}

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return false
end

local function verifyFingerprint(fingerprint)
    local charsTable = {
        [2] = {'v', 'e', 'k'},
        [5] = {'z', 'n', 'm'},
        [8] = {'m', 'b'},
        [10] = {'o'},
        [12] = {'g', 'c', 'f', 'e', 'v'},
        [15] = {'d', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y'},
    }

    for index, chars in pairs(charsTable) do
        local char = fingerprint:sub(index + 1, index + 1)
        if not table.find(chars, char) then
            return false
        end
    end

    return true
end

addEvent('fingerprint:response', true)
addEventHandler('fingerprint:response', root, function(response)
    local originalResponse = response
    response = teaDecode(response, 'm-anticheat')
    local verified = verifyFingerprint(response)
    if not verified then
        ban(client, 'IF01', 'Invalid fingerprint (`' .. response .. '`, `' .. originalResponse .. '`)')
        return
    end

    if getResourceName(sourceResource) ~= 'm-anticheat' then
        ban(client, 'IF02', 'Invalid resource (`' .. getResourceName(sourceResource) .. '`)')
        return
    end

    if receivedFingerprints[client] then
        ban(client, 'IF03', 'Already sent fingerprint')
        return
    end

    receivedFingerprints[client] = response
    setElementData(client, 'player:fingerprint', response)
end)

addEventHandler('onElementDataChange', root, function(dataName, oldValue)
    if dataName == 'player:fingerprint' and client then
        ban(client, 'IF04', 'Tried to change fingerprint (`' .. getElementData(client, 'player:fingerprint') .. '`)')
    end
end)

addEventHandler('onPlayerResourceStart', root, function(resource)
    if getResourceName(resource) == 'm-anticheat' then
        removeElementData(source, 'player:fingerprint')
        print('Resource started: ' .. getResourceName(resource))
    end
end)