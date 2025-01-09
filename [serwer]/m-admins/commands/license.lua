addCommandHandler('zpj', function(player, cmd, playerToFind, time, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:license') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if not playerToFind or not time then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format, użycie: /zpj (gracz) (czas np. 1d) (powód)')
        return
    end

    local reason = table.concat({...}, ' ') or 'nie podano powodu'
    reason = reason ~= '' and reason or 'nie podano powodu'
    
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
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
    local discordReason = ('Admin `%s` zabrał prawo jazdy `%s` na %d %s: `%s`'):format(getPlayerName(player), getPlayerName(foundPlayer), timeValue, timeUnitName, reason)
    local serverReason = ('Admin %s zabrał prawo jazdy %s na %d %s: %s'):format(getPlayerName(player), getPlayerName(foundPlayer), timeValue, timeUnitName, reason)
    local notiMessage = ('Zabrano prawo jazdy %s na %d %s'):format(getPlayerName(foundPlayer), timeValue, timeUnitName)
    
    exports['m-core']:takeLicense(foundPlayer, player, timeValue, unit, discordReason, reason)
    exports['m-logs']:sendLog('admin', 'error', discordReason)
    exports['m-notis']:addNotification(player, 'success', 'Prawo jazdy', notiMessage)

    triggerClientEvent('createAdminNotification', root, 'license', serverReason)
end)

addCommandHandler('opj', function(player, cmd, playerToFind, ...)
    if not getElementData(player, 'player:uid') then return end
    if not doesPlayerHavePermission(player, 'command:license') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz uprawnień')
        return
    end

    if not playerToFind then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format, użycie: /opj (gracz)')
        return
    end

    local reason = table.concat({...}, ' ') or 'nie podano powodu'
    reason = reason ~= '' and reason or 'nie podano powodu'
    
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local discordReason = ('Admin `%s` oddał prawo jazdy `%s`: `%s`'):format(getPlayerName(player), getPlayerName(foundPlayer), reason)
    local serverReason = ('Admin %s oddał prawo jazdy %s: %s'):format(getPlayerName(player), getPlayerName(foundPlayer), reason)
    local notiMessage = ('Oddano prawo jazdy %s'):format(getPlayerName(foundPlayer))

    exports['m-core']:returnLicense(foundPlayer, player)
    exports['m-logs']:sendLog('admin', 'success', discordReason)
    exports['m-notis']:addNotification(player, 'success', 'Prawo jazdy', notiMessage)

    triggerClientEvent('createAdminNotification', root, 'license', serverReason)
end)