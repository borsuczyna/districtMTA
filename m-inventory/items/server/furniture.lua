function onFurnitureUse(player, itemHash)
    local item = getPlayerItem(player, itemHash)
    local itemData = getItemData(item)
    local furniture = getFurniture(item.item)
    if not item or not furniture then return end

    exports['m-houses']:useFurniture(player, itemHash, furniture)
end