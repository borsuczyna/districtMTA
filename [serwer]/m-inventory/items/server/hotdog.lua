function onHotDogUse(player)
    local health = getElementHealth(player)
    setElementHealth(player, health + 20)
    setPedAnimation(player, "FOOD", "EAT_Burger", nil, false, false, nil, false)
    return -1
end