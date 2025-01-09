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

local function getRandomFish(rarity, classMore)
    local possibleFishes = {'wire'}

    local insertFishes = function(fishes)
        for i, fish in ipairs(fishes) do
            table.insert(possibleFishes, fish)
        end
    end

    local breakOnNext = false
    for i, fishData in ipairs(rarityFishes) do
        insertFishes(fishData.items)
        if breakOnNext then break end
        if fishData.rarity == rarity then
            if classMore then
                breakOnNext = true
            else
                break
            end
        end
    end

    return possibleFishes[math.random(1, #possibleFishes)]
end

function fishingRodHit(player)
    setElementFrozen(player, true)
    setPedAnimation(player, 'SWORD', 'sword_' .. math.random(1, 4), -1, false, true, false, true, 250)
    setTimer(setPedAnimation, 600, 1, player, 'SWORD', 'sword_IDLE')
end

local function getFish(player, rarity)
    local fish = getRandomFish(rarity, isPlayerInFishingArea(player))
    if not fish then return end

    local icon = exports['m-inventory']:getItemIcon(fish)
    triggerClientEvent(player, 'fishing:catchFish', resourceRoot, icon)
    catchFishMinigames[player] = {
        fish = fish,
        time = getTickCount()
    }
end

addEventHandler('fishing:catchFish', resourceRoot, function(success)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `fishing:catchFish` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    local player = client
    
    local fishData = catchFishMinigames[player]
    if not fishData then return end

    local fish = fishData.fish
    if fishData.time + 800 > getTickCount() and success then
        exports['m-anticheat']:ban(client, 'Lua injector', 'Lua injector (**fishing too fast**)')
        return
    end

    if success then
        local itemName = exports['m-inventory']:getItemName(fish)
        
        exports['m-inventory']:addPlayerItem(player, fish, 1)
        exports['m-notis']:addNotification(player, 'info', 'Łowienie', 'Złowiono ' .. itemName .. ' x1.')
        setElementData(player, 'player:catchedFishes', (getElementData(player, 'player:catchedFishes') or 0) + 1)
        setElementData(player, 'player:catchedFishesSession', (getElementData(player, 'player:catchedFishesSession') or 0) + 1)

        local fishingRod = getElementData(player, 'player:equippedFishingRod')
        if not fishingRod then return end

        if math.random(1, 2) == 2 then
            exports['m-inventory']:addItemProgress(player, fishingRod, 1)
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
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `fishing:start` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end
    
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
    local time = math.random(3000, 24000) * (isPlayerInFishingArea(client) and 0.7 or 1)
    setTimer(getFish, time, 1, client, rarity)
end)

addEventHandler('onResourceStart', resourceRoot, function()
    for i, player in ipairs(getElementsByType('player')) do
        setElementData(player, 'player:fishing', false, false)
    end
end)