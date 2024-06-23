function isSerialWhitelisted(serial)
    local result = exports['m-mysql']:query('SELECT * FROM `m-whitelist` WHERE `serial` = ?', serial)
    return #result > 0
end

function checkWhitelist(playerNick, playerIP, playerUsername, playerSerial)
    if not isSerialWhitelisted(playerSerial) then
        cancelEvent(true, 'You are not whitelisted')
    end
end

addEventHandler('onPlayerConnect', root, checkWhitelist)