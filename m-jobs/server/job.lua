addEvent('jobs:endJobI', true)
addEvent('jobs:endJob', true)

local lobbies = {}

function startJob(job, players, minPlayers)
    table.insert(lobbies, {
        job = job,
        players = players,
        minPlayers = minPlayers,
        objects = {}
    })

    for i, player in ipairs(players) do
        setElementData(player, 'player:job', job)
    end
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

function createLobbyObject(player, model, x, y, z, rx, ry, rz)
    local lobby = getPlayerJobLobby(player)
    if not lobby then return end

    local hash = generateHash()
    local object = {
        hash = hash,
        model = model,
        position = Vector3(x, y, z),
        rotation = Vector3(rx, ry, rz)
    }

    table.insert(lobby.objects, object)
    triggerClientEvent(lobby.players, 'jobs:updateObject', resourceRoot, object)

    return hash
end

function destroyJobLobby(lobby)
    triggerClientEvent(lobby.players, 'jobs:destroyObjects', resourceRoot)

    for i, player in ipairs(lobby.players) do
        setElementData(player, 'player:job', false)
    end

    for i, lobby in ipairs(lobbies) do
        if lobby == lobby then
            table.remove(lobbies, i)
            break
        end
    end

    print('Destroyed lobby')
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
    setElementData(player, 'player:job', false)
    triggerEvent('jobs:finishJob', player)
    triggerClientEvent(player, 'jobs:endJob', resourceRoot)
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
    if not job then return end

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