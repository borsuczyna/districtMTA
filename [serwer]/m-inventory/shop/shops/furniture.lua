function createFurnitureShop(type, name, x, y, z, interior)
    local items = {}

    for _, item in pairs(getFurnituresByCategory(type)) do
        table.insert(items, {category = name, item = item.item, price = item.price, type = 'buy'})
    end

    return {
        position = {x, y, z},
        name = 'Sklep z meblami',
        description = name,
        items = items,
        interior = interior
    }
end