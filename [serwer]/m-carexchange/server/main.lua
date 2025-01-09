addEvent('carExchange:putUp')
addEvent('carExchange:getCarExchangeOfferData')
addEvent('carExchange:sendCarExchangeOffer')

local timeouts = {}
local carExchangeColshapes = {}

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

function getVehicleCarExchangeColshape(vehicle)
    for i, colshape in ipairs(carExchangeColshapes) do
        if isElementWithinColShape(vehicle, colshape) then
            return colshape, i
        end
    end

    return false
end

function getCarExchangeColshapeIndex(colshape)
    for i, c in ipairs(carExchangeColshapes) do
        if c == colshape then
            return i
        end
    end

    return false
end

local function onPutUpMarkerHit(hitElement, matchingDimension)
    if getElementType(hitElement) ~= 'player' or not matchingDimension then return end

    local vehicle = getPedOccupiedVehicle(hitElement)
    if not vehicle then return end

    local uid = getElementData(hitElement, 'player:uid')
    if not uid then return end

    local vehicleUid = getElementData(vehicle, 'vehicle:uid')
    if not vehicleUid then
        exports['m-notis']:addNotification(hitElement, 'warning', 'Giełda', 'Na giełdę można tylko wystawiać prywatne pojazdy.')
        return
    end

    local owner = getElementData(vehicle, 'vehicle:owner')
    if owner ~= uid then
        exports['m-notis']:addNotification(hitElement, 'warning', 'Giełda', 'Na giełdę można tylko wystawiać swoje pojazdy.')
        return
    end

    local controller = getVehicleController(vehicle)
    if controller ~= hitElement then
        exports['m-notis']:addNotification(hitElement, 'warning', 'Giełda', 'Tylko kierowca pojazdu może wystawić go na giełdę.')
        return
    end

    local prices = getElementData(source, 'marker:carExchange:prices')
    if not prices then return end

    triggerClientEvent(hitElement, 'carExchange:showPutUpWindow', resourceRoot, {
        uid = uid,
        vehicleUid = vehicleUid,
        vehicleName = exports['m-models']:getVehicleName(vehicle),
        tuning = getVehicleTuning(vehicle),
        prices = prices
    })
end

local function onPutUpMarkerLeave(leaveElement, matchingDimension)
    if getElementType(leaveElement) ~= 'player' or not matchingDimension then return end

    triggerClientEvent(leaveElement, 'carExchange:closePutUpWindow', resourceRoot)
end

local function onCarExchangeColshapeLeave(leaveElement, matchingDimension)
    if getElementType(leaveElement) ~= 'vehicle' or not matchingDimension then return end
    local vehicle = leaveElement

    local vehicleUid = getElementData(vehicle, 'vehicle:uid')
    if not vehicleUid then return end

    local carExchange = getElementData(vehicle, 'vehicle:carExchange')
    if not carExchange then return end

    local carExchangeIndex = getCarExchangeColshapeIndex(source)
    if carExchange.carExchangeIndex == carExchangeIndex then
        removeElementData(vehicle, 'vehicle:carExchange')
    end
end

local function createCarExchange(enter, prices, colshape)
    local marker = createMarker(enter[1], enter[2], enter[3] - 0.95, 'cylinder', 4, 0, 255, 0, 150)
    setElementData(marker, 'marker:title', 'Giełda')
    setElementData(marker, 'marker:desc', 'Wystawianie pojazdu')
    setElementData(marker, 'marker:carExchange:prices', prices, false)

    local blip = createBlipAttachedTo(marker, 16, 2, 255, 0, 0, 255, 0, 9999.0, getRootElement())
    setElementData(blip, 'blip:hoverText', 'Giełda samochodowa')

    addEventHandler('onMarkerHit', marker, onPutUpMarkerHit)
    addEventHandler('onMarkerLeave', marker, onPutUpMarkerLeave)

    local colshape = createColCuboid(unpack(colshape))
    setElementData(colshape, 'colshape:carExchange:prices', prices, false)

    addEventHandler('onColShapeLeave', colshape, onCarExchangeColshapeLeave)

    table.insert(carExchangeColshapes, colshape)
