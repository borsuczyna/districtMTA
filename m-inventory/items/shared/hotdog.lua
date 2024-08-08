function createHotDogItem()
    return {
        title = 'Hotdog',
        description = 'Parówka w bułce z ketchupem i musztardą',
        category = 'food',
        icon = '/m-inventory/data/icons/hot-dog.png',
        rarity = 'common',
        onUse = onHotDogUse,
    }
end