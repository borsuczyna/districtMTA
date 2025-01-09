addEvent('jobs:createLobby')
addEvent('jobs:fetchLobbies')
addEvent('jobs:quitLobby', true)
addEvent('jobs:joinLobby', true)
addEvent('jobs:kickFromLobby', true)
addEvent('jobs:startJobI', true)
addEvent('jobs:startJob')

local lobbies = {}

function playerToJSON(player)
    return {
        name = getPlayerName(player),
        uid = getElementData(player, 'player:uid')
    }
end

function lobbyToJSON(lobby)
    local owner = playerToJSON(lobby.owner)
    local players = {}

    for i, player in ipairs(lobby.players) do
        table.insert(players, playerToJSON(player))
    end

    return {
        owner = owner,
        players = players,
        maxPlayers = lobby.maxPlayers,
        job = lobby.job
    }
end

function createLobby(job, ownedPlayer, maxPlayers)
    local lobby, type = getPlayerLobby(ownedPlayer)

    if lobby then
        exports['m-notis']:addNotification(ownedPlayer, 'error', 'Błąd', 'Posiadasz lub jesteś w lobby')
        return false
    end

    local lobby = {
        owner = ownedPlayer,
        players = {ownedPlayer},
        maxPlayers = maxPlayers,
        job = job,
    }

    table.insert(lobbies, lobby)
    return true
end

function sendLobbyTrigger(lobby, trigger, ...)
    triggerClientEvent(lobby.players, trigger, root, ...)
end

function sendPlayerUID(player)
    triggerClientEvent(player, 'jobs:playerUID', resourceRoot, getElementData(player, 'player:uid'))
end

function getPlayerLobby(player)
    for i, lobby in ipairs(lobbies) do
        if lobby.owner == player then
            return lobby, 'owner'
        end

        for j, p in ipairs(lobby.players) do
            if p == player then
                return lobby, 'player'
            end
        end
    end

    return nil
end

function quitLobby(player)
    local lobby, type = getPlayerLobby(player)
    if not lobby then return false end

    if type == 'owner' then
        return closeLobby(player)
    else
        for i, p in ipairs(lobby.players) do
            if p == player then
                table.remove(lobby.players, i)
                break
            end
        end

        exports['m-notis']:addNotification(lobby.players, 'info', 'Lobby', 'Gracz ' .. htmlEscape(getPlayerName(player)) .. ' opuścił lobby')
        updateLobby(lobby.owner)
    end

    triggerClientEvent(player, 'jobs:lobbyLeft', resourceRoot, true)
    exports['m-notis']:addNotification(player, 'success', 'Sukces', 'Opuszczono lobby')

    return true
end

function closeLobby(player, started, players)
    local lobby, type = getPlayerLobby(player)
    if not lobby then return false end

    if type == 'owner' then
        if not started then
            sendLobbyTrigger(lobby, 'jobs:lobbyClosed')
        else
            sendLobbyTrigger(lobby, 'jobs:jobStarted', true, players)
        end

        for i, l in ipairs(lobbies) do
            if l == lobby then
                table.remove(lobbies, i)
                break
            end
        end
    else
        return quitLobby(player)
    end

    return true
end

function updateLobby(player)
    local lobby, type = getPlayerLobby(player)
    if not lobby then return false end

    sendLobbyTrigger(lobby, 'jobs:lobbyUpdated', lobbyToJSON(lobby))
    return true
end

addEventHandler('jobs:fetchLobbies', resourceRoot, function(hash, player, job)
    if not jobs[job] then return end
    
    local filtered = {}

    for i, lobby in ipairs(lobbies) do
        if lobby.job == job then
            table.insert(filtered, lobbyToJSON(lobby))
        end
    end

    -- triggerClientEvent(client, 'jobs:fetchLobbiesResult', resourceRoot, filtered)
    exports['m-ui']:respondToRequest(hash, {status = 'success', lobbies = filtered})
end)

addEventHandler('jobs:createLobby', resourceRoot, function(hash, client, job)
    if not jobs[job] then return end

    local success = createLobby(job, client, jobs[job].lobbySize)
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd', message = 'Posiadasz lub jesteś w lobby'})
        return
    end
    
    exports['m-ui']:respondToRequest(hash, {status = 'success', title = 'Sukces', message = 'Lobby zostało utworzone'})
    sendPlayerUID(client)
    updateLobby(client)
end)

