function createTuningItem(type, name, description, icon, rarity)
    return {
        title = name,
        description = description,
        icon = '/m-inventory/data/icons/' .. icon .. '.png',
        rarity = rarity,
        onUse = onTuningUse,

        metadata = {
            noRepeat = true,
        },

        render = [[{description}<br><br>
            ||<div class="label">Typ: ]] .. type .. [[</div>||
        ]],
    }
end