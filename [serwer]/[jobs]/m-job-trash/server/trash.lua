addEvent('jobs:trash:trashHit')
addEvent('jobs:trash:putTrash')
addEvent('jobs:trash:dumpTrash')

local hitTime = {}

local function setPlayerOnHitCooldown(player)
    hitTime[player] = getTickCount() + 500
end

local function isPlayerOnHitCooldown(player)
    return hitTime[player] and hitTime[player] > getTickCount()
end

local function toggleJobControls(player, enable)
    toggleControl(player, 'crouch', enable)
    toggleControl(player, 'jump', enable)
    if not enable then
        local upgrades = getElementData(player, 'player:job-upgrades-cache')
        toggleControl(player, 'sprint', not not table.find(upgrades, 'sprinter'))
    else
        toggleControl(player, 'sprint', true)
    end
end

local function pickUpTrash(player, hash, objectHash)
    local model = exports['m-jobs']:getLobbyObjectModel(hash, objectHash)
    local model, offset, attachData, playAnimation = getTrashInfoByModel(model)

    setElementFrozen(player, false)
    setPedAnimation(player)
    if playAnimation then
        exports['m-anim']:setPedAnimation(player, 'carry')
    end
    toggleAllControls(player, true, false)
    toggleJobControls(player, false)

    exports['m-jobs']:attachObjectToPlayer(hash, objectHash, player, unpack(attachData))
end

local function putBackTrash(player, hash, objectHash)
    local model = exports['m-jobs']:getLobbyObjectModel(hash, objectHash)
    local model, offset, attachData, playAnimation = getTrashInfoByModel(model)

    if playAnimation then
        exports['m-anim']:setPedAnimation(player, 'carry')
    end
    removeElementData(player, 'player:dumpingTrash')
    toggleAllControls(player, true, false)
    setElementFrozen(player, false)
    toggleJobControls(player, false)
    
    exports['m-jobs']:setLobbyData(hash, 'trashDumping', false)
    exports['m-jobs']:attachObjectToPlayer(hash, objectHash, player, unpack(attachData))

    local upgrades = getElementData(player, 'player:job-upgrades-cache')
    local hasRecycleUpgrade = table.find(upgrades, 'recykling')
    local trashLevel = exports['m-jobs']:getLobbyData(hash, 'trashLevel')
    local addAmount = math.random(450, 4500)/100 * (hasRecycleUpgrade and 1.1 or 1)
    local newTrashLevel = math.min(trashLevel + addAmount, 10000)
    exports['m-jobs']:setLobbyData(hash, 'trashLevel', newTrashLevel)
    exports['m-notis']:addNotification(player, 'success', 'Kosz', 'Wyrzucono śmieci')
end

local function dumpTrash(player, hash, objectHash)
    setPedAnimation(player)
    setElementFrozen(player, false)
    exports['m-anim']:removePedAnimation(player, 'carry')
    toggleAllControls(player, true, false)
    toggleJobControls(player, true)

    exports['m-jobs']:detachObjectFromPlayer(hash, objectHash)
    exports['m-jobs']:setLobbyData(hash, 'trashDumpingTemp', false)
    exports['m-jobs']:setLobbyData(hash, 'trashDumping', objectHash)
    exports['m-jobs']:setLobbyObjectOption(hash, objectHash, 'blip', false)
    exports['m-jobs']:setLobbyObjectCustomData(hash, objectHash, 'emptyTime', getTickCount())

    local x, y, z = getElementPosition(player)
    exports['m-jobs']:playSound3D(hash, ':m-job-trash/data/trash.mp3', x, y, z, 3, 25, 1)

    setPlayerTimer(player, putBackTrash, 3200, player, hash, objectHash)
end

local function returnTrash(player, hash, objectHash)
    setPedAnimation(player)
    setElementFrozen(player, false)
    exports['m-anim']:removePedAnimation(player, 'carry')
    toggleAllControls(player, true, false)
    toggleJobControls(player, true)

    exports['m-jobs']:detachObjectFromPlayer(hash, objectHash)
end

local function isTrashEmpty(hash, objectHash)
    local emptyTime = exports['m-jobs']:getLobbyObjectCustomData(hash, objectHash, 'emptyTime')
    return emptyTime and (getTickCount() - emptyTime ) < settings.trashRefillTime
end

addEventHandler('jobs:trash:trashHit', root, function(hash, player, objectHash)
    if getElementData(player, 'player:dumpingTrash') then return end
    if isPedInVehicle(player) then return end
    if getElementData(player, 'player:attachedVehicle') then return end
    if isPlayerOnHitCooldown(player) then return end
    setPlayerOnHitCooldown(player)

    local carried = exports['m-jobs']:getLobbyObjectCustomData(hash, objectHash, 'carried')
    local carryBin = getElementData(player, 'player:carryBin')
    if carried and carryBin ~= objectHash then return end

    if carryBin then
        if carryBin ~= objectHash then return end

        exports['m-jobs']:setLobbyObjectCustomData(hash, objectHash, 'carried', false)

        setElementFrozen(player, true)
        toggleAllControls(player, false, false)
        setPedAnimation(player, "CARRY", "putdwn", -1, false)

        removeElementData(player, 'player:carryBin')
        setPlayerTimer(player, returnTrash, 1000, player, hash, objectHash)
    else
        exports['m-jobs']:setLobbyObjectCustomData(hash, objectHash, 'carried', true)
        
        setElementFrozen(player, true)
        toggleAllControls(player, false, false)
        setPedAnimation(player, "CARRY", "putdwn", -1, false)
    
        setElementData(player, 'player:carryBin', objectHash)
        setPlayerTimer(player, pickUpTrash, 1000, player, hash, objectHash)

        if isTrashEmpty(hash, objectHash) then
            exports['m-notis']:addNotification(player, 'warning', 'Kosz', 'Podniesiony kosz jest pusty, poczekaj chwilę aż zostanie zapełniony')
        end
    end
    -- exports['m-jobs']:setLobbyObjectOption(hash, objectHash, 'colshape', false)
    -- exports['m-jobs']:setLobbyObjectOption(hash, objectHash, 'blip', false)
end)

