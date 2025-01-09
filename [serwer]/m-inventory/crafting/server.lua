addEvent('inventory:craftItem')

addEventHandler('inventory:craftItem', root, function(hash, player, recipeId)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local recipe = craftingRecipes[recipeId]
    if not recipe then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie znaleziono tego craftingu'})
        return
    end

    local checkTable = {}
    for i, ingredient in ipairs(recipe.ingredients) do
        checkTable[ingredient.item] = ingredient.amount
    end

    -- check if player has all items
    local have, missingItem = doesPlayerHaveItems(player, checkTable)
    if not have then
        local itemName = getItemName(missingItem)
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie posiadasz wszystkich składników ('..itemName..')'})
        return
    end

    -- check if player has all items unequipped
    local have, equippedItem = doesPlayerHaveItemsUnequipped(player, checkTable)
    if not have then
        local itemName = getItemName(equippedItem)
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Musisz zdjąć '..itemName})
        return
    end

    -- call callback
    local success, message = recipe.craft(player, recipe)
    if not success then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = message})
        return
    end

    -- remove items
    for i, ingredient in ipairs(recipe.ingredients) do
        if ingredient.remove then
            removePlayerItem(player, ingredient.item, ingredient.amount)
        end
    end

    -- add result
    if recipe.result and recipe.resultAmount then
        addPlayerItem(player, recipe.result, recipe.resultAmount)
    end

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Wytworzono '..recipe.name, inventory = getPlayerInventory(player)})
end)