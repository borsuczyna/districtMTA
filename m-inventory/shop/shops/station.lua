function createStationShop(name, x, y, z, interior)
    local items = {
        {item = 'canister', price = 100},
        {item = 'hotDog', price = 50},
        {item = 'nukaCola', price = 20},
    }
    
    local newItems = {}
    for _, item in pairs(items) do
        table.insert(newItems, {category = item.category, item = item.item, price = item.price, type = 'buy'})
    end
    
    return {
        position = {x, y, z},
        name = 'Sklep 24/7',
        description = name,
        items = newItems,
        interior = interior
    }
end
