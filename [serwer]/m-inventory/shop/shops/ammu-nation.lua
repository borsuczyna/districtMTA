function createAmmunationShop(name, x, y, z, interior)
    local items = {

    }
    
    local newItems = {}
    for _, item in pairs(items) do
        table.insert(newItems, {category = item.category, item = item.item, price = item.price, type = 'buy'})
    end
    
    return {
        position = {x, y, z},
        name = 'Sklep z bronią',
        description = name,
        items = newItems,
        interior = interior
    }
end
