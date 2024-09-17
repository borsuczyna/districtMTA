function createCanisterItem()
    return {
        title = 'Kanister z benzyną',
        description = 'Pojemnik na benzynę używany do tankowania pojazdów',
        category = 'vehicle',
        icon = '/m-inventory/data/icons/canister.png',
        rarity = 'common',
        onUse = onCanisterUse
    }
end