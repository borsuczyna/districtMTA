function onSprayUse(player, itemHash)
    local item = getPlayerItem(player, itemHash)
    local itemData = getItemData(item)

    giveWeapon(player, 41, 5000, true)
    setElementData(player, 'player:paint', item.metadata)

    local color = ('<span style="background: %s; min-width: 2rem; display: inline-block; height: 1rem; border-radius: 0.2rem;"></span><br>'):format(item.metadata.color)
    exports['m-notis']:addNotification(player, 'info', 'Spray', 'Wyjęto spray z ekwipunku o kolorze ' .. color)

    return -1
end