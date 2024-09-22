addEvent('jobs:endJobI')
addEvent('jobs:endJob')
addEvent('jobs:finishJob')
addEvent('jobs:startJob')
addEvent('jobs:finishJobLobby')
addEvent('jobs:colshapeHit', true)
addEvent('jobs:markerHit', true)

local lobbies = {}
local updateRequested = {}

function startJob(job, players, minPlayers)
    local hash = generateHash()
    table.insert(lobbies, {
        job = job,
        players = players,
        minPlayers = minPlayers,
        objects = {},
        blips = {},
        markers = {},
        peds = {},
        data = {},
        timers = {},
        playerTimers = {},
        hash = hash
    })

    for i, player in ipairs(players) do
        setElementData(player, 'player:job', job)
        setElementData(player, 'player:job-hash', hash)
        setElementData(player, 'player:job-players', players)
        setElementData(player, 'player:job-end', jobs[job].canEndWithGui)
        setElementData(player, 'player:job-earned', 0)
        setElementData(player, 'player:job-start', getRealTime().timestamp)
    end

    exports['m-notis']:addNotification(players, 'info', 'Informacja', 'Praca została rozpoczęta')
    triggerClientEvent(players, 'jobs:hideJobGui', resourceRoot)
    
    local success = triggerEvent('jobs:startJob', root, job, hash, players)
    if not success then
        destroyJobLobby(getLobbyByHash(hash))
    end
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

function setLobbyData(playerOrHash, key, value)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    lobby.data[key] = value
    triggerClientEvent(lobby.players, 'jobs:updateData', resourceRoot, key, value)
end

function getLobbyData(playerOrHash, key)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
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
        options = options,
        customData = options.customData or {},
        attachedElements = {}
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
        if object.hash == objectHash then
            table.remove(lobby.objects, i)
            break
        end
    end
end

function setLobbyObjectCustomData(playerOrHash, objectHash, key, value)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local object = findElementByHash(lobby.objects, objectHash)
    if not object then return end

    object.customData[key] = value
    -- triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, {object})
    triggerClientEvent(lobby.players, 'jobs:setObjectCustomData', resourceRoot, objectHash, key, value)
end

function getLobbyObjectCustomData(playerOrHash, objectHash, key)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local object = findElementByHash(lobby.objects, objectHash)
    if not object then return end

    return object.customData[key]
end

