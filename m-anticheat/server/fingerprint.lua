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

local function checkFingerprintValidityResponse(query, player, serial, fingerprint)
    local result = dbPoll(query, 0)
    if not result then return end
    result = result[1]
    if not result then return end

    if result.fingerprint ~= fingerprint then
        removeElementData(player, 'player:fingerprint')
        ban(player, 'IF04', 'Fingerprint changed (`' .. fingerprint .. '`, `' .. result.fingerprint .. '`)')
        return
    end
end

local function checkFingerprintValidity(player, serial, fingerprint)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = dbQuery(checkFingerprintValidityResponse, {player, serial, fingerprint}, connection, 'SELECT `serial`, `fingerprint` FROM `m-users` WHERE `serial` = ? OR `fingerprint` = ?', serial, fingerprint)
end

addEvent('fingerprint:response', true)
addEventHandler('fingerprint:response', root, function(response)
    local originalResponse = response
    response = teaDecode(response, 'm-anticheat')
    -- outputDebugString('Fingerprint: ' .. getPlayerName(client) .. ' - ' .. response)

    local verified = verifyFingerprint(response)
    if not verified then
        ban(client, 'IF01', 'Invalid fingerprint (`' .. response .. '`, `' .. originalResponse .. '`)')
        return
    end

    -- if getResourceName(sourceResource) ~= 'm-anticheat' then
    --     ban(client, 'IF02', 'Invalid resource (`' .. getResourceName(sourceResource) .. '`)')
    --     return
    -- end

    if receivedFingerprints[client] then
        ban(client, 'IF03', 'Already sent fingerprint')
        return
    end

    checkFingerprintValidity(client, getPlayerSerial(client), originalResponse)

    receivedFingerprints[client] = response
    exports['m-core']:checkBan(client, getPlayerSerial(client), response, getPlayerIP(client))
    setElementData(client, 'player:fingerprint', response, false)
end)

addEventHandler('onPlayerResourceStart', root, function(resource)
    if getResourceName(resource) == 'm-anticheat' then
        removeElementData(source, 'player:fingerprint')
        receivedFingerprints[source] = nil
    end
end)