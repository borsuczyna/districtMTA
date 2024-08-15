furnitures = {
    {
        item = 'toilet1',
        category = 'toilet',
        name = 'Toaleta',
        description = 'Toaleta w kształcie klasycznej muszli klozetowej',
        icon = 'toilet-1',
        model = 2525,
        rarity = 'common',
        price = 60,
    },
    {
        item = 'toilet2',
        category = 'toilet',
        name = 'Toaleta',
        description = 'Toaleta w kształcie klasycznej muszli klozetowej',
        icon = 'toilet-2',
        model = 2521,
        rarity = 'uncommon',
        price = 90,
    },
    {
        item = 'toilet3',
        category = 'toilet',
        name = 'Toaleta',
        description = 'Nowoczesna toaleta',
        icon = 'toilet-3',
        model = 2528,
        rarity = 'rare',
        price = 120,
    },
    {
        item = 'soap1',
        category = 'toilet',
        name = 'Dyspenser do mydła',
        description = 'Dyspenser do mydła w płynie',
        icon = 'soap-1',
        model = 2741,
        rarity = 'common',
        price = 40,
    },
}

function getFurnitures()
    return furnitures
end

function getFurniture(item)
    for _, furniture in pairs(furnitures) do
        if furniture.item == item then
            return furniture
        end
    end
end

function getFurnituresByCategory(category)
    local items = {}
    for _, furniture in pairs(furnitures) do
        if furniture.category == category then
            table.insert(items, furniture)
        end
    end
    return items
end