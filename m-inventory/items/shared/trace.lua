function createTraceItem(id, name, description, rarity)
    return {
        title = name,
        description = description,
        category = 'vehicle',
        icon = '/m-inventory/data/icons/traces/' .. id .. '.png',
        rarity = rarity,
        onUse = onTraceUse,

        metadata = {
            equipped = false,
        },

        render = [[{description}<br>
            ||<div class="label">Założone: {metadata.equipped}</div>||
        ]],
    }
end