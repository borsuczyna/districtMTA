function createStationShop(name, x, y, z)
    local items = {
        {category = 'Pojazdy', item = 'canister', price = 100},
        {category = 'Jedzenie', item = 'hotDog', price = 50}
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
    }
end
