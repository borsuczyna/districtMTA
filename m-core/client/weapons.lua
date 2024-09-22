function requestReloadWeapon()
    local weapon = getPedWeapon(localPlayer)
    
    if weapon and weapon > 0 then
        triggerServerEvent('onPlayerRequestReload', resourceRoot)
    end
end

bindKey('r', 'down', requestReloadWeapon)

addEventHandler('onClientPlayerChoke', root, function()
    cancelEvent()
end)

addEventHandler('onClientPlayerDamage', localPlayer, function(attacker, weapon)
    if weapon == 41 then
        cancelEvent()
    end
end)