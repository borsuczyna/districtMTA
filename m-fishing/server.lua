addEvent('fishing:start', true)
addEvent('fishing:catchFish', true)

local catchFishMinigames = {}
local rarityFishes = {
    {
        rarity = 'common',
        items = {'smallFry', 'orangeFlopper', 'slurpJellyfish', 'moltenSpicyFish', 'driftSpicyFish'}
    },
    {
        rarity = 'uncommon',
        items = {'greenFlopper', 'lbShieldFish', 'blueSlurpfish', 'southernSpicyFish', 'sbSpicyFish'}
    },
    {
        rarity = 'rare',
        items = {'peelyJellyfish', 'blueFlopper', 'bbShieldFish', 'yellowSlurpfish'}
    },
    {
        rarity = 'epic',
        items = {'blackSlurpfish', 'blackSmallFry', 'purpleJellyfish', 'wsSpicyFish'}
    },
    {
        rarity = 'legendary',
        items = {'bsShieldFish', 'darkVanguardJellyfish', 'cuddleJellyfish'}
    },
    {
        rarity = 'mythic',
        items = {'chumHopFlopper', 'atlanticHopFlopper'}
    },
    {
        rarity = 'exotic',
        items = {'chinhookHopFlopper', 'cohoHopFlopper'}
    },
    {
        rarity = 'divine',
        items = {'divineHopFlopper'}
    }
}

local function getRandomFish(rarity)
    local possibleFishes = {'wire'}

    local insertFishes = function(fishes)
        for i, fish in ipairs(fishes) do
            table.insert(possibleFishes, fish)
        end
    end

    for i, fishData in ipairs(rarityFishes) do
        insertFishes(fishData.items)
        if fishData.rarity == rarity then break end
    end

    return possibleFishes[math.random(1, #possibleFishes)]
end

function fishingRodHit(player)
    setElementFrozen(player, true)
    setPedAnimation(player, 'SWORD', 'sword_' .. math.random(1, 4), -1, false, true, false, true, 250)
    setTimer(setPedAnimation, 600, 1, player, 'SWORD', 'sword_IDLE')
end

local function getFish(player, rarity)
    local fish = getRandomFish(rarity)
    if not fish then return end

    local icon = exports['m-inventory']:getItemIcon(fish)
    triggerClientEvent(player, 'fishing:catchFish', resourceRoot, icon)
    catchFishMinigames[player] = {
        fish = fish,
        time = getTickCount()
    }
end

addEventHandler('fishing:catchFish', resourceRoot, function(success)
    local player = client
    
    local fishData = catchFishMinigames[player]
    if not fishData then return end

    local fish = fishData.fish
    if fishData.time + 800 > getTickCount() and success then
        exports['m-anticheat']:ban(client, 'Lua injector', 'Lua injector (fishing too fast)')
        return
    end

    if success then
        local itemName = exports['m-inventory']:getItemName(fish)
        
        exports['m-inventory']:addPlayerItem(player, fish, 1)
        exports['m-notis']:addNotification(player, 'info', 'Łowienie', 'Złowiono ' .. itemName .. ' x1.')

        local fishingRod = getElementData(player, 'player:equippedFishingRod')
        if not fishingRod then return end

        if math.random(1, 2) == 2 then
            exports['m-inventory']:addItemProgress(player, fishingRod, 100)
        end
    else
        exports['m-notis']:addNotification(player, 'error', 'Łowienie', 'Nie udało się złowić ryby.')
    end

    catchFishMinigames[player] = nil

    setElementData(player, 'player:fishing', false, false)
    setElementFrozen(player, false)
    setPedAnimation(player)
end)

addEventHandler('fishing:start', resourceRoot, function()
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end

    if getElementData(client, 'player:fishing') then return end
    setElementData(client, 'player:fishing', true, false)

    local itemHash = getElementData(client, 'player:equippedFishingRod')
    if not itemHash then
        exports['m-notis']:addNotification(client, 'error', 'Łowienie', 'Musisz mieć założoną wędkę, aby łowić ryby.')
        return
    end

    local rarity = exports['m-inventory']:getPlayerItemRarityByHash(client, itemHash)
    if not rarity then
        exports['m-notis']:addNotification(client, 'error', 'Łowienie', 'Musisz mieć założoną wędkę, aby łowić ryby.')
        return
    end

    local bait = exports['m-inventory']:getPlayerItemAmount(client, 'bait')
    if bait < 1 then
        exports['m-notis']:addNotification(client, 'error', 'Łowienie', 'Musisz mieć przynętę, aby łowić ryby.')
        return
    end

    exports['m-inventory']:removePlayerItem(client, 'bait', 1)
    fishingRodHit(client)
    -- setTimer(getFish, math.random(3000, 24000), 1, client, rarity)
    setTimer(getFish, 1000, 1, client, rarity)
end)

addEventHandler('onResourceStart', resourceRoot, function()
    for i, player in ipairs(getElementsByType('player')) do
        setElementData(player, 'player:fishing', false, false)
    end
end)