local awaitingRequests = {}
local requestedAvatars = {}
local avatars = {}
local avatarUrls = {}

function sendPlayerAvatar(player, uid, avatar)
    if not isElement(player) then return end
    triggerClientEvent(player, 'avatars:receivePlayerAvatar', resourceRoot, uid, avatar)
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

addEvent('avatars:getPlayerAvatar', true)
addEventHandler('avatars:getPlayerAvatar', resourceRoot, function(uid)
    if getElementData(client, 'player:triggerLocked') then return end

    local player = exports['m-core']:getPlayerByUid(uid)
    if not player then return end

    if requestedAvatars[uid] then return end

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
    if not awaitingRequests[uid] then
        awaitingRequests[uid] = {}
    end
    if table.includes(awaitingRequests[uid], client) then return end
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