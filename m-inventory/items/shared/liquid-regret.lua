function createLiquidRegretItem()
    return {
        title = 'Liquid regret',
        description = 'Mocny napój o orzeźwiającym smaku, który skrywa w sobie nieprzewidywalne konsekwencje',
        category = 'food',
        icon = '/m-inventory/data/icons/liquid-regret.png',
        rarity = 'common',
        onUse = onLiquidRegretUse
    }
end