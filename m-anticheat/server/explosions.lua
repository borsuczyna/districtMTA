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

addEventHandler('onPlayerDetonateSatchels', root, function()
    if source and getElementType(source) == 'player' then
        local message = ('%s tried to detonate satchels'):format(getPlayerName(source))
        exports['m-logs']:sendLog('anticheat', 'warning', message)
    end

    cancelEvent()
end)

addEventHandler('onVehicleExplode', root, function(_, player)
    if not player then return end

    local controller = getVehicleController(source)
    if player == controller then return end
    
    kick(player, 'Explosion hack', 'Explosion hack')
end)