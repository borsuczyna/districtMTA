function checkSpeedHack(gameSpeed)
    local serverGameSpeed = ('%.2f'):format(getGameSpeed())
    local clientGameSpeed = ('%.2f'):format(gameSpeed)

    if serverGameSpeed ~= clientGameSpeed then
        ban(client, 'Speed hack', 'Speed hack')
    end
end

addEvent('checkSpeedHack', true)
addEventHandler('checkSpeedHack', resourceRoot, checkSpeedHack)