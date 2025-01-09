function createNukaColaItem()
    return {
        title = 'Nuka Cola',
        description = 'Napój gazowany z postapokaliptycznego świata',
        category = 'food',
        icon = '/m-inventory/data/icons/nukacola.png',
        rarity = 'common',
        onUse = onNukaColaUse,
    }
end