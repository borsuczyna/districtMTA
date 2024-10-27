tuningItems = {
    {
        item = 'spoiler1',
        type = 'Spoiler',
        name = 'Jump Spoiler',
        description = 'Niski, zakrzywiony spoiler dodający stylu do twojego pojazdu',
        icon = 'tuning/Spoiler',
        rarity = 'uncommon',
    },
    {
        item = 'spoiler2',
        type = 'Spoiler',
        name = 'Champ Spoiler',
        description = 'Średni, zakrzywiony, chromowany spoiler dodający agresywnego wyglądu do pojazdu',
        icon = 'tuning/Spoiler2',
        rarity = 'rare',
    },
    {
        item = 'spoiler3',
        type = 'Spoiler',
        name = 'Wind Spoiler',
        description = 'Zakrzywiony do tyłu spoiler, dodający przyczepności do pojazdu',
        icon = 'tuning/Spoiler3',
        rarity = 'epic',
    },
    {
        item = 'spoiler4',
        type = 'Tylny Spoiler',
        name = 'Huge Spoiler',
        description = 'Ogromny spoiler na tył pojazdu',
        icon = 'tuning/Spoiler4',
        rarity = 'exotic',
    },
    {
        item = 'fbumper1',
        type = 'Przedni zderzak',
        name = 'Champ Przedni zderzak',
        description = 'Niski zderzak z chromowanymi akcentami',
        icon = 'tuning/BumperFront1',
        rarity = 'epic',
    },
    {
        item = 'fbumper2',
        type = 'Przedni zderzak',
        name = 'Grind Przedni zderzak',
        description = 'Niski zderzak z czarnymi akcentami',
        icon = 'tuning/BumperFront2',
        rarity = 'rare',
    },
    {
        item = 'rbumper1',
        type = 'Tylny zderzak',
        name = 'Champ Tylny zderzak',
        description = 'Niski zderzak z chromowanymi akcentami',
        icon = 'tuning/BumperRear1',
        rarity = 'epic',
    },
    {
        item = 'rbumper2',
        type = 'Tylny zderzak',
        name = 'Jack Tylny zderzak',
        description = 'Prosty, standardowy zderzak',
        icon = 'tuning/BumperRear2',
        rarity = 'uncommon',
    },
    {
        item = 'hoodvent1',
        type = 'Wenty na maske',
        name = 'Champ Vents',
        description = 'Wloty powietrza na maske',
        icon = 'tuning/RoofAirIntake',
        rarity = 'uncommon',
    },
}

function getTuningItems()
    return tuningItems
end

function getTuningItem(item)
    for _, item in pairs(tuningItems) do
        if item.item == item then
            return item
        end
    end
end