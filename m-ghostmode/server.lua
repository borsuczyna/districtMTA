function setGhostMode(player)
    triggerClientEvent('ghostmode:set', root, player)
    print('kupa')
end

addCommandHandler('ghostmodeXDDDD', function(plr,cmd,...)
    setGhostMode(plr)
end)