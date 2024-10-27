cosmetics = {
    {
        item = 'pumpkin1',
        type = 'Czapka',
        name = 'Kapeluśna dynia',
        description = 'Upiorna dynia z pirackim kapeluszem',
        icon = 'halloween1/dynia1',
        rarity = 'rare',

        model = 'halloween1/dynia1',
        bone = 'head',
        position = Vector3(0.12, 0.04, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'pumpkin2',
        type = 'Czapka',
        name = 'Dynia',
        description = 'Upiorna dynia',
        icon = 'halloween1/dynia2',
        rarity = 'rare',

        model = 'halloween1/dynia2',
        bone = 'head',
        position = Vector3(0.12, 0.04, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'pumpkin3',
        type = 'Czapka',
        name = 'Kapeluśna dynia',
        description = 'Czarna upiorna dynia z pirackim kapeluszem',
        icon = 'halloween1/dynia3',
        rarity = 'epic',

        model = 'halloween1/dynia3',
        bone = 'head',
        position = Vector3(0.12, 0.04, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'pumpkin4',
        type = 'Czapka',
        name = 'Dynia',
        description = 'Czarna upiorna dynia',
        icon = 'halloween1/dynia4',
        rarity = 'rare',

        model = 'halloween1/dynia4',
        bone = 'head',
        position = Vector3(0.12, 0.04, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'angry-bag',
        type = 'Czapka',
        name = 'Wściekła torba',
        description = 'Papierowa torba z wściekłym wyrazem twarzy',
        icon = 'halloween1/torbanaleb',
        rarity = 'epic',

        model = 'halloween1/torbanaleb',
        bone = 'head',
        position = Vector3(0.07, 0.01, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'scream-face1',
        type = 'Czapka',
        name = 'Maska krzyku',
        description = 'Maska krzyku z filmu "Krzyk"',
        icon = 'halloween1/maskakrzyk',
        rarity = 'rare',

        model = 'halloween1/maskakrzyk',
        bone = 'head',
        position = Vector3(0.07, 0.06, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'scream-face2',
        type = 'Czapka',
        name = 'Maska krzyku',
        description = 'Maska krzyku z filmu "Krzyk"',
        icon = 'halloween1/maskakrzyk2',
        rarity = 'epic',

        model = 'halloween1/maskakrzyk2',
        bone = 'head',
        position = Vector3(0.07, 0.06, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'bunny-ears1',
        type = 'Czapka',
        name = 'Królicze uszka',
        description = 'Białe królicze uszka',
        icon = 'halloween1/uszykrolika1',
        rarity = 'rare',

        model = 'halloween1/uszykrolika1',
        bone = 'head',
        position = Vector3(0.16, 0.00, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'bunny-ears2',
        type = 'Czapka',
        name = 'Królicze uszka',
        description = 'Ciemne królicze uszka',
        icon = 'halloween1/uszykrolika2',
        rarity = 'rare',

        model = 'halloween1/uszykrolika2',
        bone = 'head',
        position = Vector3(0.16, 0.00, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'alien-backpack',
        type = 'Plecak',
        name = 'Kosmiczny plecak',
        description = 'Zielona maska kosmity na plecy', 
        icon = 'halloween1/plecak',
        rarity = 'rare',

        model = 'halloween1/plecak',
        bone = 4,
        position = Vector3(-0.1, -0.1, 0),
        rotation = Vector3(180, 90, 0),
    },
    {
        item = 'ufo-hat',
        type = 'Czapka',
        name = 'Inwazja kosmitów',
        description = 'Unoszący się nad głową statek UFO, emanujący nieziemskim blaskiem',
        icon = 'cosmetics/ufo-hat',
        rarity = 'epic',

        model = 'ufo3',
        bone = 'head',
        position = Vector3(0.35, -0.03, 0),
        rotation = Vector3(0, 90, 0),
    },
    {
        item = 'foil-hat',
        type = 'Czapka',
        name = 'Hełm zmierzchu',
        description = 'Chroni przed obcymi sygnałami, must-have dla każdego paranoika',
        icon = 'cosmetics/foil-hat',
        rarity = 'common',

        model = 'cosmetics/FoilHat',
        bone = 'head',
        position = Vector3(0.13, 0.012, 0),
        rotation = Vector3(0, 90, 0),
    },
    {
        item = 'alien-glasses',
        type = 'Okulary UFO',
        name = 'Kosmiczne okulary obserwatora',
        description = 'Okulary pozwalające zobaczyć świat oczami kosmitów',
        icon = 'cosmetics/alien-glasses',
        rarity = 'uncommon',

        model = 'cosmetics/AlienGlasses',
        bone = 'head',
        position = Vector3(0.08, 0.12, 0),
        rotation = Vector3(0, 90, 0),
    },
    {
        item = 'ufo-kidney',
        type = 'Nerka',
        name = 'Galaktyczna nerka',
        description = 'Zaginiona galaktyczna nerka która ma nieskończoną pojemność',
        icon = 'cosmetics/ufo-kidney',
        rarity = 'epic',

        model = 'cosmetics/Nerka',
        bone = 4,
        position = Vector3(-0.17, 0.055, -0.01),
        rotation = Vector3(0, 90, 0),
    },
}

function doesPlayerHaveEquippedCosmetic(player, type)
    local cosmetics = getElementData(player, 'player:cosmetics') or {}
    for _, cosmetic in ipairs(cosmetics) do
        if cosmetic.type == type then
            return true
        end
    end
    return false
end
  
function setCosmeticEquipped(player, type, item, equipped)
    local cosmetics = getElementData(player, 'player:cosmetics') or {}
    
    if equipped then
        table.insert(cosmetics, { type = type, item = item })
    else
        for i, cosmetic in ipairs(cosmetics) do
            if cosmetic.type == type and cosmetic.item == item then
                table.remove(cosmetics, i)
                break
            end
        end
    end

    setElementData(player, 'player:cosmetics', cosmetics)
end

function getCosmetics()
    return cosmetics
end

function getCosmetic(item)
    for _, cosmetic in pairs(cosmetics) do
        if cosmetic.item == item then
            return cosmetic
        end
    end
end