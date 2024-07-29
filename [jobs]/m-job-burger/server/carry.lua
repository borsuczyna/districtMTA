local carryObjects = {}

function getPlayerCarryKey(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    return ('player:%d:carry'):format(uid)
end

function makePlayerCarryObject(player, model, nData, options)
    local key = getPlayerCarryKey(player)
    if not key then return end

    setElementData(player, 'player:animation', 'carry-burger')

    if carryObjects[player] then
        exports['m-jobs']:destroyLobbyObject(player, carryObjects[player])
    end

    local data = settings.carryPositions[model]
    local x, y, z = unpack(data.position)
    local rx, ry, rz = unpack(data.rotation)
    local scale = data.scale

    local objectOptions = {
        customModel = model,
        attachBone = {player, 34, x, y, z, rx, ry, rz},
        dimension = getElementDimension(player),
        scale = scale,
    }

    for k,v in pairs(options or {}) do
        objectOptions[k] = v
    end

    carryObjects[player] = exports['m-jobs']:createLobbyObject(player, 1337, 0, 0, 0, 0, 0, 0, objectOptions)

    exports['m-jobs']:setLobbyData(player, key, {
        object = carryObjects[player],
        model = model,
        data = nData,
        options = options,
    })
end

function getPlayerCarryObject(player)
    local key = getPlayerCarryKey(player)
    if not key then return end

    return exports['m-jobs']:getLobbyData(player, key)
end

function stopPlayerCarryObject(player, hash)
    removeElementData(player, 'player:animation')

    if carryObjects[player] then
        exports['m-jobs']:destroyLobbyObject(hash or player, carryObjects[player])
        exports['m-jobs']:setLobbyData(player, getPlayerCarryKey(player), nil)
        carryObjects[player] = nil
    end
end

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'burger' then return end

    stopPlayerCarryObject(player, hash)
end)