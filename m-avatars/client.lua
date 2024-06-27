local avatars = {}
local playerUids = {}
local defaultAvatar = ':m-avatars/data/user.png'

addEvent('avatars:receivePlayerAvatar', true)
addEvent('avatars:onPlayerAvatarChange', true)

function getPlayerAvatar(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return defaultAvatar end

    playerUids[uid] = player

    if not avatars[uid] then
        triggerServerEvent('avatars:getPlayerAvatar', resourceRoot, uid)
    end

    return avatars[uid] or defaultAvatar
end

addEventHandler('avatars:receivePlayerAvatar', resourceRoot, function(uid, avatar)
    local player = playerUids[uid]
    if not player then return end

    avatars[uid] = base64Encode(avatar)
    triggerEvent('avatars:onPlayerAvatarChange', root, player, avatars[uid])
end)

addEventHandler('onClientPlayerQuit', root, function()
    local uid = getElementData(source, 'player:uid')
    if not uid then return end

    avatars[uid] = nil
    playerUids[uid] = nil
end)

addEventHandler('onClientElementDataChange', root, function(key, oldValue)
    if key == 'player:avatar' then
        local uid = getElementData(source, 'player:uid')
        local avatar = getElementData(source, 'player:avatar')
        if not uid or not avatars[uid] then return end

        if avatars[uid] then
            avatars[uid] = nil
            triggerServerEvent('avatars:getPlayerAvatar', resourceRoot, uid)
        end
    end
end)