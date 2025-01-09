function createStationShop(name, x, y, z, interior)
    local items = {
        {item = 'canister', price = 5499},
        {item = 'hotDog', price = 1000},
        {item = 'nukaCola', price = 500},
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