end

addEventHandler('carExchange:putUp', root, function(hash, player, vehicleUid, amount)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    vehicleUid = tonumber(vehicleUid)
    amount = tonumber(amount)
    
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local vehicle = exports['m-core']:getVehicleByUid(vehicleUid)
    if not vehicle then return end

    local owner = getElementData(vehicle, 'vehicle:owner')
    if owner ~= uid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Na giełdzie można tylko sprzedawać swoje pojazdy.'})
        return
    end

    local controller = getVehicleController(vehicle)
    if controller ~= player then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Tylko kierowca pojazdu może wystawić go na giełdę.'})
        return
    end

    local colshape, carExchangeIndex = getVehicleCarExchangeColshape(vehicle)
    if not colshape then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Musisz znajdować się na giełdzie, aby wystawić pojazd.'})
        return
    end

    local prices = getElementData(colshape, 'colshape:carExchange:prices')
    if not prices then return end

    if amount < prices[1] or amount > prices[2] then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Podana cena jest poza zakresem.'})
        return
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie wystawiłeś pojazd na giełdę.'})
    setElementData(vehicle, 'vehicle:carExchange', {
        price = tonumber(amount) * 100,
        owner = owner,
        ownerName = getPlayerName(player),
        vehicleName = exports['m-models']:getVehicleName(vehicle),
        tuning = getVehicleTuning(vehicle),
        carExchangeIndex = carExchangeIndex
    })
end)

local function getPlayerExchangeVehicles(player)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local vehicles = getElementsByType('vehicle')
    local exchangeVehicles = {}

    for i, vehicle in ipairs(vehicles) do
        local carExchange = getElementData(vehicle, 'vehicle:carExchange')
        if carExchange and carExchange.owner == uid then
            table.insert(exchangeVehicles, vehicle)
        end
    end

    return exchangeVehicles
end

addEventHandler('carExchange:getCarExchangeOfferData', root, function(hash, player)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local vehicles = getPlayerExchangeVehicles(player)
    local vehiclesData = {}

    for i, vehicle in ipairs(vehicles) do
        table.insert(vehiclesData, {
            uid = getElementData(vehicle, 'vehicle:uid'),
            vehicleName = exports['m-models']:getVehicleName(vehicle),
        })
    end

    local x, y, z = getElementPosition(player)
    local closePlayers = {}
    for i, p in ipairs(getElementsByType('player')) do
        if p ~= player then
            local px, py, pz = getElementPosition(p)
            if getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 10 then
                table.insert(closePlayers, {
                    name = getPlayerName(p),
                    uid = getElementData(p, 'player:uid')
                })
            end
        end
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', data = {vehicles = vehiclesData, players = closePlayers}})
end)

-- exchange
local awaitingOffers = {}

