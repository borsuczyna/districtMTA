function reloadWeapon(player)
    local weapon = getPedWeapon(player)

    if weapon and weapon > 0 then
        reloadPedWeapon(player)
    end
end

addEvent('onPlayerRequestReload', true)
addEventHandler('onPlayerRequestReload', resourceRoot, function()
    reloadWeapon(client)
end)

addEventHandler('onPlayerDamage', root, function(attacker, weapon)
    if weapon == 41 then
        cancelEvent()
    end
end)