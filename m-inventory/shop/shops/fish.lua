local fishPrices = {
    {'smallFry', 4},
    {'orangeFlopper', 4},
    {'slurpJellyfish', 4},
    {'moltenSpicyFish', 4},
    {'driftSpicyFish', 5},
    {'greenFlopper', 5},
    {'lbShieldFish', 5},
    {'blueSlurpfish', 6},
    {'southernSpicyFish', 6},
    {'sbSpicyFish', 6},
    {'peelyJellyfish', 6},
    {'blueFlopper', 7},
    {'bbShieldFish', 7},
    {'yellowSlurpfish', 7},
    {'blackSlurpfish', 8},
    {'blackSmallFry', 9},
    {'purpleJellyfish', 9},
    {'wsSpicyFish', 9},
    {'bsShieldFish', 10},
    {'darkVanguardJellyfish', 10},
    {'cuddleJellyfish', 12},
    {'chumHopFlopper', 11},
    {'atlanticHopFlopper', 11},
    {'chinhookHopFlopper', 12},
    {'cohoHopFlopper', 13},
    {'divineHopFlopper', 18},
}

function createFishShop(x, y, z)
    local items = {
        {category = 'Wędki', item = 'fishingRodCommon', price = 100, type = 'buy'},

        {category = 'Wynajem kutra', item = 'reefer10', price = 500, type = 'buy', single = true, onBuy = function(player, count)
            triggerEvent('fishing:onReeferBuy', root, player, count * 10)
        end},
        {category = 'Wynajem kutra', item = 'reefer30', price = 1000, type = 'buy', single = true, onBuy = function(player, count)
            triggerEvent('fishing:onReeferBuy', root, player, count * 30)
        end},
        {category = 'Wynajem kutra', item = 'reefer60', price = 1200, type = 'buy', single = true, onBuy = function(player, count)
            triggerEvent('fishing:onReeferBuy', root, player, count * 60)
        end},
        
        {category = 'Przynęta', item = 'bait', price = 1, type = 'buy'},
        
        {category = 'Sprzedaż ryb', item = 'allFish', price = 'Zależy od towaru', priceCallback = function(item)
            for _, fish in pairs(fishPrices) do
                if fish[1] == item then
                    return fish[2]
                end
            end
        end, type = 'sell'},
    }

    for _, fish in pairs(fishPrices) do
        table.insert(items, {category = 'Sprzedaż ryb', item = fish[1], price = fish[2], type = 'sell'})
    end

    return {
        position = {x, y, z},
        name = 'Sklep rybacki',
        description = 'Santa Maria Beach',
        items = items
    }
end