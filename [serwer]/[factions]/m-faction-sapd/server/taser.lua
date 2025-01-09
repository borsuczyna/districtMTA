function paralyzePlayer(player)
    setElementFrozen(player, true)
    setPedAnimation(player, 'SWEET', 'Sweet_injuredloop')
    toggleAllControls(player, false, true, false)

    setTimer(function()
        setElementFrozen(player, false)
        setPedAnimation(player)
        toggleAllControls(player, true)
    end, 15000, 1)
end

addEventHandler('onPlayerWeaponFire', root, function(weapon, endX, endY, endZ, hitElement, startX, startY, startZ)
    if weapon == 23 or weapon == 25 then
        if isElement(hitElement) and getElementType(hitElement) == 'player' then
            paralyzePlayer(hitElement)
        end
    end
end)