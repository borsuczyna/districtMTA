addEvent('jobs:finishJob')
addEvent('jobs:startJob')
addEvent('jobs:finishJobLobby')

local dimensionsInUse = {}
local interiorObject = createObject(1337, unpack(settings.interior))
setElementDimension(interiorObject, 10000)

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
        -- makePlayerCarryObject(player, 'burger/burger')
    end

    loadElements(hash, dimension)
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

addEventHandler('onPlayerResourceStart', root, function(resource)
    if resource ~= getThisResource() then return end

    if getElementData(source, 'player:job') == 'burger' then
        triggerEvent('jobs:endJobI', root, false, source)
    end
end)