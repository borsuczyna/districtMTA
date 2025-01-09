local fishPrices = {
    {'smallFry', 400},
    {'orangeFlopper', 400},
    {'slurpJellyfish', 400},
    {'moltenSpicyFish', 400},
    {'driftSpicyFish', 500},
    {'greenFlopper', 500},
    {'lbShieldFish', 500},
    {'blueSlurpfish', 600},
    {'southernSpicyFish', 600},
    {'sbSpicyFish', 600},
    {'peelyJellyfish', 600},
    {'blueFlopper', 700},
    {'bbShieldFish', 700},
    {'yellowSlurpfish', 700},
    {'blackSlurpfish', 800},
    {'blackSmallFry', 900},
    {'purpleJellyfish', 900},
    {'wsSpicyFish', 900},
    {'bsShieldFish', 1000},
    {'darkVanguardJellyfish', 1000},
    {'cuddleJellyfish', 1200},
    {'chumHopFlopper', 1100},
    {'atlanticHopFlopper', 1100},
    {'chinhookHopFlopper', 1200},
    {'cohoHopFlopper', 1300},
    {'divineHopFlopper', 1800},
}

function createFishShop(x, y, z)
    local items = {
        {category = 'Wędki', item = 'fishingRodCommon', price = 10000, type = 'buy'},

        {category = 'Wynajem kutra', item = 'reefer10', price = 50000, type = 'buy', single = true, onBuy = function(player, count)
            triggerEvent('fishing:onReeferBuy', root, player, count * 10)
        end},
        {category = 'Wynajem kutra', item = 'reefer30', price = 100000, type = 'buy', single = true, onBuy = function(player, count)
            triggerEvent('fishing:onReeferBuy', root, player, count * 30)
        end},
        {category = 'Wynajem kutra', item = 'reefer60', price = 120000, type = 'buy', single = true, onBuy = function(player, count)
            triggerEvent('fishing:onReeferBuy', root, player, count * 60)
        end},
        
        {category = 'Przynęta', item = 'bait', price = 200, type = 'buy'},
        
        {category = 'Sprzedaż ryb', item = 'allFish', price = 'Zależy od towaru', priceCallback = function(item)
            for _, fish in pairs(fishPrices) do
                if fish[1] == item.item then
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