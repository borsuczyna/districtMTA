function createFishItem(rarity, title, description, icon)
    return {
        title = title,
        description = description,
        category = 'fish',
        icon = '/m-inventory/data/icons/' .. icon .. '.png',
        rarity = rarity,
        onUse = false,
    }
end