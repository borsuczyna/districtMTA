addEvent('login:onPlayerSpawn')

local releasePosition = {2048.382, -1868.778, 13.703}
local objects = {
    {2056.62, -1866.65, 12.7, 0, 0, 0},
    {2053.04, -1866.65, 12.7, 0, 0, 0},
    {2049.48, -1866.65, 12.7, 0, 0, 0},
    {2045.92, -1866.65, 12.7, 0, 0, 0},
    {2042.34, -1866.65, 12.7, 0, 0, 0},
}

local jailPositions = {
    {2049.417, -1865.035, 13.703},
    {2053.339, -1865.310, 13.703},
    {2056.251, -1865.212, 13.703},
    {2045.750, -1865.009, 13.703},
    {2042.010, -1865.078, 13.703},
}

addEventHandler('onResourceStart', resourceRoot, function()
    for i, object in ipairs(objects) do
        local x, y, z, rx, ry, rz = unpack(object)
        local object = createObject(2693, x, y, z, rx, ry, rz)
        setElementData(object, 'element:model', 'models/police_station_ls_celldoor')
    end
    
    for i, position in ipairs(jailPositions) do
        local x, y, z = unpack(position)
        local colShape = createColSphere(x, y, z, 1.9)
        setElementData(colShape, 'jail:sphere', true)
        addEventHandler('onColShapeLeave', colShape, onPlayerLeaveJailSphere)
    end
end)

-- jail code
local jailedPlayers = {}

addCommandHandler('jail', function(player, cmd, playerToFind, time, ...)
    local reason = table.concat({...}, ' ')

    if isPlayerTimedOut(player) then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Zbyt szybko wykonujesz akcje.')
        return
    end

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Nie znaleziono gracza o podanej nazwie.')
        return
    end

    local uid = getElementData(foundPlayer, 'player:uid')
    if not uid then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Ten gracz nie jest zalogowany.')
        return
    end

    if getElementData(foundPlayer, 'player:jail') then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Gracz jest już w więzieniu.')
        return
    end

    if foundPlayer == player then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Nie możesz dać samego siebie do więzienia.')
        return
    end

    local x, y, z = getElementPosition(player)
    local x2, y2, z2 = getElementPosition(foundPlayer)
    local distance = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
    if distance > 10 then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Gracz jest zbyt daleko.')
        return
    end

    local distanceToRelease = getDistanceBetweenPoints3D(x, y, z, unpack(releasePosition))
    if distanceToRelease > 40 then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Jesteś zbyt daleko od więzienia.')
        return
    end

    if not time then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Nie podałeś czasu, użycie: /jail (gracz) (czas, np. 10m) (powód)')
        return
    end

    local timePattern = '(%d+)([dhms])'
    local timeValue, unit = time:match(timePattern)
    if not unit then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Nieprawidłowy format czasu (przykład: 1d, 1h, 1m, 1s)')
        return
    end

    timeValue = tonumber(timeValue)
    if not timeValue then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Nieprawidłowy format czasu (przykład: 1d, 1h, 1m, 1s)')
        return
    end

    local timeUnits = {
        d = 'dni',
        h = 'godzin',
        m = 'minut',
        s = 'sekund',
    }

    local timeUnitName = timeUnits[unit]
    local seconds = timeValue
    if unit == 'd' then
        seconds = timeValue * 24 * 60 * 60
    elseif unit == 'h' then
        seconds = timeValue * 60 * 60
    elseif unit == 'm' then
        seconds = timeValue * 60
    end

    if #reason < 5 then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Podaj powód uwięzienia, minimum 5 znaków.')
        return
    end

    local handuffedBy = getElementData(foundPlayer, 'player:handcuffed')
    if handuffedBy then
        unHandcuffPlayer(foundPlayer)
    end

    putPlayerInJail(foundPlayer, getPlayerName(player), getRealTime().timestamp + seconds, reason)

    exports['m-notis']:addNotification(player, 'success', 'Więzienie', 'Gracz '..htmlEscape(getPlayerName(foundPlayer))..' został uwięziony na '..timeValue..' '..timeUnitName..'.')
    exports['m-notis']:addNotification(foundPlayer, 'error', 'Więzienie', 'Zostałeś uwięziony na '..timeValue..' '..timeUnitName..' przez '..htmlEscape(getPlayerName(player))..'.')
    jailedPlayers[uid] = {
        time = getRealTime().timestamp + seconds,
        playerName = getPlayerName(player),
        reason = reason,
    }
end)

-- unjail command
addCommandHandler('unjail', function(player, cmd, playerToFind)
    if isPlayerTimedOut(player) then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Zbyt szybko wykonujesz akcje.')
        return
    end

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Nie znaleziono gracza o podanej nazwie.')
        return
    end

    local uid = getElementData(foundPlayer, 'player:uid')
    if not uid then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Ten gracz nie jest zalogowany.')
        return
    end

    if not getElementData(foundPlayer, 'player:jail') then
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Gracz nie jest w więzieniu.')
        return
    end

    removePlayerFromJail(foundPlayer)
    jailedPlayers[uid] = nil

    exports['m-notis']:addNotification(player, 'success', 'Więzienie', 'Gracz '..htmlEscape(getPlayerName(foundPlayer))..' został zwolniony z więzienia.')
end)

function putPlayerInJail(player, jailedBy, endTime, reason)
    local seconds = endTime - getRealTime().timestamp

    local randomPosition = jailPositions[math.random(1, #jailPositions)]
    setElementData(player, 'player:jail', endTime)
    setElementData(player, 'player:jailedBy', jailedBy)
    setElementData(player, 'player:jailReason', reason)
    setElementData(player, 'player:jailedPosition', randomPosition)
    
    setElementPosition(player, unpack(randomPosition))
    setTimer(removePlayerFromJail, seconds * 1000, 1, player)

    triggerClientEvent(player, 'jail:setUIVisible', resourceRoot, true)
end

function removePlayerFromJail(player)
    removeElementData(player, 'player:jail')
    removePedFromVehicle(player)
    setElementPosition(player, unpack(releasePosition))
    exports['m-notis']:addNotification(player, 'success', 'Więzienie', 'Zostałeś zwolniony z więzienia.')
    triggerClientEvent(player, 'jail:setUIVisible', resourceRoot, false)
end

function updatePlayerJail(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local jailTime = jailedPlayers[uid]
    if not jailTime then return end

    if jailTime.time > getRealTime().timestamp then
        putPlayerInJail(player, jailTime.playerName, jailTime.time, jailTime.reason)
        exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Opuściłeś grę podczas bycia w więzieniu, wróciłeś do celi.')
    end
end

function onPlayerLeaveJailSphere(player)
    if not getElementData(player, 'player:jail') then return end
    
    exports['m-notis']:addNotification(player, 'error', 'Więzienie', 'Nie możesz opuścić celi więzienia.')
    
    removePedFromVehicle(player)
    local x, y, z = unpack(getElementData(player, 'player:jailedPosition'))
    setElementPosition(player, x, y, z)
end

-- on resource restart remove all players from jail
addEventHandler('onResourceStart', resourceRoot, function()
    for i, player in ipairs(getElementsByType('player')) do
        if getElementData(player, 'player:jail') then
            removePlayerFromJail(player)
        end
    end
end)

-- on relogin
addEventHandler('login:onPlayerSpawn', root, function(player)
    updatePlayerJail(player)
end)