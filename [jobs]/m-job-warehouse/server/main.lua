addEvent('jobs:finishJob')
addEvent('jobs:startJob')
addEvent('jobs:finishJobLobby')
addEvent('jobs:warehouse:getPackage')
addEvent('jobs:leavePackage')

local packages = {}
local targetPositions = {}
local blip = createBlip(settings.blipPosition, 40, 2, 255, 255, 255, 255, 0, 9999)
setElementData(blip, 'blip:hoverText', 'Praca dorywcza<br>Magazyn')

local vehicle = createVehicle(414, 2255.736, -195.283, 96.275, 0, 0, 0)
setElementFrozen(vehicle, true)
setVehicleDoorOpenRatio(vehicle, 1, 1, 0)
setElementDimension(vehicle, settings.dimension)
setElementInterior(vehicle, settings.interior)

local door = createObject(3109, 2258.591309, -224.140244, 96.341896)
setElementDimension(door, settings.dimension)
setElementInterior(door, settings.interior)

addEventHandler('onVehicleStartEnter', vehicle, function(player)
    cancelEvent()
end)

local _toggleAllControls = toggleAllControls
local function toggleAllControls(player, state)
    _toggleAllControls(player, state)

    local upgrades = getElementData(player, 'player:job-upgrades-cache') or {}
    toggleControl(player, 'sprint', not not table.find(upgrades, 'sprinter'))
    toggleControl(player, 'jump', false)
    toggleControl(player, 'crouch', false)
end

addEventHandler('jobs:startJob', root, function(job, hash, players)
    if job ~= 'warehouse' then return end

    local pos = settings.packagePosition
    exports['m-jobs']:createLobbyMarker(hash, 'cylinder', settings.packagePosition.x, settings.packagePosition.y, settings.packagePosition.z - 1, 2, 50, 255, 50, 0, {
        icon = 'work',
        title = 'Magazyn',
        desc = 'Odbiór paczki',
        event = 'jobs:warehouse:getPackage',
        dimension = settings.dimension,
        interior = settings.interior,
    })

    for i, player in ipairs(players) do
        setElementData(player, 'element:ghostmode', true)

        local upgrades = exports['m-jobs']:getPlayerJobUpgrades(player, 'warehouse')
        setElementData(player, 'player:job-upgrades-cache', upgrades, false)
    end
end)

local function pickupPackage(player)
    setPedAnimation(player, 'CARRY', 'crry_prtial', 1, true, true, true, true)
    toggleAllControls(player, true)
end

local function destroyPlayerPackage(player)
    setElementData(player, 'player:holdingPackage', false)
    if packages[player] and isElement(packages[player]) then
        destroyElement(packages[player])
    end
end

