local timers = {}
local blocked = {}

function premiumChatDiscord(name, message)
    if not name or not message then return end

    message = removeHex(message)

    local premiumPlayers = {}
    for i, player in ipairs(getElementsByType('player')) do
        if not getElementData(player, 'player:blockedPremiumChat') then
            if doesPlayerHavePremium(player) then
                table.insert(premiumPlayers, player)
            end
        end
    end

    local fullMessage = ('#ff9900G> #7289da(#ffffffDISCORD#7289da) #dddddd%s: #eeeeee%s'):format(name, message)
    outputChatBox(fullMessage, premiumPlayers, 255, 255, 255, true)
end

function premiumChat(player, cmd, ...)
    if not doesPlayerHavePremium(player) then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz premium')
        return
    end

    if getElementData(player, 'player:blockedPremiumChat') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Posiadasz wyłączone wiadomości premium')
        return
    end

    local message = table.concat({...}, ' ')
    if message == '' then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie podałeś wiadomości do wysłania')
        return
    end

    message = removeHex(message)

    local color = getPlayerColor(player)
    local playerID = getElementData(player, 'player:id')
    local playerUID = getElementData(player, 'player:uid')
    local playerName = getPlayerName(player)

    local premiumPlayers = {}
    for i, player in ipairs(getElementsByType('player')) do
        if not getElementData(player, 'player:blockedPremiumChat') then
            if doesPlayerHavePremium(player) then
                table.insert(premiumPlayers, player)
            end
        end
    end

    local fullMessage = ('#ff9900G>#ffffff (%s) #dddddd%s%s: #eeeeee%s'):format(playerID, color, playerName, message)
    outputChatBox(fullMessage, premiumPlayers, 255, 255, 255, true)
    exports['m-admins']:addLog('premium', fullMessage, {
        {'teleport', 'teleport-uid', playerUID}
    }) 
end
addCommandHandler('g', premiumChat)

function premiumChat(player, cmd, ...)
    if not doesPlayerHavePremium(player) then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie posiadasz premium')
        return
    end

    if getElementData(player, 'player:blockedPremiumAds') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Posiadasz wyłączone ogłoszenia premium')
        return
    end

    if blocked[player] then
        local time = getTimerDetails(timers[player])
        time = math.ceil(time / 1000)

        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Następne ogłoszenie możesz wysłać za za '..time..' sek.')
        return
    end

    local message = table.concat({...}, ' ')
    if message == '' then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie podałeś treści ogłoszenia')
        return
    end

    message = removeHex(message)

    local color = getPlayerColor(player)
    local playerID = getElementData(player, 'player:id')
    local playerUID = getElementData(player, 'player:uid')
    local playerName = getPlayerName(player)

    local premiumPlayers = {}
    for i, player in ipairs(getElementsByType('player')) do
        if not getElementData(player, 'player:blockedPremiumAds') then
            if doesPlayerHavePremium(player) then
                table.insert(premiumPlayers, player)
            end
        end
    end

    if not blocked[player] then
        blocked[player] = true

        if timers[player] then
            killTimer(timers[player])
        end

        timers[player] = setTimer(function(player)
            blocked[player] = false
        end, 60000, 1, player)
    end

    local fullMessage = ('#78aeffOG>#ffffff (%s) #dddddd%s%s: #eeeeee%s'):format(playerID, color, playerName, message)
    outputChatBox(fullMessage, premiumPlayers, 255, 255, 255, true)
    exports['m-admins']:addLog('premium', fullMessage, {
        {'teleport', 'teleport-uid', playerUID}
    }) 
end
addCommandHandler('og', premiumChat)

function doesPlayerHavePremium(player)
    local premiumEnd = getElementData(player, 'player:premium-end')
    if not premiumEnd then
        return false
    end

    if getRealTime().timestamp < tonumber(premiumEnd) then
        return true
    else
        removeElementData(player, 'player:premium-end')
        return false
    end
end