function getLobbyObjectModel(playerOrHash, objectHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local object = findElementByHash(lobby.objects, objectHash)
    if not object then return end

    return object.model
end

function getObjectByHash(playerOrHash, objectHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    return findElementByHash(lobby.objects, objectHash)
end

function setLobbyObjectPosition(playerOrHash, objectHash, x, y, z, rx, ry, rz)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local object = findElementByHash(lobby.objects, objectHash)
    if not object then return end

    object.position = {x, y, z}
    if rx and ry and rz then
        object.rotation = {rx, ry, rz}
    end
    -- triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, {object})
    triggerClientEvent(lobby.players, 'jobs:setObjectPosition', resourceRoot, objectHash, x, y, z, rx, ry, rz)
end

function setLobbyTimer(playerOrHash, event, time, ...)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local args = {...}

    local hash = generateHash()
    local timer = setTimer(function(event, hash, args)
        triggerEvent(event, root, hash, unpack(args))
    end, time, 1, event, lobby.hash, args)

    lobby.timers[hash] = timer
    return hash
end

function killLobbyTimer(playerOrHash, hash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local timer = lobby.timers[hash]
    if not timer then return end

    if isTimer(timer) then
        killTimer(timer)
    end

    lobby.timers[hash] = nil
end

function setPlayerLobbyTimer(playerOrHash, player, event, time, ...)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local args = {...}

    local hash = generateHash()
    local timer = setTimer(function(event, hash, player, args)
        triggerEvent(event, root, hash, player, unpack(args))
    end, time, 1, event, hash, player, args)

    if not lobby.playerTimers[player] then
        lobby.playerTimers[player] = {}
    end

    lobby.playerTimers[player][hash] = timer
    return hash
end

function killPlayerLobbyTimer(playerOrHash, player, hash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    if not lobby.playerTimers[player] then
        lobby.playerTimers[player] = {}
    end

    local timer = lobby.playerTimers[player][hash]
    if not timer then return end

    if isTimer(timer) then
        killTimer(timer)
    end

    lobby.playerTimers[player][hash] = nil
end

function createLobbyBlip(playerOrHash, x, y, z, icon, visibleDistance, options)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local options = options or {}

    local hash = generateHash()
    local blip = {
        hash = hash,
        position = {x or 0, y or 0, z or 0},
        visibleDistance = visibleDistance or 9999,
        icon = icon or 41,
        options = options
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
        if object.hash == hash then
            table.remove(lobby.blips, i)
            break
        end
    end
end

function createLobbyPed(playerOrHash, model, x, y, z, rx, ry, rz, options)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local options = options or {}

    local hash = generateHash()
    local ped = {
        hash = hash,
        model = model or 1337,
        position = {x or 0, y or 0, z or 0},
        rotation = {rx or 0, ry or 0, rz or 0},
        options = options
    }

    table.insert(lobby.peds, ped)

    if not options.noTrigger then
        triggerClientEvent(lobby.players, 'jobs:updatePeds', resourceRoot, {ped})
    end

    return hash
end

function updateLobbyPeds(playerOrHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)

    triggerClientEvent(lobby.players, 'jobs:updatePeds', resourceRoot, lobby.peds)
end

function destroyLobbyPed(playerOrHash, hash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local ped = findElementByHash(lobby.peds, hash)
    if not ped then return end

    for i, player in ipairs(lobby.players) do
        triggerClientEvent(player, 'jobs:destroyPed', resourceRoot, hash)
    end

    for i, object in ipairs(lobby.peds) do
        if object.hash == hash then
            table.remove(lobby.peds, i)
            break
        end
    end
end

function getLobbyPed(playerOrHash, hash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    return findElementByHash(lobby.peds, hash)
end

function setPedRotation(playerOrHash, hash, rotation)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local ped = findElementByHash(lobby.peds, hash)
    if not ped then return end

    ped.rotation[3] = rotation
    -- triggerClientEvent(lobby.players, 'jobs:updatePeds', resourceRoot, {ped})
    triggerClientEvent(lobby.players, 'jobs:setPedRotation', resourceRoot, hash, rotation)
end

function setPedControlState(playerOrHash, hash, state, enabled)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end
    
    local ped = findElementByHash(lobby.peds, hash)
    if not ped then return end

    ped.options.controlStates = ped.options.controlStates or {}
    ped.options.controlStates[state] = enabled
    -- triggerClientEvent(lobby.players, 'jobs:updatePeds', resourceRoot, {ped})
    triggerClientEvent(lobby.players, 'jobs:setPedControlState', resourceRoot, hash, state, enabled)
end

function makePedGoAway(playerOrHash, hash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local ped = findElementByHash(lobby.peds, hash)
    if not ped then return end

    ped.options.controlStates = ped.options.controlStates or {}
    ped.options.controlStates['forwards'] = true
    ped.rotation[3] = ped.rotation[3] + 180
    ped.options.frozen = false

    triggerClientEvent(lobby.players, 'jobs:updatePeds', resourceRoot, {ped})
end

function getAllLobbyObjectsWithCustomData(key)
    local objects = {}
    for i, lobby in ipairs(lobbies) do
        for j, object in ipairs(lobby.objects) do
            if object.customData[key] then
                table.insert(objects, {
                    lobby = lobby.hash,
                    hash = object.hash,
                    value = object.customData[key]
                })
            end
        end
    end

    return objects
end

function getLobbyPlayers(playerOrHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    return lobby.players
end

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
        options = options,
        customData = options.customData or {}
    }

    table.insert(lobby.markers, marker)

    if not options.noTrigger then
        triggerClientEvent(lobby.players, 'jobs:updateMarkers', resourceRoot, {marker})
    end

    return hash
end

function getLobbyMarkerCustomData(playerOrHash, markerHash, key)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)

    local marker = findElementByHash(lobby.markers, markerHash)
    if not marker then return end

    return marker.customData[key]
end

function setLobbyMarkerCustomData(playerOrHash, markerHash, key, value)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)

    local marker = findElementByHash(lobby.markers, markerHash)
    if not marker then return end

    marker.customData[key] = value
    -- triggerClientEvent(lobby.players, 'jobs:updateMarkers', resourceRoot, {marker})
    triggerClientEvent(lobby.players, 'jobs:setMarkerCustomData', resourceRoot, markerHash, key, value)
end

function updateLobbyMarkers(playerOrHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)

    triggerClientEvent(lobby.players, 'jobs:updateMarkers', resourceRoot, lobby.markers)
end

function destroyLobbyMarker(playerOrHash, markerHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local marker = findElementByHash(lobby.markers, markerHash)
    if not marker then return end

    triggerClientEvent(lobby.players, 'jobs:destroyMarker', resourceRoot, markerHash)

    for i, object in ipairs(lobby.markers) do
        if object.hash == markerHash then
            table.remove(lobby.markers, i)
            break
        end
    end
end

function setLobbyObjectOption(playerOrHash, elementHash, key, value)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    local element = findElementByHash(lobby.objects, elementHash)
    if not element then return end

    element.options[key] = value
    -- triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, {element})
    triggerClientEvent(lobby.players, 'jobs:setObjectOption', resourceRoot, elementHash, key, value)
end

function attachObjectToPlayer(playerOrHash, objectHash, player, bone, x, y, z, rx, ry, rz)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    setLobbyObjectOption(lobby.hash, objectHash, 'attachBone', {player, bone, x, y, z, rx, ry, rz})
end

function detachObjectFromPlayer(playerOrHash, objectHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    setLobbyObjectOption(lobby.hash, objectHash, 'attachBone', false)
end

function attachObject(playerOrHash, objectHash, element, x, y, z, rx, ry, rz)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    setLobbyObjectOption(lobby.hash, objectHash, 'attach', {
        element = element,
        position = {x, y, z, rx, ry, rz}
    })
end

function attachObjectToLobbyObject(playerOrHash, objectHash, objectToAttachHash, x, y, z, rx, ry, rz)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local attachTo = findElementByHash(lobby.objects, objectToAttachHash)
    if not attachTo then return end

    local object = findElementByHash(lobby.objects, objectHash)
    if not object then return end

    attachTo.attachedElements = attachTo.attachedElements or {}
    table.insert(attachTo.attachedElements, {
        hash = objectHash,
        position = {x, y, z, rx, ry, rz}
    })

    triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, {attachTo})
end

function detachObjectFromLobbyObject(playerOrHash, objectHash, objectToDetachHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    local attachTo = findElementByHash(lobby.objects, objectToDetachHash)
    if not attachTo then return end

    local changed = false
    for i, attached in ipairs(attachTo.attachedElements) do
        if attached.hash == objectHash then
            table.remove(attachTo.attachedElements, i)
            changed = true
            break
        end
    end

    if not changed then return end
    triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, {attachTo})
end

function detachObject(playerOrHash, objectHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    setLobbyObjectOption(lobby.hash, objectHash, 'attach', false)
end

function updateLobbyObjects(playerOrHash)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    triggerClientEvent(lobby.players, 'jobs:updateObjects', resourceRoot, lobby.objects)
    triggerClientEvent(lobby.players, 'jobs:updateBlips', resourceRoot, lobby.blips)
end

function playSound3D(playerOrHash, sound, x, y, z, minDistance, maxDistance, volume)
    local lobby = type(playerOrHash) == 'string' and getLobbyByHash(playerOrHash) or getPlayerJobLobby(playerOrHash)
    if not lobby then return end

    triggerClientEvent(lobby.players, 'jobs:playSound3D', resourceRoot, sound, x, y, z, minDistance, maxDistance, volume)
end

function destroyJobLobby(lobby)
    triggerEvent('jobs:finishJobLobby', root, lobby.job, lobby.hash)

    -- kill timers
    for i, timer in pairs(lobby.timers) do
        if isTimer(timer) then
            killTimer(timer)
        end
    end

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

    for i, p in ipairs(lobby.players) do
        setElementData(p, 'player:job-players', lobby.players)
    end

    if #(lobby.players or {}) < (lobby.minPlayers or 100) then
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
    triggerClientEvent(player, 'jobs:destroyPeds', resourceRoot)
    exports['m-notis']:addNotification(player, 'info', 'Praca', 'Zakończono pracę')

    -- kill player timers
    if lobby and lobby.playerTimers and lobby.playerTimers[player] then
        for i, timer in pairs(lobby.playerTimers[player]) do
            if isTimer(timer) then
                killTimer(timer)
            end
        end
    end

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
    if hash then
        exports['m-ui']:respondToRequest(hash, {status = 'success', title = 'Sukces', message = 'Zakończono pracę'})
    end
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
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `jobs:colshapeHit` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    local lobby = getPlayerJobLobby(client)
    if not lobby then return end

    local object = findElementByHash(lobby.objects, objectHash)
    if not object then return end
    if not object.options.colshape or not object.options.colshape.event then return end

    triggerEvent(object.options.colshape.event, root, lobby.hash, client, object.hash)
end)

addEventHandler('jobs:markerHit', resourceRoot, function(markerHash)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `jobs:markerHit` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    local lobby = getPlayerJobLobby(client)
    if not lobby then return end

    local marker = findElementByHash(lobby.markers, markerHash)
    if not marker then return end
    if not marker.options.event then return end

    triggerEvent(marker.options.event, root, lobby.hash, client, marker.hash)
end)