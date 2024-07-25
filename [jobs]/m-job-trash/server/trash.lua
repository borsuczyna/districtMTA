addEvent('jobs:trash:trashHit')
addEvent('jobs:trash:putTrash')
addEvent('jobs:trash:dumpTrash')

local hitTime = {}
local trashRefillTime = 15 * 60000
local oneKgTrashCost = 12

local function setPlayerOnHitCooldown(player)
    hitTime[player] = getTickCount() + 1500
end

local function isPlayerOnHitCooldown(player)
    return hitTime[player] and hitTime[player] > getTickCount()
end

local function toggleJobControls(player)
    toggleControl(player, 'crouch', false)
    toggleControl(player, 'jump', false)
    toggleControl(player, 'sprint', true)
end

local function pickUpTrash(player, hash, objectHash)
    local model = exports['m-jobs']:getLobbyObjectModel(hash, objectHash)
    local model, offset, attachData, playAnimation = getTrashInfoByModel(model)

    setElementFrozen(player, false)
    setPedAnimation(player)
    if playAnimation then
        setElementData(player, 'player:animation', 'carry')
    end
    toggleAllControls(player, true)
    toggleJobControls(player) -- TODO add sprint upgrade

    exports['m-jobs']:attachObjectToPlayer(hash, objectHash, player, unpack(attachData))
end

local function putBackTrash(player, hash, objectHash)
    local model = exports['m-jobs']:getLobbyObjectModel(hash, objectHash)
    local model, offset, attachData, playAnimation = getTrashInfoByModel(model)

    setElementData(player, 'player:carryBin', objectHash)
    if playAnimation then
        setElementData(player, 'player:animation', 'carry')
    end
    toggleAllControls(player, true)
    setElementFrozen(player, false)
    toggleJobControls(player) -- TODO add sprint upgrade
    
    exports['m-jobs']:setLobbyData(hash, 'trashDumping', false)
    exports['m-jobs']:attachObjectToPlayer(hash, objectHash, player, unpack(attachData))

    local trashLevel = exports['m-jobs']:getLobbyData(hash, 'trashLevel')
    local newTrashLevel = math.min(trashLevel + math.random(450, 4500)/100, 10000)
    exports['m-jobs']:setLobbyData(hash, 'trashLevel', newTrashLevel)
    exports['m-notis']:addNotification(player, 'success', 'Kosz', 'Wyrzucono śmieci')
end

local function dumpTrash(player, hash, objectHash)
    setPedAnimation(player)

    exports['m-jobs']:detachObjectFromPlayer(hash, objectHash, player)
    exports['m-jobs']:setLobbyData(hash, 'trashDumpingTemp', false)
    exports['m-jobs']:setLobbyData(hash, 'trashDumping', objectHash)
    exports['m-jobs']:setLobbyObjectOption(hash, objectHash, 'blip', false)
    exports['m-jobs']:setLobbyObjectCustomData(hash, objectHash, 'emptyTime', getTickCount())

    setPlayerTimer(player, putBackTrash, 3200, player, hash, objectHash)
end

local function returnTrash(player, hash, objectHash)
    setPedAnimation(player)
    setElementFrozen(player, false)
    removeElementData(player, 'player:animation')
    toggleAllControls(player, true)
    toggleJobControls(player) -- TODO add sprint upgrade

    exports['m-jobs']:detachObjectFromPlayer(hash, objectHash, player)
end

local function isTrashEmpty(hash, objectHash)
    local emptyTime = exports['m-jobs']:getLobbyObjectCustomData(hash, objectHash, 'emptyTime')
    return emptyTime and (getTickCount() - emptyTime )< trashRefillTime
end

addEventHandler('jobs:trash:trashHit', root, function(hash, player, objectHash)
    if isPedInVehicle(player) then return end
    if getElementData(player, 'player:attachedVehicle') then return end
    if isPlayerOnHitCooldown(player) then return end
    setPlayerOnHitCooldown(player)

    if getElementData(player, 'player:carryBin') then
        local carryBin = getElementData(player, 'player:carryBin')
        if carryBin ~= objectHash then return end

        exports['m-jobs']:setLobbyObjectCustomData(hash, objectHash, 'carried', false)

        setElementFrozen(player, true)
        toggleAllControls(player, false)
        setPedAnimation(player, "CARRY", "putdwn", -1, false)

        removeElementData(player, 'player:carryBin')
        setPlayerTimer(player, returnTrash, 1000, player, hash, objectHash)
    else
        exports['m-jobs']:setLobbyObjectCustomData(hash, objectHash, 'carried', true)
        
        setElementFrozen(player, true)
        toggleAllControls(player, false)
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

    setElementData(player, 'player:carryBin', false)
    setElementFrozen(player, true)
    toggleAllControls(player, false)
    removeElementData(player, 'player:animation')
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

        if getTickCount() - value > trashRefillTime then
            exports['m-jobs']:setLobbyObjectCustomData(lobbyHash, hash, 'emptyTime', nil)
            restoreBlip(lobbyHash, hash)
        end
    end
end

addEventHandler('jobs:trash:dumpTrash', root, function(hash, player)
    local vehicle = getElementData(player, 'player:jobVehicle')
    if not vehicle or getPedOccupiedVehicle(player) ~= vehicle then
        exports['m-notis']:addNotification(player, 'error', 'Wywóz śmieci', 'Nie jesteś w śmieciarce')
        return
    end
    if getVehicleOccupant(vehicle, 0) ~= player then
        exports['m-notis']:addNotification(player, 'error', 'Wywóz śmieci', 'Tylko kierowca może oddawać śmieci')
        return
    end

    local trashLevel = exports['m-jobs']:getLobbyData(hash, 'trashLevel')
    if trashLevel < 50 then
        exports['m-notis']:addNotification(player, 'error', 'Wywóz śmieci', 'Potrzebujesz minimum 50kg śmieci aby je oddać')
        return
    end

    exports['m-jobs']:setLobbyData(hash, 'trashLevel', 0)
    print('Zarobiono', trashLevel * oneKgTrashCost)

    local players = exports['m-jobs']:getLobbyPlayers(hash)
    exports['m-notis']:addNotification(players, 'success', 'Wywóz śmieci', 'Za oddane śmieci zarobiłeś ' .. trashLevel * oneKgTrashCost .. '$')
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