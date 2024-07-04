addEventHandler('onExplosion', root, function() 
    if source and getElementType(source) == 'player' then
        local message = ('%s tried to create explosion'):format(getPlayerName(source))
        exports['m-logs']:sendLog('anticheat', 'warning', message)
    end
    
    cancelEvent()
end)

addEventHandler('onPlayerProjectileCreation', root, function()
    if source and getElementType(source) == 'player' then
        local message = ('%s tried to create projectile'):format(getPlayerName(source))
        exports['m-logs']:sendLog('anticheat', 'warning', message)
    end

    cancelEvent()
end)