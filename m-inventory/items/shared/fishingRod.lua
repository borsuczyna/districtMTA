function createFishingRodItem(rarity, title, description)
    return {
        title = title,
        description = description,
        category = 'fish',
        icon = '/m-inventory/data/icons/fishing-rod.png',
        rarity = rarity,
        onUse = onFishingRodUse,
    
        metadata = {
            progress = 0,
            equipped = false,
        },
    
        render = [[{description}<br>
            ||<div class="progress">
                <div class="colored-progress-bar" style="width: {metadata.progress}%;"></div>
            </div>
            <div class="label">Postęp: {metadata.progress}%</div>
            <div class="label">Założona: {metadata.equipped}</div>||
        ]],
    }
end