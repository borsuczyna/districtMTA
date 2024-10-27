function onLiquidRegretUse(player)
    triggerClientEvent(player, 'item:applyDrunkEffect', resourceRoot)
    setPedAnimation(player, "VENDING", "VEND_Drink2_P", nil, false, false, nil, false)
    return -1
end