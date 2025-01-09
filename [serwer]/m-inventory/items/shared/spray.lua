function createSprayItem()
    return {
        title = 'Spray',
        description = 'Spray służący do malowania pojazdów',
        category = 'vehicle',
        icon = '/m-inventory/data/icons/spray.png',
        rarity = 'uncommon',
        onUse = onSprayUse,

        metadata = {
            progress = 0,
            equipped = false,
        },

        render = [[{description}<br>||
            <br>Kolor: <span style="background: {metadata.color}; min-width: 2rem; display: inline-block; height: 1rem; border-radius: 0.2rem;"></span><br>
            Typ farby: Kolor {metadata.type}||
        ]],
    }
end