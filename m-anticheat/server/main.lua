function ban(player, reason, log)
    local name = getPlayerName(player)
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)

    banPlayer(player, true, false, true, 'Anticheat', reason)

    local message = ('Zbanowano `%s` (`%s`, `%s`): %s'):format(name, serial, ip, log or reason)
    exports['m-logs']:sendLog('anticheat', 'error', message)
end