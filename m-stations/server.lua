addEvent('stations:refill')

local fuelPrices = {
    petrol = 2,
    diesel = 1.5,
    lpg = 1,
}

local fuelNames = {
    petrol = 'Benzyna',
    diesel = 'Diesel',
    lpg = 'Gaz LPG',
}

local stations = {
    {1938.679, -1772.928, 13.383, false},
    {1944.479, -1772.928, 13.383, false},
}

local timeouts = {}

local function getFuelTypeFromName(name)
    for fuelType, fuelName in pairs(fuelNames) do
        if fuelName == name then
            return fuelType
        end
    end
end

local function isPlayerTimedOut(player)
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

local function hitStationMarker(player, matchingDimension)
    if not matchingDimension then return end
    if getElementType(player) ~= 'player' then return end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then return end

    local uid = getElementData(vehicle, 'vehicle:uid')
    if not uid then
        exports['m-notis']:addNotification(player, 'warning', 'Stacja paliw', 'Możesz zatankować tylko pojazdy prywatne.')
        return
    end

    local fuels = {}
    local fuel = getElementData(vehicle, 'vehicle:fuel')
    local maxFuel = getElementData(vehicle, 'vehicle:maxFuel')
    local fuelType = getElementData(vehicle, 'vehicle:fuelType')
    local lpg = getElementData(vehicle, 'vehicle:lpg')
    local lpgFuel = getElementData(vehicle, 'vehicle:lpgFuel')

    table.insert(fuels, {name = fuelNames[fuelType], price = fuelPrices[fuelType], amount = fuel, max = maxFuel})

    if lpg then
        table.insert(fuels, {name = fuelNames.lpg, price = fuelPrices.lpg, amount = lpgFuel, max = 25})
    end

    triggerClientEvent(player, 'stations:showFuelStationsUi', resourceRoot, {
        fuels = fuels,
        vehicleName = getVehicleName(vehicle),
    })
end

local function leaveStationMarker(player, matchingDimension)
    if not matchingDimension then return end
    if getElementType(player) ~= 'player' then return end

    triggerClientEvent(player, 'stations:hideFuelStationsUi', resourceRoot)
end

local function createStation(position)
    local marker = createMarker(position[1], position[2], position[3] - 1, 'cylinder', 3.5, 0, 255, 0, 0)
    setElementData(marker, 'marker:icon', 'station')
    setElementData(marker, 'marker:title', 'Stacja paliw')
    setElementData(marker, 'marker:desc', 'Dystrybutor paliwa')
    setElementData(marker, 'marker:square', position[4] and {5, 3} or {3, 5})
    createBlipAttachedTo(marker, 54, 2, 255, 255, 255, 255, 0, 9999)

    addEventHandler('onMarkerHit', marker, hitStationMarker)
    addEventHandler('onMarkerLeave', marker, leaveStationMarker)
end

addEventHandler('onResourceStart', resourceRoot, function()
    for i, station in ipairs(stations) do
        createStation(station)
    end
end)

addEventHandler('stations:refill', root, function(hash, player, fuelName, amount)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie jesteś w pojeździe.'})
        return
    end

    local uid = getElementData(vehicle, 'vehicle:uid')
    if not uid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Możesz zatankować tylko pojazdy prywatne.'})
        return
    end

    local fuel = getElementData(vehicle, 'vehicle:fuel')
    local maxFuel = getElementData(vehicle, 'vehicle:maxFuel')
    local fuelType = getElementData(vehicle, 'vehicle:fuelType')
    local selectedFuel = getFuelTypeFromName(fuelName)
    local lpg = getElementData(vehicle, 'vehicle:lpg')
    local lpgFuel = getElementData(vehicle, 'vehicle:lpgFuel')

    local price = 0
    if selectedFuel ~= 'lpg' and fuelType ~= selectedFuel then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie możesz zatankować tego paliwa.'})
        return
    elseif selectedFuel == 'lpg' and not lpg then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Twój pojazd nie posiada instalacji gazowej.'})
        return
    end

    if selectedFuel == 'lpg' then
        maxFuel = 25
        amount = math.min(amount, maxFuel - lpgFuel)
        fuel = lpgFuel
    end

    price = fuelPrices[selectedFuel] * amount
    if getPlayerMoney(player) < price then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz wystarczająco pieniędzy.'})
        return
    end

    local possibleFuel = maxFuel - fuel
    amount = math.min(amount, possibleFuel)
    if amount <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Bak jest pełny.'})
        return
    end

    exports['m-core']:givePlayerMoney(player, 'stations', ('Zatankowanie pojazdu %s (%d) - %dL %s'):format(getVehicleName(vehicle), uid, amount, fuelName), -price)
    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Zatankowano pojazd.', fuel = fuel + amount})
    
    if selectedFuel == 'lpg' then
        setElementData(vehicle, 'vehicle:lpgFuel', fuel + amount)
    else
        setElementData(vehicle, 'vehicle:fuel', fuel + amount)
    end
end)