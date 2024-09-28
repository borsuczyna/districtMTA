function onTraceUse(player, itemHash, autoUse)
    local item = getPlayerItem(player, itemHash)
    local itemData = getItemData(item)

    local equipped = item.metadata and item.metadata.equipped or false
    local equippedOtherTrace = doesPlayerHaveAnyItemByRegexEquipped(player, 'trace%w+')
    if not equipped and equippedOtherTrace then
        exports['m-notis']:addNotification(player, 'error', 'Ślady', 'Posiadasz już założone ślady.')
        return 0
    end

    setItemMetadata(player, itemHash, 'equipped', not equipped)

    if not autoUse then
        exports['m-notis']:addNotification(player, 'info', 'Ślady', 'Ślady zostały ' .. (equipped and 'zdjęte.' or 'założone.'))
    end
    
    local traceId = item.item:gsub('trace', '')
    if not equipped then
        setElementData(player, 'player:scooter-trace', tonumber(traceId))
    else
        removeElementData(player, 'player:scooter-trace')
    end

    return 0
end