addEventHandler('carExchange:sendCarExchangeOffer', root, function(hash, player, vehicleUid, targetUid, price)
    if isPlayerTimedOut(player) then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Zbyt szybko wykonujesz akcje.'})
        return
    end

    vehicleUid = tonumber(vehicleUid)
    targetUid = tonumber(targetUid)

    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local vehicle = exports['m-core']:getVehicleByUid(vehicleUid)
    if not vehicle then return end

    local owner = getElementData(vehicle, 'vehicle:owner')
    if owner ~= uid then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Na giełdzie można tylko sprzedawać swoje pojazdy.'})
        return
    end

    local targetPlayer = exports['m-core']:getPlayerByUid(targetUid)
    if not targetPlayer then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Gracz nie jest online.'})
        return
    end

    if targetPlayer == player then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie możesz wysłać oferty sam sobie.'})
        return
    end

    local px, py, pz = getElementPosition(player)
    local x, y, z = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, x, y, z) > 10 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Gracz jest zbyt daleko.'})
        return
    end

    if tonumber(price) < 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Podana cena jest nieprawidłowa.'})
        return
    end

    -- find all offers with this vehicle and remove them
    for p, offer in pairs(awaitingOffers) do
        if offer.vehicle == vehicleUid then
            awaitingOffers[p] = nil
        end
    end

    awaitingOffers[targetPlayer] = {
        player = player,
        vehicle = vehicleUid,
        price = tonumber(price) * 100,
        expires = getTickCount() + 30000
    }

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie wysłano ofertę.'})
    exports['m-notis']:addNotification(targetPlayer, 'info', 'Giełda', ('Otrzymałeś ofertę kupna pojazdu od %s.<br>Pojazd: (%d) %s<br>Cena: %s<br>Aby zakupić pojazd wpisz /kuppojazd %d<br><br>Przed kupnem sprawdź czy UID pojazdu się zgadza, administracja nie odpowiada za oszustwa!'):format(getPlayerName(player), vehicleUid, exports['m-models']:getVehicleName(vehicle), addCents(price * 100), vehicleUid), 30000)
end)

-- buy
addCommandHandler('kuppojazd', function(player, cmd, vehicleUid)
    if isPlayerTimedOut(player) then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Zbyt szybko wykonujesz akcje.')
        return
    end

    vehicleUid = tonumber(vehicleUid)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local offer = awaitingOffers[player]
    if not offer then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Nie masz żadnej oferty kupna pojazdu.')
        return
    end

    if offer.vehicle ~= vehicleUid then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Podany UID pojazdu nie zgadza się z ofertą.')
        return
    end

    local targetPlayer = offer.player
    if not isElement(targetPlayer) then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Gracz, który wysłał ofertę nie jest online.')
        return
    end

    local targetUid = getElementData(targetPlayer, 'player:uid')
    if not targetUid then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Gracz, który wysłał ofertę nie jest online.')
        return
    end

    local vehicle = exports['m-core']:getVehicleByUid(vehicleUid)
    if not vehicle then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Podany pojazd nie istnieje.')
        return
    end

    local owner = getElementData(vehicle, 'vehicle:owner')
    if owner ~= targetUid then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Oferta kupna pojazdu jest nieaktualna.')
        return
    end

    local price = offer.price
    if getPlayerMoney(player) < price then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Nie masz wystarczająco pieniędzy.')
        return
    end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        exports['m-notis']:addNotification(player, 'error', 'Giełda', 'Wystąpił błąd podczas zakupu pojazdu.')
        return
    end

    local details1 = ('Kupno pojazdu (%d) %s od %s'):format(vehicleUid, exports['m-models']:getVehicleName(vehicle), getPlayerName(targetPlayer))
    local details2 = ('Sprzedaż pojazdu (%d) %s do %s'):format(vehicleUid, exports['m-models']:getVehicleName(vehicle), getPlayerName(player))
    exports['m-core']:givePlayerMoney(player, 'vehicle-buy', details1, -price)
    exports['m-core']:givePlayerMoney(targetPlayer, 'vehicle-sell', details2, price)

    setElementData(vehicle, 'vehicle:owner', uid)
    setElementData(vehicle, 'vehicle:carExchange', nil)

    exports['m-notis']:addNotification(player, 'success', 'Giełda', 'Pomyślnie zakupiłeś pojazd.')
    exports['m-notis']:addNotification(targetPlayer, 'success', 'Giełda', 'Pomyślnie sprzedałeś pojazd.')
    dbExec(connection, 'UPDATE `m-vehicles` SET `owner` = ? WHERE `uid` = ?', uid, vehicleUid)
end)

function addCents(amount)
    return '$' .. string.format('%0.2f', amount / 100)
end

createCarExchange({1479.557, -1694.691, 13.383}, {0, 5000}, {1440.669, -1699.689, 14.695-2.5, 78, 75, 5})