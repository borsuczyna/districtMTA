addEvent('jobs:courier:cartHit')
addEvent('jobs:courier:cartLeave', true)

local hitTime = {}

local function setPlayerOnHitCooldown(player)
    hitTime[player] = getTickCount() + 500
end

local function isPlayerOnHitCooldown(player)
    return hitTime[player] and hitTime[player] > getTickCount()
end

function toggleCartControls(player, enabled)
    local upgrades = getElementData(player, "player:job-upgrades-cache") or {}
    local canSprint = enabled

    if table.find(upgrades, 'sprinter') then
        canSprint = true
    end

    toggleControl(player, 'jump', enabled)
    toggleControl(player, 'sprint', canSprint)
    toggleControl(player, 'crouch', enabled)
    toggleControl(player, 'enter_exit', enabled)
    toggleControl(player, 'enter_passenger', enabled)
end

local function leaveCart(player)
    local cartPlayer = exports['m-jobs']:getLobbyData(player, 'cart:player')
    if cartPlayer ~= player then return end
    
    local cartObject = exports['m-jobs']:getLobbyData(player, 'cart:object')
    if not cartObject then return end

    triggerClientEvent(player, 'jobs:courier:cartLeave', resourceRoot, cartObject)
end

addEventHandler('jobs:courier:cartHit', root, function(hash, player, objectHash)
    if isPedInVehicle(player) then return end
    if isPlayerOnHitCooldown(player) then return end
    setPlayerOnHitCooldown(player)

    local cartPlayer = exports['m-jobs']:getLobbyData(player, 'cart:player')
    if cartPlayer then return end

    local playerPackage = getElementData(player, 'player:holdingPackage')
    if playerPackage then
        leavePackage(player)
        return
    end

    local cartObject = exports['m-jobs']:getLobbyData(player, 'cart:object')
    exports['m-jobs']:attachObject(hash, cartObject, player, 0, 0.3, 0, 0, 0, 90)
    exports['m-notis']:addNotification(player, 'info', 'Wózek', 'Naciśnij <kbd class="keycap">F</kbd> aby puścić wózek.')
    toggleCartControls(player, false)
    setElementData(player, 'player:animation', 'cart')

    exports['m-jobs']:setLobbyData(player, 'cart:player', player)
    bindKey(player, 'f', 'down', leaveCart)
end)

addEventHandler('jobs:courier:cartLeave', resourceRoot, function(x, y, z, rx, ry, rz)
    local cartPlayer = exports['m-jobs']:getLobbyData(client, 'cart:player')
    if cartPlayer ~= client then return end

    local cartObject = exports['m-jobs']:getLobbyData(client, 'cart:object')
    if not cartObject then return end

    exports['m-jobs']:detachObject(client, cartObject)
    exports['m-jobs']:setLobbyData(client, 'cart:player', nil)
    unbindKey(client, 'f', 'down', leaveCart)
    toggleCartControls(client, true)
    removeElementData(client, 'player:animation')
    
    exports['m-jobs']:setLobbyObjectPosition(client, cartObject, x, y, z, rx, ry, rz)
    setPlayerOnHitCooldown(client)
end)

function detachCartFromPlayer(player)
    local cartPlayer = exports['m-jobs']:getLobbyData(player, 'cart:player')
    if cartPlayer ~= player then return end

    local cartObject = exports['m-jobs']:getLobbyData(player, 'cart:object')
    if not cartObject then return end

    exports['m-jobs']:detachObject(player, cartObject)
    exports['m-jobs']:setLobbyData(player, 'cart:player', nil)
    unbindKey(player, 'f', 'down', leaveCart)
    toggleCartControls(player, true)
    removeElementData(player, 'player:animation')
end

function isPlayerHoldingCart(player)
    return exports['m-jobs']:getLobbyData(player, 'cart:player') == player
end