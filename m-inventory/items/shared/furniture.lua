function createFurnitureItem(name, description, icon, rarity)
    return {
        title = name,
        description = description,
        category = 'furniture',
        icon = '/m-inventory/data/icons/furniture/' .. icon .. '.png',
        rarity = rarity or 'common',
        onUse = onFurnitureUse,

        metadata = {
            equipped = false,
        },
    }
end