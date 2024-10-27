addEvent('login:onPlayerSpawn')

local timeouts = {}

function isPlayerTimedOut(player)
    if not timeouts[player] then
        timeouts[player] = getTickCount()
        return false
    end

    if getTickCount() - timeouts[player] < 1000 then
        return true
    end

    timeouts[player] = getTickCount()
    return false
end

addCommandHandler('zakuj', function(player, cmd, playerToFind)
    if isPlayerTimedOut(player) then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Zbyt szybko wykonujesz akcje.')
        return
    end

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie znaleziono gracza o podanej nazwie.')
        return
    end


    if foundPlayer == player then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie możesz zakucić samego siebie.')
        return
    end

    -- if found player has already someone handcuffed
    local handcuffing = getElementData(foundPlayer, 'player:handcuffing')
    if handcuffing then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Gracz zakuł innego gracza.')
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'manageFaction', 'defaultEquipment'})
    if not hasPermission then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie posiadasz uprawnień do tej komendy.')
        return
    end

    local uid = getElementData(foundPlayer, 'player:uid')
    if not uid then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Gracz nie jest zalogowany.')
        return
    end

    local px, py, pz = getElementPosition(player)
    local fx, fy, fz = getElementPosition(foundPlayer)
    local distance = getDistanceBetweenPoints3D(px, py, pz, fx, fy, fz)
    if distance > 10 then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Gracz jest zbyt daleko.')
        return
    end

    if getPedOccupiedVehicle(player) then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie możesz tego zrobić będąc w pojeździe.')
        return
    end

    if getPedOccupiedVehicle(foundPlayer) then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie możesz tego zrobić gdy gracz jest w pojeździe.')
        return
    end

    -- if getElementData(foundPlayer, 'player:handcuffed') then
    --     exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Gracz jest już zakuty.')
    --     return
    -- end
    
    local handuffedBy = getElementData(foundPlayer, 'player:handcuffed')
    if handuffedBy then
        if handuffedBy == player then
            exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Gracz jest już zakuty, użyj /odkuj.')
        else
            exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Gracz jest już zakuty przez innego gracza.')
        end

        return
    end

    if getElementData(player, 'player:handcuffing') then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Już masz zakutego gracza.')
        return
    end

    setElementData(foundPlayer, 'player:handcuffed', getElementData(player, 'player:uid'))
    setElementData(player, 'player:handcuffing', getElementData(foundPlayer, 'player:uid'))
    attachElements(foundPlayer, player, 0, 1, 0)
    exports['m-notis']:addNotification(player, 'info', 'Kajdanki', 'Zakuto gracza.')
    exports['m-notis']:addNotification(foundPlayer, 'info', 'Kajdanki', 'Zostałeś zakuty przez gracza '..htmlEscape(getPlayerName(player))..'.')
end)

addCommandHandler('odkuj', function(player, cmd)
    if isPlayerTimedOut(player) then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Zbyt szybko wykonujesz akcje.')
        return
    end

    local hasPermission = exports['m-factions']:doesPlayerHaveAnyFactionPermission(player, 'SAPD', {'manageFaction', 'defaultEquipment'})
    if not hasPermission then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie posiadasz uprawnień do tej komendy.')
        return
    end

    local foundPlayer = getElementData(player, 'player:handcuffing')
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie masz zakutego gracza.')
        return
    end

    foundPlayer = exports['m-core']:getPlayerByUid(foundPlayer)
    if not isElement(foundPlayer) then
        exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Gracz nie jest online.')
        setElementData(player, 'player:handcuffing', false)
        return
    end

    setElementData(foundPlayer, 'player:handcuffed', false)
    setElementData(player, 'player:handcuffing', false)
    detachElements(foundPlayer, player)
    exports['m-notis']:addNotification(player, 'info', 'Kajdanki', 'Odkuto gracza.')
    exports['m-notis']:addNotification(foundPlayer, 'info', 'Kajdanki', 'Zostałeś odkuty przez gracza '..htmlEscape(getPlayerName(player))..'.')
end)

