local function firstLetterUpper(str)
    return str:gsub("^%l", string.upper)
end

function createFishingRodRecipe(previous, next, neededSteel, name, description)
    local previousRod = firstLetterUpper(previous)
    local nextRod = firstLetterUpper(next)
    local neededItem = 'fishingRod' .. previousRod

    return {
        name = name,
        category = 'fish',
        ingredients = {
            {item = neededItem, amount = 1, remove = false},
            {item = 'wire', amount = neededSteel, remove = true},
        },
        result = 'fishingRod' .. nextRod,
        resultAmount = 1,

        craft = function(player, recipe)
            local validFishingRood = matchItems(player, function(item)
                if item.item ~= neededItem then return false end
                return (item.metadata and item.metadata.progress or 0) >= 100
            end)

            if #validFishingRood == 0 then
                return false, 'Nie posiadasz wędki z pełnym postępem.'
            end

            removePlayerItemByHash(player, validFishingRood[1].hash, 1)

            return true
        end
    }
end