addCommandHandler('b', function(player, cmd, playerToFind, time, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:ban') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if not playerToFind or not time then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format, użycie: /b (gracz) (czas np. 1d) (powód)')
        return
    end

    local reason = table.concat({...}, ' ') or 'nie podano powodu'
    reason = reason ~= '' and reason or 'nie podano powodu'
    
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local playerRank = getElementData(player, 'player:rank')
    local foundPlayerRank = getElementData(foundPlayer, 'player:rank')
    if foundPlayerRank and playerRank and foundPlayerRank >= playerRank then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie możesz zbanować gracza o wyższej lub tej samej randze')
        return
    end

    local timePattern = '(%d+)([dhms])'
    local timeValue, unit = time:match(timePattern)
    if not unit then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nieprawidłowy format czasu (przykład: 1d, 1h, 1m, 1s)')
        return
    end

    timeValue = tonumber(timeValue)
    if not timeValue then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nieprawidłowy format czasu (przykład: 1d, 1h, 1m, 1s)')
        return
    end

    local timeUnits = {
        d = 'dni',
        h = 'godzin',
        m = 'minut',
        s = 'sekund',
    }

    local timeUnitName = timeUnits[unit]
    local discordReason = ('Admin `%s` zbanował gracza `%s` na %d %s: `%s`'):format(getPlayerName(player), getPlayerName(foundPlayer), timeValue, timeUnitName, reason)
    local serverReason = ('Admin %s zbanował gracza %s na %d %s: %s'):format(getPlayerName(player), getPlayerName(foundPlayer), timeValue, timeUnitName, reason)
    local notiMessage = ('Zbanowano gracza %s na %d %s'):format(getPlayerName(foundPlayer), timeValue, timeUnitName)

    exports['m-core']:tempBan(foundPlayer, player, timeValue, unit, discordReason, reason)
    exports['m-logs']:sendLog('admin', 'error', discordReason)
    exports['m-notis']:addNotification(player, 'success', 'Ban', notiMessage)

    triggerClientEvent('createAdminNotification', resourceRoot, 'ban', serverReason)
end)

addCommandHandler('pb', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:ban') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    local reason = table.concat({...}, ' ') or 'nie podano powodu'
    reason = reason ~= '' and reason or 'nie podano powodu'
    
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local playerRank = getElementData(player, 'player:rank')
    local foundPlayerRank = getElementData(foundPlayer, 'player:rank')
    if foundPlayerRank and playerRank and foundPlayerRank >= playerRank then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie możesz zbanować gracza o wyższej lub tej samej randze')
        return
    end

    local discordReason = ('Admin `%s` zbanował gracza `%s` na zawsze: `%s`'):format(getPlayerName(player), getPlayerName(foundPlayer), reason)
    local serverReason = ('Admin %s zbanował gracza %s na zawsze: %s'):format(getPlayerName(player), getPlayerName(foundPlayer), reason)
    local notiMessage = ('Zbanowano gracza %s na zawsze'):format(getPlayerName(foundPlayer))

    exports['m-core']:permBan(foundPlayer, player, discordReason, reason)
    exports['m-logs']:sendLog('admin', 'error', discordReason)
    exports['m-notis']:addNotification(player, 'success', 'Ban', notiMessage)

    triggerClientEvent('createAdminNotification', resourceRoot, 'ban', serverReason)
end)

addCommandHandler('ub', function(player, cmd, serial)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:ban') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if not serial then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format, użycie: /ub (serial)')
        return
    end

    local discordReason = ('Admin `%s` odbanował gracza o serialu `%s`'):format(getPlayerName(player), serial)
    local notiMessage = ('Odbanowano gracza o serialu %s'):format(serial)

    exports['m-core']:unbanPlayer(player, serial)
    exports['m-logs']:sendLog('admin', 'success', discordReason)
    exports['m-notis']:addNotification(player, 'success', 'Unban', notiMessage)
end)