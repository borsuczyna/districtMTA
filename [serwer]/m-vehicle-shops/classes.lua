function CarsShop(x, y, z, vehicles)
    return {
        position = {x, y, z},
        vehicles = vehicles,
    }
end

function CheapCar(models, position, exitPosition)
    return {
        models = models,
        position = position,
        exitPosition = exitPosition,
        quality = {0, 1, 2},
        fuel = {0, 50},
        maxFuel = {30, 60, 5},
        engineCapacity = {1.2, 2.0, 0.2},
        mileage = {80000, 240000, 1},
        fuelType = {'petrol', 'diesel'},
        rotationTime = 20,
        countSpawn = {1, 5},
    }
end

function GoodCar(models, position, exitPosition)
    return {
        models = models,
        position = position,
        exitPosition = exitPosition,
        quality = {3},
        fuel = {60, 60},
        maxFuel = {30, 60, 5},
        engineCapacity = {1.8, 2.2, 0.2},
        mileage = {10000, 30000, 1},
        fuelType = {'petrol', 'diesel'},
        rotationTime = 20,
        countSpawn = {1, 5},
    }
end

function LuxuryCar(models, position, exitPosition)
    return {
        models = models,
        position = position,
        exitPosition = exitPosition,
        quality = {3},
        fuel = {60, 60},
        maxFuel = {50, 75, 5},
        engineCapacity = {1.8, 3, 0.2},
        mileage = {0, 1, 1},
        fuelType = {'petrol', 'diesel'},
        rotationTime = 60,
        countSpawn = {1, 5},
    }
end

-- useful

function randomWithStep(first, last, stepSize)
    local steps = (last - first) / stepSize
    local steps = math.abs(steps)
    local step = math.random(0, steps)
    return first + step * stepSize
end

function getVehiclePrice(model)
    local price = vehiclePrices[model]
    if not price then
        return false
    end

    return randomWithStep(price[1], price[2], price[3])
end

function getRandomVehicleDamage(quality)
    local wheels = {0, 0, 0, 0}
    local panels = {0, 0, 0, 0, 0, 0, 0}
    local doors = {0, 0, 0, 0, 0, 0}
    local lights = {0, 0, 0, 0}

    local function getRandomDamage(possibleStates, count)
        local result = {}
        for i = 1, count do
            result[i] = possibleStates[math.random(1, #possibleStates)]
        end
        return result
    end

    if quality == 0 then
        wheels = getRandomDamage({0, 0, 1}, 4)
        panels = getRandomDamage({0, 1, 2, 3}, 7)
        doors = getRandomDamage({0, 0, 0, 2}, 6)
        lights = getRandomDamage({0, 0, 0, 1}, 4)
    elseif quality == 1 then
        wheels = getRandomDamage({0, 0, 0, 0, 0, 1}, 4)
        panels = getRandomDamage({0, 0, 0, 0, 1, 1, 2}, 7)
        doors = getRandomDamage({0, 0, 0, 0, 2}, 6)
        lights = getRandomDamage({0, 0, 0, 0, 1}, 4)
    elseif quality == 2 then
        wheels = getRandomDamage({0}, 4)
        panels = getRandomDamage({0, 0, 0, 0, 0, 1}, 7)
        doors = getRandomDamage({0, 0, 0, 0, 0, 0, 0, 0, 2}, 6)
        lights = getRandomDamage({0}, 4)
    end

    return wheels, panels, doors, lights
end

function iter(s, e, func)
    local t = {}
    for i = s, e do
        table.insert(t, func(i))
    end
    return t
end