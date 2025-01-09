local clientSide = localPlayer

function createFoodCart(name, x, y, z, rot)
    rot = rot or 0
    local items = {
        {item = 'hotDog', price = 1000},
        {item = 'nukaCola', price = 500}
    }
    
    local newItems = {}
    for _, item in pairs(items) do
        table.insert(newItems, {category = item.category, item = item.item, price = item.price, type = 'buy'})
    end

    if clientSide then
        local object = createObject(1340, x, y, z, 0, 0, rot)
        setElementFrozen(object, true)
        setObjectBreakable(object, false)

        local px, py = getPointFromDistanceRotation(x, y, 1.2, rot-90)
        local ped = createPed(168, px, py, z, rot - 90)
        setElementFrozen(ped, true)
        addEventHandler('onClientPedDamage', ped, function() cancelEvent() end)
    end
    
    x, y = getPointFromDistanceRotation(x, y, 1.2, rot+90)
    return {
        position = {x, y, z},
        name = 'Budka z jedzeniem',
        description = name,
        items = newItems,
    }
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(angle - 90)
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist
    return x + dx, y + dy
end