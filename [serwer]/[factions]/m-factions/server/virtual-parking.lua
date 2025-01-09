addEvent('factions:useVirtualParking')

local factionsVirtualParkings = {}
local factionVehicles = {}
local playersCooldowns = {}

local function onMarkerHit(hitElement, matchingDimension)
    if not matchingDimension or getElementType(hitElement) ~= 'player' then return end
    local player = hitElement

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local faction = getElementData(source, 'marker:vparking-faction')
    if not faction or not player then return end

    local playerFaction = getElementData(player, 'player:duty')
    if playerFaction ~= faction then
        return exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie jesteś na służbie tej frakcji.')
    end

    if not doesPlayerHaveAnyFactionPermission(player, faction, {'virtualParking', 'manageFaction'}) then
        return exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie posiadasz uprawnień do otwarcia tej szafki.')
    end

    triggerClientEvent(player, 'factions:openVirtualParkingPanel', resourceRoot, {
        faction = faction,
        data = getElementData(source, 'marker:vparking-data')
    })
end

local function onMarkerLeave(leaveElement, matchingDimension)
    if not matchingDimension or getElementType(leaveElement) ~= 'player' then return end
    local player = leaveElement

    triggerClientEvent(player, 'factions:closeVirtualParkingPanel', resourceRoot)
end

local function onHideMarkerHit(hitElement, matchingDimension)
    if not matchingDimension or not hitElement or not isElement(hitElement) or getElementType(hitElement) ~= 'player' then return end
    local player = hitElement

    if playersCooldowns[player] and playersCooldowns[player] > getTickCount() then return end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local faction = getElementData(source, 'marker:vparking-faction')
    if not faction or not player then return end

    local playerFaction = getElementData(player, 'player:duty')
    if playerFaction ~= faction then
        return exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie jesteś na służbie tej frakcji.')
    end

    if not doesPlayerHaveAnyFactionPermission(player, faction, {'virtualParking', 'manageFaction'}) then
        return exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie posiadasz uprawnień do otwarcia tej szafki.')
    end

    local vehicle = factionVehicles[player]
    local pedVehicle = getPedOccupiedVehicle(player)
    if not vehicle or vehicle ~= pedVehicle then return end

    destroyElement(vehicle)
    exports['m-notis']:addNotification(player, 'success', ('Frakcja %s'):format(faction), 'Pojazd został odstawiony.')
    factionVehicles[player] = nil
end

function createVirtualParking(faction, position, positionOut, data)
    local marker = createMarker(position[1], position[2], position[3] - 0.95, 'cylinder', 1, 0, 255, 0, 150)
    local markerOut = createMarker(positionOut[1], positionOut[2], positionOut[3] - 0.95, 'cylinder', 4, 0, 0, 255, 150)
    setElementData(marker, 'marker:vparking-faction', faction)
    setElementData(marker, 'marker:vparking-data', data)
    setElementData(marker, 'marker:title', 'Parking wirtualny')
    setElementData(marker, 'marker:desc', 'Wyciąganie pojazdu')

    setElementData(markerOut, 'marker:vparking-faction', faction)
    setElementData(markerOut, 'marker:title', 'Parking wirtualny')
    setElementData(markerOut, 'marker:desc', 'Odstawianie pojazdu')
    addDestroyOnRestartElement(marker, sourceResource)
    addDestroyOnRestartElement(markerOut, sourceResource)

    addEventHandler('onMarkerHit', marker, onMarkerHit)
    addEventHandler('onMarkerLeave', marker, onMarkerLeave)
    addEventHandler('onMarkerHit', markerOut, onHideMarkerHit)

    factionsVirtualParkings[faction] = {
        position = position,
        positionOut = positionOut,
        items = data
    }
end

addEventHandler('factions:useVirtualParking', root, function(hash, player, faction, index)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local data = factionsVirtualParkings[faction]
    local items = data.items
    if not items then return end

    local item = items[tonumber(index) + 1]
    if not item then return end

    local playerDuty = getElementData(player, 'player:duty')
    if playerDuty ~= faction then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś na służbie tej frakcji.'})
        return
    end

    if not doesPlayerHaveAnyFactionPermission(player, faction, item.permissions) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz uprawnień do wzięcia tego pojazdu.'})
        return
    end

    if factionVehicles[player] then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Schowaj poprzedni pojazd przed wyciągnięciem kolejnego.'})
        return
    end

    local vehicle = createVehicle(item.model, unpack(data.positionOut))
    setElementData(vehicle, 'vehicle:faction', faction)
    setElementData(vehicle, 'vehicle:faction-owner', getElementData(player, 'player:uid'))
    
    for k, v in pairs(item.handling or {}) do
        setVehicleHandling(vehicle, k, v)
    end

    factionVehicles[player] = vehicle
    warpPedIntoVehicle(player, vehicle)
    playersCooldowns[player] = getTickCount() + 5000

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pojazd został wyciągnięty.'})
end)

-- non faction players can't enter faction vehicles
addEventHandler('onVehicleStartEnter', root, function(player, seat, jacked)
    if seat ~= 0 then return end

    local faction = getElementData(source, 'vehicle:faction')
    if not faction then return end

    local playerFaction = getElementData(player, 'player:duty')
    if playerFaction ~= faction then
        cancelEvent()
        exports['m-notis']:addNotification(player, 'error', ('Frakcja %s'):format(faction), 'Nie jesteś na służbie tej frakcji.')
    end
end)

-- on player leave game
addEventHandler('onPlayerQuit', root, function()
    local vehicle = factionVehicles[source]
    if not vehicle then return end

    destroyElement(vehicle)
    factionVehicles[source] = nil
end)