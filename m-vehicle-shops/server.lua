addEvent('vehicle-shops:buyVehicle')

local function randomVehicleProperties(shopId, vehicleId, vehicle)
    local vehicleData = vehicleShops[shopId].vehicles[vehicleId]
    if not vehicleData then return end

    local maxFuel = getElementData(vehicle, 'vehicle:shop:maxFuel')
    local fuel = math.min(maxFuel, math.random(unpack(vehicleData.fuel)))
    local mileage = randomWithStep(unpack(vehicleData.mileage))
    
    setElementData(vehicle, 'vehicle:shop:fuel', fuel, false)
    setElementData(vehicle, 'vehicle:shop:mileage', mileage, false)

    setVehicleColor(vehicle, math.random(0, 255), math.random(0, 255), math.random(0, 255), math.random(0, 255))
end

local function randomVehicleDamage(shopId, vehicleId, vehicle)
    local vehicleData = vehicleShops[shopId].vehicles[vehicleId]
    if not vehicleData then return end

    local quality = getElementData(vehicle, 'vehicle:shop:quality')
    local wheels, panels, doors, lights = getRandomVehicleDamage(quality)
    setVehicleWheelStates(vehicle, unpack(wheels))
    
    for i = 0, 6 do
        setVehiclePanelState(vehicle, i, panels[i] or 0)
    end

    for i = 0, 5 do
        setVehicleDoorState(vehicle, i, doors[i] or 0)
    end

    for i = 0, 3 do
        setVehicleLightState(vehicle, i, lights[i] or 0)
    end
end

