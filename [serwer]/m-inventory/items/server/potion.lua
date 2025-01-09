function onPotionUse(player)
    setPedAnimation(player, "FOOD", "EAT_Burger", nil, false, false, nil, false)
    triggerClientEvent(player, 'inventory:onUsePotion', resourceRoot)
    return -1
end