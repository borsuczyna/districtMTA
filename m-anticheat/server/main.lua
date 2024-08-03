function ban(player, reason, log)
    local name = getPlayerName(player)
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)

    exports['m-core']:permBan(player, 'Anticheat', log, reason)
    local message = ('Banned `%s` (`%s`, `%s`): %s'):format(name, serial, ip, log or reason)
    exports['m-logs']:sendLog('anticheat', 'error', message)
end

addEventHandler('onElementDataChange', root, function(data, oldValue, newValue)
    if data == 'player:gameTime' then
        if newValue == 99 then
            ban(client, 'Integration error', 'Integration error')
        elseif newValue == 9 then
            local message = getElementData(client, 'player:gameInterval')
            ban(client, 'Custom command', ('Custom command %s'):format(teaDecode(message, 'district')))
        elseif newValue == 8 then
            ban(client, 'Fly hack', 'Fly hack')
        elseif newValue == 7 then
            ban(client, 'Speed hack', 'Speed hack')
        elseif newValue == 6 then
            ban(client, 'World special properties', 'World special properties')
        elseif newValue == 1 then
            local message = getElementData(client, 'player:gameInterval')
            ban(client, 'Lua injector', ('Lua injector %s'):format(teaDecode(message, 'district')))
        end
    end
end)