local function makeVehicleRotation(shopId, vehicleId, vehicle)
    local data = vehicleShops[shopId].vehicles[vehicleId]
    local model = data.models[math.random(1, #data.models)]
    local price = getVehiclePrice(model)
    local quality = data.quality[math.random(1, #data.quality)]
    local maxFuel = randomWithStep(unpack(data.maxFuel))
    local engineCapacity = randomWithStep(unpack(data.engineCapacity))
    local fuelType = data.fuelType[math.random(1, #data.fuelType)]
    local exitPosition = data.exitPosition
    local rotationTime = data.rotationTime * 60 * 60 * 1000
    data.count = math.random(unpack(data.countSpawn))
    
    -- setElementModel(vehicle, model)
    exports['m-models']:setVehicleModel(vehicle, model)
    setElementData(vehicle, 'vehicle:shop', shopId, false)
    setElementData(vehicle, 'vehicle:shop-vehicle', vehicleId, false)
    setElementData(vehicle, 'vehicle:shop:price', price, false)
    setElementData(vehicle, 'vehicle:shop:quality', quality, false)
    setElementData(vehicle, 'vehicle:shop:maxFuel', maxFuel, false)
    setElementData(vehicle, 'vehicle:shop:engineCapacity', engineCapacity, false)
    setElementData(vehicle, 'vehicle:shop:fuelType', fuelType, false)
    setElementData(vehicle, 'vehicle:shop:exitPosition', exitPosition, false)
    setElementData(vehicle, 'vehicle:shop:rotationTime', getRealTime().timestamp + rotationTime / 1000, false)
    randomVehicleProperties(shopId, vehicleId, vehicle)
    randomVehicleDamage(shopId, vehicleId, vehicle)

    setTimer(makeVehicleRotation, rotationTime, 1, shopId, vehicleId, vehicle)

    local x, y, z = getElementPosition(vehicle)
    if z > 10000 then
        setElementPosition(vehicle, x, y, z - 10000)
    end
end

local function createVehicleRotation(shopId, vehicleId, rotation)
    local model = rotation.models[math.random(1, #rotation.models)]
    local x, y, z, rx, ry, rz = unpack(rotation.position)

    local vehicle = createVehicle(400, x, y, z, rx, ry, rz)
    local colshape = createColSphere(x, y, z, 3)
    attachElements(colshape, vehicle)
    setElementData(colshape, 'vehicle:shop-vehicle', vehicle)
    addEventHandler('onColShapeHit', colshape, hitVehicleShopColshape)
    setElementFrozen(vehicle, true)
    
    rotation.vehicle = vehicle

    makeVehicleRotation(shopId, vehicleId, vehicle)
end

function createVehicleShop(shopId, shop)
    shop.blip = createBlip(shop.position[1], shop.position[2], shop.position[3], 55, 2, 255, 0, 0, 255, 0, 9999)
    setElementData(shop.blip, 'blip:hoverText', 'Salon samochodowy')

    for vehicleId, rotation in ipairs(shop.vehicles) do
        createVehicleRotation(shopId, vehicleId, rotation)
    end
end

function getShopVehicleData(shopId, vehicleId)
    local vehicleData = vehicleShops[shopId].vehicles[vehicleId]
    if not vehicleData then return end

    local vehicle = vehicleData.vehicle
    if not vehicle then return end

    return {
        name = exports['m-models']:getVehicleName(vehicle),
        shopId = shopId,
        vehicleId = vehicleId,
        price = getElementData(vehicle, 'vehicle:shop:price'),
        quality = getElementData(vehicle, 'vehicle:shop:quality'),
        maxFuel = getElementData(vehicle, 'vehicle:shop:maxFuel'),
        fuel = getElementData(vehicle, 'vehicle:shop:fuel'),
        engineCapacity = getElementData(vehicle, 'vehicle:shop:engineCapacity'),
        mileage = getElementData(vehicle, 'vehicle:shop:mileage'),
        fuelType = getElementData(vehicle, 'vehicle:shop:fuelType'),
        exitPosition = getElementData(vehicle, 'vehicle:shop:exitPosition'),
        rotationTime = getElementData(vehicle, 'vehicle:shop:rotationTime'),
        vehicleName = exports['m-models']:getVehicleName(vehicle),
        count = vehicleData.count,
    }, vehicle
end

function hitVehicleShopColshape(hitElement, matchingDimension)
    if getElementType(hitElement) ~= 'player' or not matchingDimension then return end

    local vehicle = getElementData(source, 'vehicle:shop-vehicle')
    local shopId = getElementData(vehicle, 'vehicle:shop')
    local vehicleId = getElementData(vehicle, 'vehicle:shop-vehicle')
    local vehicleData = vehicleShops[shopId].vehicles[vehicleId]
    if not vehicleData then return end

    local data = getShopVehicleData(shopId, vehicleId)
    if not data then return end
    
    triggerClientEvent(hitElement, 'vehicle-shop:show', resourceRoot, data)
end

function decreaseVehicleCount(shopId, vehicleId)
    local vehicleData = vehicleShops[shopId].vehicles[vehicleId]
    if not vehicleData then return end

    vehicleData.count = vehicleData.count - 1
    if vehicleData.count <= 0 then
        local x, y, z = getElementPosition(vehicleData.vehicle)
        setElementPosition(vehicleData.vehicle, x, y, z + 10000)
    end
end

addEventHandler('onVehicleStartEnter', root, function(player, seat, jacked)
    if getElementData(source, 'vehicle:shop') then
        cancelEvent()
    end
end)

addEventHandler('vehicle-shops:buyVehicle', root, function(hash, player, shopId, vehicleId)
    local data, vehicle = getShopVehicleData(shopId, vehicleId)
    if not data or not vehicle then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono pojazdu.'})
        return
    end

    if getPlayerMoney(player) < data.price then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie masz wystarczająco pieniędzy.'})
        return
    end

    if data.count <= 0 then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Brak pojazdów w sklepie.'})
        return
    end

    -- local vehicleName = getVehicleNameFromModel(getElementModel(vehicle))
    local vehicleName = exports['m-models']:getVehicleName(vehicle)
    exports['m-core']:givePlayerMoney(player, 'vehicle-buy', 'Zakup pojazdu ' .. vehicleName .. ' w sklepie', -data.price)
    setElementData(player, 'player:boughtCars', (getElementData(player, 'player:boughtCars') or 0) + 1)

    decreaseVehicleCount(shopId, vehicleId)

    -- local wheels, panels, doors, lights = getRandomVehicleDamage(data.quality)
    local panels = iter(0, 6, function(i)
        return getVehiclePanelState(vehicle, i)
    end)
    local doors = iter(0, 5, function(i)
        return getVehicleDoorState(vehicle, i)
    end)
    local lights = iter(0, 3, function(i)
        return getVehicleLightState(vehicle, i)
    end)
    local wheels = {getVehicleWheelStates(vehicle)}
    
    local data = {
        -- model = getElementModel(vehicle),
        model = getElementData(vehicle, 'vehicle:model'),
        position = data.exitPosition,
        fuel = data.fuel,
        maxFuel = data.maxFuel,
        engineCapacity = data.engineCapacity,
        mileage = data.mileage,
        fuelType = data.fuelType,
        color = {getVehicleColor(vehicle)},
        wheels = wheels,
        panels = panels,
        doors = doors,
        lights = lights,
    }

    randomVehicleProperties(shopId, vehicleId, vehicle)
    randomVehicleDamage(shopId, vehicleId, vehicle)

    exports['m-core']:createPrivateVehicle(player, hash, data)
end)

addEventHandler('onResourceStart', resourceRoot, function()
    for shopId, shop in ipairs(vehicleShops) do
        createVehicleShop(shopId, shop)
    end
end)