local function attachPackage(player)
    destroyPlayerPackage(player)
    
    local models = {'pears', 'apples', 'bananas', 'lemons'}
    packages[player] = createObject(1337, 0, 0, 0)
    setElementData(packages[player], 'element:model', models[math.random(1, #models)])
    exports['m-pattach']:attach(packages[player], player, unpack(settings.packageAttach))
    setElementInterior(packages[player], settings.interior)
    setElementDimension(packages[player], settings.dimension)
    setElementData(player, 'player:holdingPackage', true)

    local position = getRandomShelf()
    targetPositions[player] = position

    exports['m-jobs']:createLobbyMarker(player, 'cylinder', position[1], position[2], position[3] - 1, 1, 255, 0, 0, 0, {
        icon = 'work',
        title = 'Magazyn',
        desc = 'Dostarcz paczkę',
        event = 'jobs:leavePackage',
        dimension = settings.dimension,
        interior = settings.interior,
    })
end

local function makePlayerPickupPackage(player)
    toggleAllControls(player, false)
    setPedAnimation(player, 'CARRY', 'liftup', -1, false, false, false, false)
    setTimer(pickupPackage, 1000, 1, player)
    setTimer(attachPackage, 400, 1, player)
end

addEventHandler('jobs:warehouse:getPackage', resourceRoot, function(hash, player, objectHash)
    if not isElement(player) or getElementType(player) ~= 'player' then return end

    if isPedInVehicle(player) then
        exports['m-notis']:addNotification(player, 'error', 'Magazyn', 'Nie możesz podnieść paczki będąc w pojeździe.')
        return
    end

    local playerPackage = getElementData(player, 'player:holdingPackage')
    if playerPackage then
        exports['m-notis']:addNotification(player, 'error', 'Magazyn', 'Masz już paczkę w rękach.')
        return
    end

    makePlayerPickupPackage(player)
end)

addEventHandler('jobs:finishJob', root, function(job, hash, player)
    if job ~= 'warehouse' then return end

    removeElementData(player, 'player:holdingPackage')
    setElementData(player, 'element:ghostmode', false)
    setPedAnimation(player)
    destroyPlayerPackage(player)
    _toggleAllControls(player, true)
end)

local function leavePackage(player)
    if not isElement(player) or getElementType(player) ~= 'player' then return end

    setPedAnimation(player)
    removeElementData(player, 'player:holdingPackage')
    toggleAllControls(player, true)
    toggleControl(player, 'sprint', true)
end

addEventHandler('jobs:leavePackage', resourceRoot, function(hash, player, markerHash)
    if not isElement(player) or getElementType(player) ~= 'player' then return end

    local playerPackage = getElementData(player, 'player:holdingPackage')
    if not playerPackage then
        exports['m-notis']:addNotification(player, 'error', 'Magazyn', 'Nie masz paczki w rękach.')
        return
    end

    local targetPosition = targetPositions[player]
    if not targetPosition then
        exports['m-notis']:addNotification(player, 'error', 'Magazyn', 'Nie masz paczki w rękach.')
        return
    end

    local x, y, z = getElementPosition(player)
    local distance = getDistanceBetweenPoints3D(x, y, z, targetPosition[1], targetPosition[2], targetPosition[3])
    if distance > 3 then
        local banMessage = ('Tried to leave package in wrong place. Distance: %s'):format(distance)
        return exports['m-anticheat']:ban(player, 'Trigger hack', banMessage)
    end

    toggleAllControls(player, false)
    setPedAnimation(player, 'CARRY', 'putdwn', -1, false, false, false, false)
    setTimer(destroyPlayerPackage, 400, 1, player)
    setTimer(leavePackage, 1000, 1, player)
    exports['m-jobs']:destroyLobbyMarker(player, markerHash)

    targetPositions[player] = nil

    local multiplier = exports['m-jobs']:getJobMultiplier('warehouse')
    local upgrades = getElementData(player, "player:job-upgrades-cache") or {}

    if table.find(upgrades, 'biznesmen') then
        multiplier = multiplier + 0.05
    end

    if table.find(upgrades, 'fachowiec') then
        multiplier = multiplier + 0.1
    end

    local totalMoney = math.floor(math.random(unpack(settings.moneyPerPackage)) * multiplier)
    local upgradePoints = math.max(math.random(unpack(settings.upgradePointsPerPackage)), 0)
    local giveExp = math.random(0, 100) > 90

    exports['m-jobs']:giveMoney(player, totalMoney)
    if upgradePoints > 0 then
        exports['m-jobs']:giveUpgradePoints(player, upgradePoints)
    end

    if giveExp then
        exports['m-core']:givePlayerExp(player, 1)
    end

    setElementData(player, 'player:packagesDelivered', (getElementData(player, 'player:packagesDelivered') or 0) + 1)
    exports['m-jobs']:giveTopPoints(player, 1)
    exports['m-notis']:addNotification(player, 'success', 'Magazyn', ('Za dostarczenie paczki otrzymujesz %s.'):format(addCents(totalMoney), upgradePoints > 0 and (' oraz %s punktów umiejętności'):format(upgradePoints) or ''))
end)

function addCents(amount)
    return '$' .. string.format('%0.2f', amount / 100)
end