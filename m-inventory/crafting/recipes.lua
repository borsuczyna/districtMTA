craftingRecipes = {
    {
        name = 'Niezwykła wędka',
        description = 'Ulepszona wersja zwykłej wędki.',
        category = 'fish',
        ingredients = {
            {item = 'fishingRod', amount = 1, remove = false},
            {item = 'wire', amount = 1, remove = true},
        },
        result = 'fishingRodUncommon',
        resultAmount = 1,

        craft = function(player, recipe)
            local validFishingRood = matchItems(player, function(item)
                if item.item ~= 'fishingRod' then return false end
                return (item.metadata and item.metadata.progress or 0) >= 100
            end)

            if #validFishingRood == 0 then
                return false, 'Nie posiadasz wędki z pełnym postępem.'
            end

            removePlayerItemByHash(player, validFishingRood[1].hash, 1)

            return true
        end
    },
}