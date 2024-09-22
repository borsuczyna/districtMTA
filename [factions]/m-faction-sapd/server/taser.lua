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

addEventHandler('onPlayerDamage', root, function(attacker, weapon, bodypart, loss)
    if weapon == 23 then
        paralyzePlayer(source)
    end
end)