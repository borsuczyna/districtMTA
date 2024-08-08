function createReeferItem(rarity, time)
    return {
        title = 'Reefer',
        description = 'Wynajem kutra rybackiego na ' .. time .. ' minut',
        category = 'fish',
        icon = '/m-inventory/data/icons/reefer.png',
        rarity = rarity,
        onUse = false,

        render = '{description}<div class="label">Kutry mogą być współdzielone z innymi graczami</div>',
    }
end