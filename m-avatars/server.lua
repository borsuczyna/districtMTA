local awaitingRequests = {}
local requestedAvatars = {}
local avatars = {}
local avatarUrls = {}

function sendPlayerAvatar(player, uid, avatar)
    if not isElement(player) then return end
    triggerClientEvent(player, 'avatars:receivePlayerAvatar', root, uid, avatar)
end

function returnPlayerAvatar(responseData, responseInfo, uid)
    if not responseInfo.success then return end
    if not responseData then return end

    local size = #responseData
    local maxSize = 4 * 1024 * 1024
    if size > maxSize then return end
    
    avatars[uid] = responseData
    if not awaitingRequests[uid] then return end

    for i, player in ipairs(awaitingRequests[uid]) do
        sendPlayerAvatar(player, uid, responseData)
    end

    awaitingRequests[uid] = nil
    requestedAvatars[uid] = nil
end

function getPlayerFromAvatarUrl(url)
    for uid, avatar in pairs(avatarUrls) do
        if avatar == url then
            return exports['m-core']:getPlayerByUid(uid)
        end
    end
end

function updateRequests()
    local maxSize = 4 * 1024 * 1024
    local requests = getRemoteRequests()
    
    for i, request in ipairs(requests) do
        local info = getRemoteRequestInfo(request)
        if info.queue == 'avatars' and info.bytesTotal ~= 0 and info.bytesTotal > maxSize then
            abortRemoteRequest(request)

            -- local player = getPlayerFromAvatarUrl(info.url)
            -- exports['m-notis']:addNotification(player, 'error', 'Avatar', 'Twój avatar jest zbyt wielki (max. 4MB)')
        end
    end
end

function getPlayerAvatar(uid, avatar)
    fetchRemote(avatar, {
        queueName = 'avatars',
        connectTimeout = 10000,
        connectionAttempts = 1,
    }, returnPlayerAvatar, {uid})

    updateRequests()
end

function table.includes(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function getAvatarFromDatabaseResult(queryResult, client, uid)
    local result, rows, lastId = dbPoll(queryResult, 0)
    if not result then return end

    if #result == 0 then return end

    local avatar = result[1].avatar
    if not avatar then return end

    avatarUrls[uid] = avatar
    requestedAvatars[uid] = true
    table.insert(awaitingRequests[uid], client)
    
    getPlayerAvatar(uid, avatar)
end

function getPlayerAvatarFromDatabase(client, uid)
    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    dbQuery(getAvatarFromDatabaseResult, {client, uid}, connection, 'SELECT avatar FROM `m-users` WHERE uid = ?', uid)
end

addEvent('avatars:getPlayerAvatar', true)
addEventHandler('avatars:getPlayerAvatar', resourceRoot, function(uid)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `avatars:getPlayerAvatar` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    if requestedAvatars[uid] then return end

    if not awaitingRequests[uid] then
        awaitingRequests[uid] = {}
    end
    if table.includes(awaitingRequests[uid], client) then return end

    local player = exports['m-core']:getPlayerByUid(uid)
    if not player then
        getPlayerAvatarFromDatabase(client, uid)
        return
    end
    
    local avatar = getElementData(player, 'player:avatar')
    if not avatar then return end
    
    if avatarUrls[uid] ~= avatar then
        avatars[uid] = nil
    end

    if avatars[uid] then
        sendPlayerAvatar(client, uid, avatars[uid])
        return
    end

    avatarUrls[uid] = avatar
    requestedAvatars[uid] = true
    table.insert(awaitingRequests[uid], client)
    
    getPlayerAvatar(uid, avatar)
end)

addEventHandler('onPlayerQuit', root, function()
    local uid = getElementData(source, 'player:uid')
    if not uid then return end

    avatars[uid] = nil
    avatarUrls[uid] = nil
    requestedAvatars[uid] = nil
    awaitingRequests[uid] = nil
end)

setTimer(updateRequests, 1000, 0)