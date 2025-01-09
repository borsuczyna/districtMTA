addEvent('jobs:burger:pedEnter')
addEvent('jobs:burger:pedLeave')
addEvent('jobs:burger:addRandomNpc')

local carryOrderItems = {
    ['burger/fries-box'] = 'fries',
    ['burger/salad-box'] = 'salad',
    ['burger/burger-in-packaging'] = 'burger',
    ['burger/cola-glass-full'] = 'cola',
}

local function getRandomPedSpawnPosition(lobby)
    local usedPositions = exports['m-jobs']:getLobbyData(lobby, 'usedPedSpawns') or {}

    local index = math.random(1, #settings.pedSpawns)
    while usedPositions[index] do
        index = math.random(1, #settings.pedSpawns)
    end

    usedPositions[index] = true
    exports['m-jobs']:setLobbyData(lobby, 'usedPedSpawns', usedPositions)

    return settings.pedSpawns[index], index
end

local function removeUsedPedSpawn(lobby, index)
    local usedPositions = exports['m-jobs']:getLobbyData(lobby, 'usedPedSpawns') or {}
    usedPositions[index] = nil
    exports['m-jobs']:setLobbyData(lobby, 'usedPedSpawns', usedPositions)
end

local function getRandomPedSkin()
    return 7
end

local function getRandomOrder()
    local possible = {{2, 'fries'}, {2, 'salad'}, {2, 'burger'}, {2, 'cola'}}
    local count = math.random(1, 3)
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

    local spawn, index = getRandomPedSpawnPosition(lobby)
    local x, y, z, rot = unpack(spawn)
    local model = getRandomPedSkin()
    local npc = exports['m-jobs']:createLobbyPed(lobby, model, x, y, z, 0, 0, rot, {
        dimension = dimension,
        datas = {
            ['element:ghost'] = true,
        }
    })

    local order = getRandomOrder()
    local orderSize = 0
    for _, item in ipairs(order) do
        orderSize = orderSize + item[1]
    end

    table.insert(npcs, {
        hash = npc,
        order = order,
        orderSize = orderSize,
        spawnIndex = index,
    })

    exports['m-jobs']:setLobbyData(lobby, 'npcs', npcs)
    local players = exports['m-jobs']:getLobbyPlayers(lobby)
    triggerClientEvent(players, 'jobs:burger:playSound', resourceRoot, 'bell')
end

function playPedLeaveAnimation(lobby, hash)
    local ped = exports['m-jobs']:getLobbyPed(lobby, hash)
    if not ped then return end

    exports['m-jobs']:makePedGoAway(lobby, hash)
    exports['m-jobs']:setLobbyTimer(lobby, 'jobs:burger:pedLeave', 400, hash)
end

addEventHandler('jobs:burger:pedEnter', resourceRoot, function(lobby, hash)
    exports['m-jobs']:setPedControlState(lobby, hash, 'forwards', false)
end)

addEventHandler('jobs:burger:pedLeave', resourceRoot, function(lobby, hash)
    if client then
        if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Trigger hack (**jobs:burger:pedLeave**)')
    end
    exports['m-jobs']:destroyLobbyPed(lobby, hash)
end)

function removeLobbyNpc(lobby, hash, npcs)
    if not npcs then
        npcs = exports['m-jobs']:getLobbyData(lobby, 'npcs')
    end

    for i, npc in ipairs(npcs) do
        if npc.hash == hash then
            removeUsedPedSpawn(lobby, npc.spawnIndex)
            table.remove(npcs, i)
            exports['m-jobs']:setLobbyData(lobby, 'npcs', npcs)
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

    local orderSize = npc.orderSize
    local money = 0
    for i = 1, orderSize do
        money = money + math.random(unpack(settings.orderMoney))
    end
    
    local players = exports['m-jobs']:getLobbyPlayers(player)
    local perPlayerMoney = math.floor(money / #players)
    
    local giveUpgradePoints = math.random(0, 100) > 95
    local giveExp = math.random(0, 100) > 95
    
    for _, player in pairs(players) do
        exports['m-jobs']:giveMoney(player, perPlayerMoney)

        if giveUpgradePoints then
            exports['m-jobs']:giveUpgradePoints(player, 1)
        end

        if giveExp then
            exports['m-core']:givePlayerExp(player, 1)
        end

        setElementData(player, "player:deliveredBurgerOrders", (getElementData(player, "player:deliveredBurgerOrders") or 0) + 1)
    end

    local message = ('Za dostarczone zamówienie zarobiono %s'):format(addCents(perPlayerMoney))
    if giveUpgradePoints then
        message = message .. (' + 1 punktów ulepszeń')
    end
    if giveExp then
        message = message .. (' + 1 expa')
    end

    message = message .. (' (razem %s)'):format(addCents(money))
    exports['m-notis']:addNotification(players, 'success', 'Zamówienie', message)
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
        playClientSound(player, 'cant')
        return
    end

    exports['m-jobs']:setLobbyData(player, 'npcs', npcs)
    stopPlayerCarryObject(player)
    playClientSound(player, 'click')

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

addEventHandler('jobs:burger:addRandomNpc', resourceRoot, function(lobby)
    if client then
        if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Trigger hack (**jobs:burer:addRandomNpc**)')
    end
    local randomTime = math.random(unpack(settings.npcSpawnInterval))
    local timeMultiplier = 1

    local players = exports['m-jobs']:getLobbyPlayers(lobby)
    for _, player in pairs(players) do
        local upgrades = getElementData(player, "player:job-upgrades-cache") or {}
    
        if table.find(upgrades, 'natlok') then
            timeMultiplier = timeMultiplier - 0.1
        end
    end

    randomTime = randomTime * math.max(0.4, timeMultiplier)

    addLobbyNpc(lobby)
    exports['m-jobs']:setLobbyTimer(lobby, 'jobs:burger:addRandomNpc', math.random(unpack(settings.npcSpawnInterval)))
end)

function addCents(amount)
    return '$' .. string.format('%0.2f', amount / 100)
end