function unHandcuffPlayer(player)
    local handcuffedBy = getElementData(player, 'player:handcuffed')
    if handcuffedBy then
        handcuffedBy = exports['m-core']:getPlayerByUid(handcuffedBy)
        
        if isElement(handcuffedBy) then
            removeElementData(handcuffedBy, 'player:handcuffing')
            removeElementData(handcuffedBy, 'player:handcuffed')
            detachElements(player, handcuffedBy)
        end
    end

    removeElementData(player, 'player:handcuffed')
    removeElementData(player, 'player:handcuffing')
end

-- on player start vehicle enter and has handcuffed player, teleport player to car as passenger
addEventHandler('onVehicleStartEnter', root, function(player, seat, jacked)
    if seat ~= 0 then return end

    local foundPlayer = getElementData(player, 'player:handcuffing')
    if not foundPlayer then return end

    foundPlayer = exports['m-core']:getPlayerByUid(foundPlayer)
    if not isElement(foundPlayer) then return end

    if foundPlayer == player then return end

    if getPedOccupiedVehicle(foundPlayer) then return end

    detachElements(foundPlayer, player)
    warpPedIntoVehicle(foundPlayer, source, findFreeSeat(source, {2, 3, 1}))
    exports['m-notis']:addNotification(player, 'info', 'Kajdanki', 'Gracz został przeniesiony do pojazdu.')
    exports['m-notis']:addNotification(foundPlayer, 'info', 'Kajdanki', 'Zostałeś przeniesiony do pojazdu przez gracza '..htmlEscape(getPlayerName(player))..'.')
end)

-- on player exit vehicle, remove handcuffed player from vehicle
addEventHandler('onVehicleStartExit', root, function(player, seat)
    if seat ~= 0 then return end

    local foundPlayer = getElementData(player, 'player:handcuffing')
    if not foundPlayer then return end

    foundPlayer = exports['m-core']:getPlayerByUid(foundPlayer)
    if not isElement(foundPlayer) then return end

    if getPedOccupiedVehicle(foundPlayer) ~= source then return end

    removePedFromVehicle(foundPlayer)
    attachElements(foundPlayer, player, 0, 1, 0)
    exports['m-notis']:addNotification(player, 'info', 'Kajdanki', 'Gracz został usunięty z pojazdu.')
    exports['m-notis']:addNotification(foundPlayer, 'info', 'Kajdanki', 'Zostałeś usunięty z pojazdu przez gracza '..htmlEscape(getPlayerName(player))..'.')
end)

-- when handcuffed player tries to exit vehicle, cancel it
addEventHandler('onVehicleStartExit', root, function(player, seat)
    local handcuffedBy = getElementData(player, 'player:handcuffed')
    if not handcuffedBy then return end

    cancelEvent()
    exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie możesz opuścić pojazdu będąc zakutym.')
end)

-- when handcuffed player tries to enter vehicle, cancel it
addEventHandler('onVehicleStartEnter', root, function(player, seat, jacked)
    local handcuffedBy = getElementData(player, 'player:handcuffed')
    if not handcuffedBy then return end

    cancelEvent()
    exports['m-notis']:addNotification(player, 'error', 'Kajdanki', 'Nie możesz wsiąść do pojazdu będąc zakutym.')
end)

-- when player logins, check if he was handcuffed and attach him to player
addEventHandler('login:onPlayerSpawn', root, function(player)
    local handuffedBy = false
    local uid = getElementData(player, 'player:uid')

    for i, p in ipairs(getElementsByType('player')) do
        if getElementData(p, 'player:handcuffing') == uid then
            handuffedBy = p
            break
        end
    end

    if not handuffedBy then return end

    setElementData(player, 'player:handcuffed', getElementData(handuffedBy, 'player:uid'))
    attachElements(player, handuffedBy, 0, 1, 0)
    exports['m-notis']:addNotification(player, 'info', 'Kajdanki', 'Wylogowałeś się będąc zakutym.')
    exports['m-notis']:addNotification(handuffedBy, 'info', 'Kajdanki', 'Gracz '..htmlEscape(getPlayerName(player))..' wylogował się będąc zakutym, został przeniesiony do Ciebie.')
end)

function findFreeSeat(vehicle, seats)
    for i, seat in ipairs(seats) do
        if not getVehicleOccupant(vehicle, seat) then
            return seat
        end
    end

    return false
end