addEventHandler('jobs:quitLobby', resourceRoot, function()
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `jobs:quitLobby` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    quitLobby(client)
    -- triggerClientEvent(client, 'jobs:lobbyLeft', resourceRoot, success)
end)

addEventHandler('jobs:joinLobby', resourceRoot, function(ownerUid)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `jobs:joinLobby` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    local owner = exports['m-core']:getPlayerByUid(ownerUid)
    if not owner then return end

    local lobby, type = getPlayerLobby(client)
    if lobby then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Posiadasz lub jesteś w lobby')
        triggerClientEvent(client, 'jobs:lobbyJoinResult', resourceRoot, false)
        return
    end

    local lobby, type = getPlayerLobby(owner)
    if not lobby then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Lobby nie istnieje, odśwież stronę')
        triggerClientEvent(client, 'jobs:lobbyJoinResult', resourceRoot, false)
        return
    end

    if type ~= 'owner' then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Gracz nie jest właścicielem lobby')
        triggerClientEvent(client, 'jobs:lobbyJoinResult', resourceRoot, false)
        return
    end

    if owner == client then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Nie możesz dołączyć do swojego lobby')
            triggerClientEvent(client, 'jobs:lobbyJoinResult', resourceRoot, false)
        return
    end

    if #lobby.players >= lobby.maxPlayers then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Lobby jest pełne')
        triggerClientEvent(client, 'jobs:lobbyJoinResult', resourceRoot, false)
        return
    end

    sendLobbyTrigger(lobby, 'jobs:playerJoined', playerToJSON(client))
    table.insert(lobby.players, client)
    updateLobby(client)

    exports['m-notis']:addNotification(client, 'success', 'Sukces', 'Dołączono do lobby')
    triggerClientEvent(client, 'jobs:lobbyJoinResult', resourceRoot, true)
end)

addEventHandler('jobs:kickFromLobby', resourceRoot, function(uid)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `jobs:kickFromLobby` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    local player = exports['m-core']:getPlayerByUid(uid)
    if not player then
        triggerClientEvent(client, 'jobs:kickFromLobbyResult', resourceRoot, false)
        return
    end

    local lobby, type = getPlayerLobby(client)
    if not lobby then
        triggerClientEvent(client, 'jobs:kickFromLobbyResult', resourceRoot, false)
        return
    end

    if type ~= 'owner' then
        exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Nie jesteś właścicielem lobby')
        triggerClientEvent(client, 'jobs:kickFromLobbyResult', resourceRoot, false)
        return
    end

    for i, p in ipairs(lobby.players) do
        if p == player then
            table.remove(lobby.players, i)
            break
        end
    end

    exports['m-notis']:addNotification(lobby.players, 'info', 'Lobby', 'Gracz został wyrzucony')
    triggerClientEvent(player, 'jobs:lobbyLeft', resourceRoot, true)
    exports['m-notis']:addNotification(player, 'error', 'Lobby', 'Zostałeś wyrzucony z lobby')
    updateLobby(lobby.owner)

    triggerClientEvent(client, 'jobs:kickFromLobbyResult', resourceRoot, true)
end)

addEventHandler('jobs:startJobI', resourceRoot, function(job)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `jobs:startJobI` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    local jobData = jobs[job]
    if not jobData then
        triggerClientEvent(client, 'jobs:jobStarted', resourceRoot, false)
        return
    end

    if not jobData.coop then
        startJob(job, {client})
    else
        local lobby, type = getPlayerLobby(client)
        if not lobby then
            exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Nie jesteś w lobby')
            triggerClientEvent(client, 'jobs:jobStarted', resourceRoot, false)
            return
        end

        if type ~= 'owner' then
            exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Nie jesteś właścicielem lobby')
            triggerClientEvent(client, 'jobs:jobStarted', resourceRoot, false)
            return
        end

        if #lobby.players < jobData.minLobbySize then
            exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Minimalna ilość graczy do rozpoczęcia tej pracy to ' .. jobData.minLobbySize)
            triggerClientEvent(client, 'jobs:jobStarted', resourceRoot, false)
            return
        end

        startJob(job, lobby.players, jobData.minLobbySize)
        closeLobby(client, true, lobby.players)
    end
end)

addEventHandler('onPlayerQuit', root, function()
    quitLobby(source)
end)