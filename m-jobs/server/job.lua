addEvent('jobs:endJobI', true)
addEvent('jobs:endJob', true)
addEvent('jobs:finishJob', true)
addEvent('jobs:startJob', true)
addEvent('jobs:finishJobLobby', true)

local lobbies = {}

function startJob(job, players, minPlayers)
    local hash = generateHash()
    table.insert(lobbies, {
        job = job,
        players = players,
        minPlayers = minPlayers,
        objects = {},
        blips = {},
        hash = hash
    })

    for i, player in ipairs(players) do
        setElementData(player, 'player:job', job)
    end

    exports['m-notis']:addNotification(players, 'info', 'Informacja', 'Praca została rozpoczęta')
    triggerEvent('jobs:startJob', root, job, hash, players)
end

function getPlayerJobLobby(player)
    for i, lobby in ipairs(lobbies) do
        for j, p in ipairs(lobby.players) do
            if p == player then
                return lobby
            end
        end
    end
end

function getLobbyByHash(hash)
    for i, lobby in ipairs(lobbies) do
        if lobby.hash == hash then
            return lobby
        end
    end
end

function createLobbyObject(playerOrHash, model, x, y, z, rx, ry, rz)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)

    local hash = generateHash()
    local object = {
        hash = hash,
        model = model or 1337,
        position = {x or 0, y or 0, z or 0},
        rotation = {rx or 0, ry or 0, rz or 0}
    }

    table.insert(lobby.objects, object)
    triggerClientEvent(lobby.players, 'jobs:updateObject', resourceRoot, object)

    return hash
end

function createLobbyBlip(playerOrHash, x, y, z, icon, visibleDistance)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)

    local hash = generateHash()
    local blip = {
        hash = hash,
        position = {x or 0, y or 0, z or 0},
        visibleDistance = visibleDistance or 9999,
        icon = icon or 41
    }

    table.insert(lobby.blips, blip)
    triggerClientEvent(lobby.players, 'jobs:updateBlip', resourceRoot, blip)

    return hash
end

function destroyJobLobby(lobby)
    triggerEvent('jobs:finishJobLobby', root, lobby.job, lobby.hash)

    for i, player in ipairs(lobby.players) do
        setElementData(player, 'player:job', false)
    end

    for i, lobby in ipairs(lobbies) do
        if lobby == lobby then
            table.remove(lobbies, i)
            break
        end
    end
end

function leaveJob(player)
    local lobby = getPlayerJobLobby(player)
    if not lobby then
        finishPlayerJob(player)
        return
    end

    finishPlayerJob(player)
    exports['m-notis']:addNotification(lobby.players, 'info', 'Praca', 'Gracz ' .. htmlEscape(getPlayerName(player)) .. ' zakończył pracę')

    if #lobby.players < lobby.minPlayers then
        exports['m-notis']:addNotification(lobby.players, 'error', 'Praca', 'Zbyt mało graczy na kontynuację pracy')

        for i, player in ipairs(lobby.players) do
            finishPlayerJob(player)
        end

        destroyJobLobby(lobby)
    end
end

function finishPlayerJob(player)
    local lobby = getPlayerJobLobby(player)
    local job = getElementData(player, 'player:job')
    setElementData(player, 'player:job', false)
    if lobby then
        triggerEvent('jobs:finishJob', root, job, lobby.hash, player)
    end
    triggerClientEvent(player, 'jobs:endJob', resourceRoot)
    triggerClientEvent(player, 'jobs:destroyObjects', resourceRoot)
    triggerClientEvent(player, 'jobs:destroyBlips', resourceRoot)
    exports['m-notis']:addNotification(player, 'info', 'Praca', 'Zakończono pracę')

    local lobby = getPlayerJobLobby(player)
    if not lobby then return end

    for i, p in ipairs(lobby.players) do
        if p == player then
            table.remove(lobby.players, i)
            break
        end
    end
end

addEventHandler('jobs:endJobI', resourceRoot, function()
    local job = getElementData(client, 'player:job')
    if not job then
        triggerClientEvent(client, 'jobs:endJob', resourceRoot)
        return
    end

    leaveJob(client)
end)

addEventHandler('jobs:endJob', resourceRoot, function()
    if client then
        if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Tried to start job from client')
    end
end)

addEventHandler('onPlayerQuit', root, function()
    local job = getElementData(source, 'player:job')
    if not job then return end

    leaveJob(source)
end)