function createCosmeticItem(type, name, description, icon, rarity)
    return {
        title = name,
        description = description,
        icon = '/m-inventory/data/icons/' .. icon .. '.png?1',
        rarity = rarity,
        onUse = onCosmeticUse,

        metadata = {
            equipped = false,
        },

        render = [[{description}<br><br>
            ||<div class="label">Typ: ]] .. type .. [[</div>||
            ||<div class="label">Założone: {metadata.equipped}</div>||
        ]],
    }
end