itemsData = {
    m4 = createM4Item(),
    hotDog = createHotDogItem(),
    potion = createPotionItem(),
    bait = createBaitItem(),
    wire = createWireItem(),
    fishingRod = createFishingRodItem('common'),
    fishingRodUncommon = createFishingRodItem('uncommon'),
    fishingRodRare = createFishingRodItem('rare'),
    fishingRodEpic = createFishingRodItem('epic'),
    fishingRodLegendary = createFishingRodItem('legendary'),
    fishingRodMythic = createFishingRodItem('mythic'),
    fishingRodExotic = createFishingRodItem('exotic'),
    fishingRodDivine = createFishingRodItem('divine'),
}

function getItemName(item)
    return itemsData[item].title
end

function getItemData(item)
    if type(item) == 'string' then
        return itemsData[item]
    elseif type(item) == 'table' then
        return itemsData[item.item]
    end
end

function generateHash()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local length = 16
    local hash = ''

    for i = 1, length do
        local randomIndex = math.random(1, #chars)
        hash = hash .. chars:sub(randomIndex, randomIndex)
    end

    return hash
end