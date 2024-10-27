itemsData = {
    m4 = createM4Item(),
    canister = createCanisterItem(),
    spray = createSprayItem(),
    liquidRegret = createLiquidRegretItem(),
    blankCard = createBlankCardItem(),
    nukaCola = createNukaColaItem(),
    hotDog = createHotDogItem(),
    potion = createPotionItem(),
    bait = createBaitItem(),
    wire = createWireItem(),
    
    reefer10 = createReeferItem('uncommon', 10),
    reefer30 = createReeferItem('rare', 30),
    reefer60 = createReeferItem('epic', 60),

    fishingRodCommon = createFishingRodItem('common', 'Wędka', 'Podstawowa wędka'),
    fishingRodUncommon = createFishingRodItem('uncommon', 'Posklejana wędka', 'Wędka posklejana stalową linką'),
    fishingRodRare = createFishingRodItem('rare', 'Umocniona wędka', 'Umocniona stalowa wędka'),
    fishingRodEpic = createFishingRodItem('epic', 'Metalowa wędka', 'Wędka z wytrzymałego metalu'),
    fishingRodLegendary = createFishingRodItem('legendary', 'Ulepszeona wędka', 'Posiada ulepszony kołowrotek'),
    fishingRodMythic = createFishingRodItem('mythic', 'Mocna wędka', 'Wędka z dodatkowym uchwytem'),
    fishingRodExotic = createFishingRodItem('exotic', 'Długa wędka', 'Bardzo długa wędka'),
    fishingRodDivine = createFishingRodItem('divine', 'Mechaniczna wędka', 'Posiada automatyczny kołowrotek'),

    -- 6 common
    smallFry = createFishItem('common', 'Small Fry', 'Jasnoniebieska mini rybka', 'lb-small-fry'),
    orangeFlopper = createFishItem('common', 'Orange Flopper', 'Pomarańczowa pospolita ryba', 'orange-flopper'),
    slurpJellyfish = createFishItem('common', 'Slurp Jellyfish', 'Niebieska meduza', 'slurp-jellyfish'),
    moltenSpicyFish = createFishItem('common', 'Spicy Fish', 'Wędrownik alpejski', 'molten-spicy-fish'),
    driftSpicyFish = createFishItem('common', 'Spicy Fish', 'Wędrownik potokowy', 'drift-spicy-fish'),

    -- 5 uncommon
    greenFlopper = createFishItem('uncommon', 'Green Flopper', 'Zielona pospolita ryba', 'green-flopper'),
    lbShieldFish = createFishItem('uncommon', 'Shield Fish', 'Napierak błękitny', 'lb-shield-fish'),
    blueSlurpfish = createFishItem('uncommon', 'Slurp Fish', 'Niebieska oceanica', 'blue-slurpfish'),
    southernSpicyFish = createFishItem('uncommon', 'Spicy Fish', 'Rzutnik południowy', 'southern-spicy-fish'),
    sbSpicyFish = createFishItem('uncommon', 'Spicy Fish', 'Rzutnik północny', 'sb-spicy-fish'),
    
    -- 4 rare
    peelyJellyfish = createFishItem('rare', 'Jellyfish', 'Jaskrawa meduza', 'peely-jellyfish'),
    blueFlopper = createFishItem('rare', 'Blue Flopper', 'Niebieska pospolita ryba', 'blue-flopper'),
    bbShieldFish = createFishItem('rare', 'Shield Fish', 'Napierak czarny', 'bb-shield-fish'),
    yellowSlurpfish = createFishItem('rare', 'Slurp Fish', 'Złota owocnica', 'yellow-slurpfish'),
    
    -- 4 epic
    blackSlurpfish = createFishItem('epic', 'Slurp Fish', 'Czarna owocnica', 'black-slurpfish'),
    blackSmallFry = createFishItem('epic', 'Small Fry', 'Czarna mini rybka', 'black-small-fry'),
    purpleJellyfish = createFishItem('epic', 'Jellyfish', 'Fioletowa meduza', 'purple-jellyfish'),
    wsSpicyFish = createFishItem('epic', 'Spicy Fish', 'Wędrownik wodospadowy', 'ws-spicy-fish'),

    -- 3 legendary
    bsShieldFish = createFishItem('legendary', 'Shield Fish', 'Lśniący napierak', 'bs-shield-fish'),
    darkVanguardJellyfish = createFishItem('legendary', 'Jellyfish', 'Ciemna meduza', 'dark-vanguard-jellyfish'),
    cuddleJellyfish = createFishItem('legendary', 'Jellyfish', 'Meduza miłosna', 'cuddle-jellyfish'),

    -- 2 mythic
    chumHopFlopper = createFishItem('mythic', 'Hop Flopper', 'Skoczek chumowy', 'chum-hop-flopper'),
    atlanticHopFlopper = createFishItem('mythic', 'Hop Flopper', 'Skoczek atlantycki', 'atlantic-hop-flopper'),

    -- 2 exotic
    chinhookHopFlopper = createFishItem('exotic', 'Hop Flopper', 'Skoczek chinhookowy', 'chinhook-hop-flopper'),
    cohoHopFlopper = createFishItem('exotic', 'Hop Flopper', 'Skoczek cohowy', 'coho-hop-flopper'),

    -- 1 divine
    divineHopFlopper = createFishItem('divine', 'Hop Flopper', 'Skoczek boski', 'drift-hop-flopper'),

    -- All fish inside one item, for example selling
    allFish = createFishItem('common', 'Wszystkie ryby', 'Wszystkie typy ryb', 'lb-small-fry'),

    -- traces
    trace1 = createTraceItem(1, 'Smugi UFO', 'Fioletowe ślady do hulajnogi elektrycznej', 'epic'),
    trace2 = createTraceItem(2, 'Szlamiaste smugi', 'Neonowe ślady do hulajnogi elektrycznej', 'uncommon'),
    trace3 = createTraceItem(3, 'Jesienne smugi', 'Ślady do hulajnogi elektrycznej w jeśienne liście', 'uncommon'),
    trace4 = createTraceItem(4, 'Smugi nieskończoności', 'Pomarańczowo fioletowe smugi nieskończoności', 'rare'),
    trace5 = createTraceItem(5, 'Upiorne smugi', 'Smugi w kształcie twarzy ducha', 'epic'),

    -- dist
    dist = createDistItem(),
}

-- furnitures
for _,data in pairs(furnitures) do
    itemsData[data.item] = createFurnitureItem(data.name, data.description, data.icon, data.rarity)
end

-- cosmetics
for _, data in pairs(cosmetics) do
    itemsData[data.item] = createCosmeticItem(data.type, data.name, data.description, data.icon, data.rarity)
end

-- tuning items
for _, data in pairs(tuningItems) do
    itemsData[data.item] = createTuningItem(data.type, data.name, data.description, data.icon, data.rarity)
end

function getItemName(item)
    if type(item) == 'table' then
        return itemsData[item.item].title
    end

    return itemsData[item].title
end

function getItemIcon(item)
    if type(item) == 'table' then
        return itemsData[item.item].icon
    end

    return itemsData[item].icon
end

function getItemData(item)
    if type(item) == 'table' then
        return itemsData[item.item]
    end

    return itemsData[item]
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