addEvent('jobs:finishJob')
addEvent('jobs:startJob')
addEvent('jobs:finishJobLobby')
addEvent('jobs:burger:getServerTick', true)

local dimensionsInUse = {}
local interiorObject = createObject(1337, unpack(settings.interior))
setElementDimension(interiorObject, 10000)
setElementAlpha(interiorObject, 0)
setElementCollisionsEnabled(interiorObject, false)

local blip = createBlip(settings.jobStart, 40, 2, 255, 255, 255, 255, 0, 9999)
setElementData(blip, 'blip:hoverText', 'Praca dorywcza<br>Burgerownia')

local function getFreeDimension(hash)
    local i = 1
    while dimensionsInUse[i] do
        i = i + 1
    end

    dimensionsInUse[i] = hash
    return i
end

local function freeDimension(hash)
    for i, v in pairs(dimensionsInUse) do
        if v == hash then
            dimensionsInUse[i] = nil
            break
        end
    end
end

local function loadElements(hash, dimension)
    local irx, iry, irz = getElementRotation(interiorObject)

    for _, element in pairs(settings.elements) do
        local x, y, z = unpack(element.position)
        local rx, ry, rz = unpack(element.rotation)

        x, y, z = getPositionFromElementOffset(interiorObject, x, y, z)
        rx, ry, rz = irx + rx, iry + ry, irz + rz
        exports['m-jobs']:createLobbyObject(hash, 1337, x, y, z, rx, ry, rz, {
            customModel = element.model,
            noTrigger = true,
            frozen = true,
            noCollision = element.noCollision,
            dimension = dimension,
            scale = element.scale,
            customData = {clickTrigger = element.clickTrigger}
        })
    end

    exports['m-jobs']:updateLobbyObjects(hash)
end

local function startBurgerJob(hash, players)
    local dimension = exports['m-jobs']:getLobbyData(hash, 'dimension')

    for _, player in pairs(players) do
        setElementPosition(player, unpack(settings.getJobSpawn()))

        local upgrades = exports['m-jobs']:getPlayerJobUpgrades(player, 'burger')
        setElementData(player, "player:job-upgrades-cache", upgrades)
        
        local multiplier = getLobbyTimeMultiplier(players)
        exports['m-notis']:addNotification(player, 'info', 'Praca burgerowni', ('Obecny mnożnik pracy: %d%%'):format(math.floor((1 - multiplier) * 100 + 0.5)))
        exports['m-jobs']:setLobbyTimer(hash, 'jobs:burger:addRandomNpc', math.random(unpack(settings.npcSpawnInterval)) * multiplier)
    end

    loadElements(hash, dimension)

    for i = 1, 2 do
        addLobbyNpc(hash, dimension)
    end
end

function getLobbyTimeMultiplier(players)
    local baseMultiplier = 1
    local minMultiplier = 0.4

    for _, player in ipairs(players) do
        local upgrades = getElementData(player, "player:job-upgrades-cache") or {}

        if table.find(upgrades, 'natlok') then
            baseMultiplier = math.max(baseMultiplier - 0.1, minMultiplier)
        end
    end

    return baseMultiplier
end

function getPlayerCookMultiplier(player)
    local baseMultiplier = 1
    local upgrades = getElementData(player, "player:job-upgrades-cache") or {}
   
    if table.find(upgrades, 'kucharz') then
        baseMultiplier = baseMultiplier + 0.1
    end

    return baseMultiplier
end

addEventHandler('jobs:startJob', root, function(job, hash, players)
    if job ~= 'burger' then return end

    triggerClientEvent(players, 'jobs:burger:startJob', resourceRoot, hash)

    local dimension = getFreeDimension(hash)
    exports['m-jobs']:setLobbyData(hash, 'dimension', dimension)

    for _, player in pairs(players) do
        toggleAllControls(player, false, true, false)
        setElementDimension(player, dimension)
        setElementData(player, 'element:ghostmode', true)
    end

    setTimer(startBurgerJob, 700, 1, hash, players)
end)

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'burger' then return end

    toggleAllControls(player, true)
    setElementDimension(player, 0)
    setElementData(player, 'element:ghostmode', false)
    triggerClientEvent(player, 'jobs:burger:finishJob', resourceRoot, hash)
end)

addEventHandler('jobs:finishJobLobby', root, function(job, hash)
    if job ~= 'burger' then return end

    freeDimension(hash)
end)

addEventHandler('jobs:burger:getServerTick', root, function()
    triggerClientEvent(client, 'jobs:burger:serverTickResponse', resourceRoot, getTickCount())
end)

addEventHandler('onPlayerResourceStart', root, function(resource)
    if resource ~= getThisResource() then return end

    if getElementData(source, 'player:job') == 'burger' then
        triggerEvent('jobs:endJobI', root, false, source)
    end
end)