addEvent('jobs:endJobI')
addEvent('jobs:endJob', true)
addEvent('jobs:finishJob', true)
addEvent('jobs:startJob', true)
addEvent('jobs:finishJobLobby', true)
addEvent('jobs:colshapeHit', true)

local lobbies = {}

function startJob(job, players, minPlayers)
    local hash = generateHash()
    table.insert(lobbies, {
        job = job,
        players = players,
        minPlayers = minPlayers,
        objects = {},
        blips = {},
        markers = {},
        data = {},
        hash = hash
    })

    for i, player in ipairs(players) do
        setElementData(player, 'player:job', job)
        setElementData(player, 'player:job-hash', hash)
    end

    exports['m-notis']:addNotification(players, 'info', 'Informacja', 'Praca została rozpoczęta')
    triggerEvent('jobs:startJob', root, job, hash, players)
end

function findElementByHash(array, hash)
    for i, object in ipairs(array) do
        if object.hash == hash then
            return object
        end
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

function getLobbyByHash(hash)
    for i, lobby in ipairs(lobbies) do
        if lobby.hash == hash then
            return lobby
        end
    end
end

function setLobbyData(hash, key, value)
    local lobby = getLobbyByHash(hash)
    if not lobby then return end

    lobby.data[key] = value
    triggerClientEvent(lobby.players, 'jobs:updateData', resourceRoot, key, value)
end

function getLobbyData(hash, key)
    local lobby = getLobbyByHash(hash)
    if not lobby then return end

    return lobby.data[key]
end

function createLobbyObject(playerOrHash, model, x, y, z, rx, ry, rz, options)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local options = options or {}

    local hash = generateHash()
    local object = {
        hash = hash,
        model = model or 1337,
        position = {x or 0, y or 0, z or 0},
        rotation = {rx or 0, ry or 0, rz or 0},
        options = options
    }

    table.insert(lobby.objects, object)

    if not options.noTrigger then
        triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, {object})
    end

    return hash
end

function destroyLobbyObject(playerOrHash, objectHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local object = findElementByHash(lobby.objects, objectHash)
    if not object then return end

    triggerClientEvent(lobby.players, 'jobs:destroyObject', resourceRoot, objectHash)

    for i, object in ipairs(lobby.objects) do
        if object == object then
            table.remove(lobby.objects, i)
            break
        end
    end
end

function createLobbyBlip(playerOrHash, x, y, z, icon, visibleDistance, options)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local options = options or {}

    local hash = generateHash()
    local blip = {
        hash = hash,
        position = {x or 0, y or 0, z or 0},
        visibleDistance = visibleDistance or 9999,
        icon = icon or 41
    }

    table.insert(lobby.blips, blip)

    if not options.noTrigger then
        triggerClientEvent(lobby.players, 'jobs:updateBlips', resourceRoot, {blip})
    end

    return hash
end

function destroyLobbyBlip(playerOrHash, hash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local blip = findElementByHash(lobby.blips, hash)
    if not blip then return end

    for i, player in ipairs(lobby.players) do
        triggerClientEvent(player, 'jobs:destroyBlip', resourceRoot, hash)
    end

    for i, object in ipairs(lobby.blips) do
        if object == blip then
            table.remove(lobby.blips, i)
            break
        end
    end
end

-- local marker = exports['m-jobs']:createLobbyMarker(hash, 'cylinder', 0, 0, 0, 1, 255, 140, 0, 0, {
--     icon = 'work',
--     title = 'Wywóz śmieci',
--     desc = 'Tył śmieciarki',
--     attach = {
--         element = vehicle,
--         position = {0, -4, -0.5},
--     }
-- })
function createLobbyMarker(playerOrHash, markerType, x, y, z, size, r, g, b, a, options)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local options = options or {}

    local hash = generateHash()
    local marker = {
        hash = hash,
        position = {x or 0, y or 0, z or 0},
        size = size or 1,
        color = {r or 255, g or 255, b or 255, a or 255},
        type = markerType or 'cylinder',
        options = options
    }

    table.insert(lobby.markers, marker)

    if not options.noTrigger then
        triggerClientEvent(lobby.players, 'jobs:updateMarkers', resourceRoot, {marker})
    end

    return hash
end

function setLobbyObjectOption(playerOrHash, elementHash, key, value)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local element = findElementByHash(lobby.objects, elementHash)
    if not element then return end

    element.options[key] = value
    triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, {element})
end

function attachObjectToPlayer(playerOrHash, objectHash, player, bone, x, y, z, rx, ry, rz)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    setLobbyObjectOption(lobby.hash, objectHash, 'attachBone', {player, bone, x, y, z, rx, ry, rz})
end

function updateLobbyObjects(playerOrHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, lobby.objects)
    triggerClientEvent(lobby.players, 'jobs:updateBlips', resourceRoot, lobby.blips)
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
    triggerClientEvent(player, 'jobs:destroyMarkers', resourceRoot)
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

addEventHandler('jobs:endJobI', resourceRoot, function(hash, player)
    local job = getElementData(player, 'player:job')
    if not job then
        triggerClientEvent(player, 'jobs:endJob', resourceRoot)
        return
    end

    leaveJob(player)
    exports['m-ui']:respondToRequest(hash, {status = 'success', title = 'Sukces', message = 'Zakończono pracę'})
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

addEventHandler('jobs:colshapeHit', resourceRoot, function(objectHash)
    local lobby = getPlayerJobLobby(client)
    if not lobby then return end

    local object = findElementByHash(lobby.objects, objectHash)
    if not object then return end
    if not object.options.colshape or not object.options.colshape.event then return end

    triggerEvent(object.options.colshape.event, root, lobby.hash, client, object.hash)
end)