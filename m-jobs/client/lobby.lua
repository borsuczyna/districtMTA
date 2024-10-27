addEvent('jobs:quitLobby', true)
addEvent('jobs:lobbyLeft', true)
addEvent('jobs:lobbyClosed', true)
addEvent('jobs:lobbyUpdated', true)
addEvent('jobs:playerUID', true)
addEvent('jobs:joinLobby', true)
addEvent('jobs:lobbyJoinResult', true)
addEvent('jobs:playerJoined', true)
addEvent('jobs:kickFromLobby', true)
addEvent('jobs:kickFromLobbyResult', true)
addEvent('jobs:startJobI', true)

local inLobby = false

function isInLobby()
    return inLobby
end

addEventHandler('jobs:quitLobby', root, function()
    if not jobGui then return end

    triggerServerEvent('jobs:quitLobby', resourceRoot)
end)

addEventHandler('jobs:lobbyLeft', resourceRoot, function(success)
    if not jobGui then return end

    exports['m-ui']:triggerInterfaceEvent('jobs', 'lobby-left', success)
    inLobby = not success
end)

addEventHandler('jobs:lobbyClosed', resourceRoot, function()
    if not jobGui then return end

    exports['m-ui']:triggerInterfaceEvent('jobs', 'lobby-closed')
    inLobby = false
end)

addEventHandler('jobs:lobbyUpdated', resourceRoot, function(lobby)
    if not jobGui then return end

    exports['m-ui']:setInterfaceData('jobs', 'lobby', lobby)
end)

addEventHandler('jobs:playerUID', resourceRoot, function(uid)
    if not jobGui then return end

    exports['m-ui']:setInterfaceData('jobs', 'player-uid', uid)
end)

addEventHandler('jobs:joinLobby', root, function(ownerUid)
    if not jobGui then return end

    triggerServerEvent('jobs:joinLobby', resourceRoot, ownerUid)
end)

addEventHandler('jobs:lobbyJoinResult', resourceRoot, function(success)
    if not jobGui then return end

    exports['m-ui']:triggerInterfaceEvent('jobs', 'lobby-join-result', success)
    inLobby = success
end)

addEventHandler('jobs:playerJoined', resourceRoot, function(player)
    if not jobGui then return end

    exports['m-ui']:triggerInterfaceEvent('jobs', 'player-joined', player)
end)

addEventHandler('jobs:kickFromLobby', root, function(uid)
    if not jobGui then return end

    triggerServerEvent('jobs:kickFromLobby', resourceRoot, uid)
end)

addEventHandler('jobs:kickFromLobbyResult', resourceRoot, function(success)
    if not jobGui then return end

    exports['m-ui']:triggerInterfaceEvent('jobs', 'kick-from-lobby-result', success)
end)

addEventHandler('jobs:startJobI', root, function()
    if not jobGui then return end

    triggerServerEvent('jobs:startJobI', resourceRoot, jobGui)
end)

function closeLobby()
    if not jobGui then return end

    triggerServerEvent('jobs:quitLobby', resourceRoot)
end