addEventHandler('jobs:trash:putTrash', root, function(hash, player, markerHash)
    if getElementData(player, 'player:dumpingTrash') then return end
    local objectHash = getElementData(player, 'player:carryBin')
    if not objectHash then return end

    if exports['m-jobs']:getLobbyData(hash, 'trashDumping') or exports['m-jobs']:getLobbyData(hash, 'trashDumpingTemp') then
        exports['m-notis']:addNotification(player, 'warning', 'Kosz', 'Śmieciarka może wyrzucać tylko jedne śmieci na raz')
        return
    end

    if isTrashEmpty(hash, objectHash) then
        exports['m-notis']:addNotification(player, 'warning', 'Kosz', 'Podniesiony kosz jest pusty, poczekaj chwilę aż zostanie zapełniony')
        return
    end

    setElementFrozen(player, true)
    toggleAllControls(player, false, false)
    exports['m-anim']:removePedAnimation(player, 'carry')
    setElementData(player, 'player:dumpingTrash', true)
    setPedAnimation(player, "CARRY", "putdwn", -1, false)

    exports['m-jobs']:setLobbyData(hash, 'trashDumpingTemp', objectHash)
    setPlayerTimer(player, dumpTrash, 1000, player, hash, objectHash)
end)

local function restoreBlip(hash, objectHash)
    exports['m-jobs']:setLobbyObjectOption(hash, objectHash, 'blip', defaultBlipData)
end

local function updateTrashObjects()
    local objects = exports['m-jobs']:getAllLobbyObjectsWithCustomData('emptyTime')
    for k,v in pairs(objects) do
        local lobbyHash = v.lobby
        local hash = v.hash
        local value = v.value

        if getTickCount() - value > settings.trashRefillTime then
            exports['m-jobs']:setLobbyObjectCustomData(lobbyHash, hash, 'emptyTime', nil)
            restoreBlip(lobbyHash, hash)
        end
    end
end

function forcefullyPutBinBack(hash, objectHash)
    exports['m-jobs']:setLobbyObjectCustomData(hash, objectHash, 'carried', false)
    exports['m-jobs']:setLobbyObjectOption(hash, objectHash, 'blip', defaultBlipData)
    exports['m-jobs']:detachObjectFromPlayer(hash, objectHash)
end

addEventHandler('jobs:trash:dumpTrash', root, function(hash, player)
    if getElementData(player, 'player:dumpingTrash') then return end

    local vehicle = getElementData(player, 'player:jobVehicle')
    
    if not vehicle or getPedOccupiedVehicle(player) ~= vehicle then return end
    if getVehicleOccupant(vehicle, 0) ~= player then return end

    local trashLevel = exports['m-jobs']:getLobbyData(hash, 'trashLevel')
    if trashLevel < 50 then
        exports['m-notis']:addNotification(player, 'error', 'Wywóz śmieci', 'Potrzebujesz minimum 50kg śmieci aby je oddać')
        return
    end

    exports['m-jobs']:setLobbyData(hash, 'trashLevel', 0)

    local multiplier = exports['m-jobs']:getJobMultiplier('trash')
    local players = exports['m-jobs']:getLobbyPlayers(hash)
    local totalMoney = math.floor(trashLevel * settings.oneKgTrashCost * multiplier)
    local perPlayerMoney = math.floor(totalMoney / #players)
    local upgradePoints = math.floor(totalMoney * settings.upgradePointChancePerKg * math.random(30, 150)/100 * multiplier)
    local topPoints = math.floor(trashLevel / settings.kgFor1TopPoint * multiplier)
    local exp = math.floor(trashLevel / settings.kgFor1Exp * multiplier)

    for _,player in pairs(players) do
        exports['m-jobs']:giveMoney(player, perPlayerMoney)
        exports['m-jobs']:giveUpgradePoints(player, upgradePoints)
        exports['m-jobs']:giveTopPoints(player, topPoints)
        exports['m-core']:givePlayerExp(player, exp)
        setElementData(player, 'player:player:trashDelivered', (getElementData(player, 'player:player:trashDelivered') or 0) + trashLevel)
    end

    exports['m-notis']:addNotification(players, 'success', 'Wywóz śmieci', ('Za oddane śmieci zarobiono %s + %d punktów ulepszeń (razem %s)'):format(addCents(perPlayerMoney), upgradePoints, addCents(totalMoney)))
end)

-- dont allow entering vehicle while carrying trash
addEventHandler('onVehicleStartEnter', root, function(player)
    if getElementData(player, 'player:carryBin') then
        cancelEvent()
    end
end)

addEventHandler('onResourceStart', resourceRoot, function()
    setTimer(updateTrashObjects, 1000, 0)
end)

function addCents(amount)
    return '$' .. string.format('%0.2f', amount / 100)
end