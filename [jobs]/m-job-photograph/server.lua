local playerBlips = {}
local playerTimers = {}
local playerTargets = {}
local playersHistory = {}
local timeouts = {}

addEvent('photograph:onPlayerPhoto', true)

local function setBlipForPlayer(player, noNoti)
    if timeouts[player] and getTickCount() < timeouts[player] then return end
    if playerBlips[player] then
        destroyElement(playerBlips[player])
        playerBlips[player] = nil
    end

    playerTargets[player] = nil

    local randomPlayer = getRandomPlayerInDistanceWithIgnored(player, 100, playersHistory[player])
    if randomPlayer then
        playerBlips[player] = createBlipAttachedTo(randomPlayer, 41)
        setElementVisibleTo(playerBlips[player], root, false)
        setElementVisibleTo(playerBlips[player], player, true)
        playerTargets[player] = randomPlayer

        exports['m-notis']:addNotification(player, 'info', 'Fotograf', 'Został wyznaczony nowy gracz. Udaj się do niego, aby zrobić zdjęcie.')
    elseif not noNoti then
        exports['m-notis']:addNotification(player, 'error', 'Fotograf', 'Brak dostępnych graczy w pobliżu.')
    end
end

local function checkPlayerDistanceAndUpdate(player)
    if playerBlips[player] then
        local px, py, pz = getElementPosition(player)
        local tx, ty, tz = getElementPosition(playerBlips[player])

        local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)
        if distance > 100 then
            exports['m-notis']:addNotification(player, 'info', 'Fotograf', 'Zbyt daleko od wyznaczonego gracza, wyznaczam nowego!')
            setBlipForPlayer(player)
        end
    else
        if getPedWeapon(player) == 43 then
            setBlipForPlayer(player, true)
        end
    end
end

local function onPickupHit(player)
    if getPickupType(source) == 2 and getPickupWeapon(source) == 43 then
        exports['m-notis']:addNotification(player, 'success', 'Fotograf', 'Odebrałeś swój aparat. Udaj się do wyznaczonego blipa na mapie i zrób zdjęcie graczowi, aby otrzymać pieniądze.')
        setBlipForPlayer(player)

        if playerTimers[player] then
            killTimer(playerTimers[player])
            playerTimers[player] = nil
        end
    end
end

addEventHandler('onPickupHit', root, onPickupHit)

addEventHandler('photograph:onPlayerPhoto', resourceRoot, function(elementsOnPhoto)
    if not getElementData(client, 'player:uid') then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    if getPedWeapon(client) ~= 43 then return end

    local targetPlayer = playerTargets[client]
    if not targetPlayer then return end

    if table.includes(elementsOnPhoto, targetPlayer) then
        exports['m-notis']:addNotification(client, 'success', 'Fotograf', 'Zdjęcie zrobione poprawnie, następna osoba zostanie wyznaczona za 10 minut.')
        exports['m-core']:givePlayerMoney(client, 'job', ('Sfotografowanie gracza %s'):format(getPlayerName(targetPlayer)), moneyPerPhoto)

        playerTargets[client] = nil
        destroyElement(playerBlips[client])
        playerBlips[client] = nil

        timeouts[client] = getTickCount() + 600000
        playersHistory[client] = playersHistory[client] or {}
        table.insert(playersHistory[client], targetPlayer)

        setTimer(function()
            -- table.remove(playersHistory[client], 1)
            table.removeElement(playersHistory[client], targetPlayer)
        end, 300000, 1)
    end
end)

setTimer(function()
    for i, player in ipairs(getElementsByType('player')) do
        checkPlayerDistanceAndUpdate(player)
    end
end, 1000, 0)
