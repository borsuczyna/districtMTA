addEvent('jobs:burger:pedLeave')

local carryOrderItems = {
    ['burger/fries-box'] = 'fries',
    ['burger/salad-box'] = 'salad',
    ['burger/burger-in-packaging'] = 'burger',
    ['burger/cola-glass-full'] = 'cola',
}

local function getRandomPedSpawnPosition()
    local index = math.random(1, #settings.pedSpawns)
    return settings.pedSpawns[index]
end

local function getRandomPedSkin()
    return 7
end

local function getRandomOrder()
    local possible = {{2, 'fries'}, {2, 'salad'}, {2, 'burger'}, {2, 'cola'}}
    -- local count = math.random(1, 4)
    local count = 1
    local order = {}
    local used = {}

    local function getUnused()
        local index = math.random(1, #possible)
        while used[index] do
            index = math.random(1, #possible)
        end

        return index
    end

    for i = 1, count do
        local index = getUnused()
        local count = math.random(1, possible[index][1])
        table.insert(order, {count, possible[index][2]})
        used[index] = true
    end

    return order
end

function addLobbyNpc(lobby, dimension)
    local npcs = exports['m-jobs']:getLobbyData(lobby, 'npcs') or {}
    if #npcs >= 4 then return end

    if not dimension then
        dimension = exports['m-jobs']:getLobbyData(lobby, 'dimension')
    end

    local x, y, z, rot = unpack(getRandomPedSpawnPosition())
    local model = getRandomPedSkin()
    local npc = exports['m-jobs']:createLobbyPed(lobby, model, x, y, z, 0, 0, rot, {
        dimension = dimension,
        datas = {
            ['element:ghost'] = true,
        }
    })

    table.insert(npcs, {
        hash = npc,
        order = getRandomOrder(),
    })

    exports['m-jobs']:setLobbyData(lobby, 'npcs', npcs)
end

function playPedLeaveAnimation(lobby, hash)
    -- local ped = exports['m-jobs']:getLobbyPed(lobby, hash)
    -- if not ped then return end

    -- exports['m-jobs']:setPedControlState(lobby, ped, 'forwards', true)
    -- exports['m-jobs']:setPedRotation(lobby, ped, ped.rotation[3] + 180)
    exports['m-jobs']:makePedGoAway(lobby, hash)
    exports['m-jobs']:setLobbyTimer(lobby, 'jobs:burger:pedLeave', 1000, hash)
end

addEventHandler('jobs:burger:pedLeave', resourceRoot, function(lobby, hash)
    exports['m-jobs']:destroyLobbyPed(lobby, hash)
end)

function removeLobbyNpc(lobby, hash, npcs)
    if not npcs then
        npcs = exports['m-jobs']:getLobbyData(lobby, 'npcs')
    end

    for i, npc in ipairs(npcs) do
        if npc.hash == hash then
            table.remove(npcs, i)
            exports['m-jobs']:setLobbyData(lobby, 'npcs', npcs)
            -- exports['m-jobs']:destroyLobbyPed(lobby, hash)
            playPedLeaveAnimation(lobby, hash)
            break
        end
    end

    if #npcs == 0 then
        addLobbyNpc(lobby)
    end
end

function finishOrder(npcs, player, npc)
    exports['m-jobs']:setLobbyData(player, 'npcs', npcs)
    removeLobbyNpc(player, npc.hash, npcs)
    exports['m-notis']:addNotification(player, 'success', 'Zamówienie', 'Zamówienie dostarczone')
end

function tryGiveOrder(npcs, carryData, player, npc)
    local order = npc.order
    local carryModel = carryData and carryData.model

    if not carryData then
        exports['m-notis']:addNotification(player, 'warning', 'Zamówienie', 'Nie masz niczego w rękach')
        return
    end

    if not carryOrderItems[carryModel] then
        exports['m-notis']:addNotification(player, 'warning', 'Zamówienie', 'Nie możesz dostarczyć tego zamówienia')
        return
    end

    local carryItem = carryOrderItems[carryModel]
    local found = false

    for i, item in ipairs(order) do
        if item[2] == carryItem then
            order[i][1] = order[i][1] - 1
            if order[i][1] == 0 then
                table.remove(order, i)
            end

            found = true
            break
        end
    end

    if not found then
        exports['m-notis']:addNotification(player, 'warning', 'Zamówienie', 'Nie możesz dostarczyć tego zamówienia')
        return
    end

    exports['m-jobs']:setLobbyData(player, 'npcs', npcs)
    stopPlayerCarryObject(player)

    if #order == 0 then
        finishOrder(npcs, player, npc)
    end
end

function clickNpc(client, hash)
    local carryData = getPlayerCarryObject(client)
    if not carryData then return end

    local npcs = exports['m-jobs']:getLobbyData(client, 'npcs')
    if not npcs then return end

    for _, npc in pairs(npcs) do
        if npc.hash == hash then
            tryGiveOrder(npcs, carryData, client, npc)
            return
        end
    end
end