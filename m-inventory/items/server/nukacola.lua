function onNukaColaUse(player)
    local health = getElementHealth(player)
    setElementHealth(player, health + 5)
    setPedAnimation(player, "VENDING", "VEND_Drink2_P", nil, false, false, nil, false)
    return -1
end