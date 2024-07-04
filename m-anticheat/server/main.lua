function ban(player, reason, log)
    local name = getPlayerName(player)
    local serial = getPlayerSerial(player)
    local ip = getPlayerIP(player)

    exports['m-core']:permBan(player, 'Anticheat', log, reason)
    local message = ('Zbanowano `%s` (`%s`, `%s`): %s'):format(name, serial, ip, log or reason)
    exports['m-logs']:sendLog('anticheat', 'error', message)
end

addCommandHandler('fingerprint', function(player)
    local fingerprint = getPlayerFingerprint(player)
    if not fingerprint then return end

    outputConsole('* Your fingerprint is: ' .. fingerprint, player)
end)

function getPlayerFingerprint(player)
    local fingerprint = getElementData(player, 'player:fingerprint') or ''
    return teaEncode(fingerprint, 'm-anticheat')
end

function getPlayerDecodedFingerprint(player)
    return getElementData(player, 'player:fingerprint')
end