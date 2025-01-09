function handleClearAvatar(data)
    local player = exports['m-core']:getPlayerByUid(tonumber(data.uid))
    if not player then return end

    exports['m-notis']:addNotification(player, 'info', 'Avatar', 'Twój avatar został odświeżony, połącz się ponownie aby zaaplikować zmiany')
end