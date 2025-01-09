local _givePlayerMoney = givePlayerMoney

function givePlayerMoney(player, type, details, amount)
    if not amount or amount == 0 then return end
    
    amount = math.ceil(amount)
    addMoneyLog(player, type, details, amount)

    if amount > 0 then
        _givePlayerMoney(player, amount)
    else
        takePlayerMoney(player, -amount)
    end

    updatePlayerMoney(player)
end

function transferMoney(player, cmd, playerToFind, money)
    if not getElementData(player, 'player:uid') then return end
    if not playerToFind or not money then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format, użycie: /przelej (gracz) (ilość)')
        return
    end

    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    if player == foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie możesz przelać pieniędzy samemu sobie')
        return
    end

    local moneyValue = tonumber(money)
    if not moneyValue or not string.match(money, "^%d+%.?%d?%d?$") or moneyValue == 0 then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Niepoprawny format kwoty, użyj np. 2, 2.5, 2.50')
        return
    end

    local moneyInCents = math.floor(moneyValue * 100)
    if getPlayerMoney(player) < moneyInCents then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie masz wystarczającej ilości pieniędzy')
        return
    end

    givePlayerMoney(player, 'transfer', 'Przelew do '..getPlayerName(foundPlayer), -moneyInCents)
    givePlayerMoney(foundPlayer, 'transfer', 'Przelew od '..getPlayerName(player), moneyInCents)

    local colorA = getPlayerColor(player)
    local playerNameA = getPlayerName(player)
    local playerIDA = getElementData(player, 'player:id')
    local playerUIDA = getElementData(player, 'player:uid')
    local colorB = getPlayerColor(foundPlayer)
    local playerNameB = getPlayerName(foundPlayer)
    local playerIDB = getElementData(foundPlayer, 'player:id')
    local playerUIDB = getElementData(foundPlayer, 'player:uid')

    local message = ('%s(#ffffff%d%s) #dddddd%s > %s(#ffffff%d%s) #dddddd%s - %s'):format(colorA, playerIDA, colorA, playerNameA, colorB, playerIDB, colorB, playerNameB, addCents(moneyInCents))
    local discordMessage = ('%s(%d) > %s(%d) - %s'):format(playerNameA, playerUIDA, playerNameB, playerUIDB, addCents(moneyInCents))
    exports['m-admins']:addLog('przelewy', message, {})
    
    exports['m-logs']:sendLog('transfers', 'info', discordMessage)
    
    exports['m-notis']:addNotification(player, 'success', 'Przelew', 'Przelałeś '..moneyValue..'$ do '..getPlayerName(foundPlayer))
    exports['m-notis']:addNotification(foundPlayer, 'info', 'Przelew', 'Otrzymałeś '..moneyValue..'$ od '..getPlayerName(player))
end

addCommandHandler('przelej', transferMoney)
addCommandHandler('przelew', transferMoney)
addCommandHandler('dajkase', transferMoney)