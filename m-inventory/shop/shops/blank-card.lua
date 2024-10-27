local clientSide = localPlayer

function createBlankCardShop(name, x, y, z, rot)
    rot = rot or 0
    local items = {
        {item = 'blankCard', price = 20000},
    }
    
    local newItems = {}
    for _, item in pairs(items) do
        table.insert(newItems, {category = item.category, item = item.item, price = item.price, type = 'buy'})
    end

    if clientSide then
        local ped = createPed(309, x, y, z, rot - 90)
        setElementFrozen(ped, true)
        addEventHandler('onClientPedDamage', ped, function() cancelEvent() end)
    end
    
    return {
        position = {x + 1, y, z},
        name = '?',
        description = name,
        items = newItems,
        noBlip = true
    }
end