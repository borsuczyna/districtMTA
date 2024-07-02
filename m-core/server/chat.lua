local antySpam = {}
local rankColors = {}

local function rgbToHex(r, g, b)
    return ('#%02x%02x%02x'):format(r, g, b)
end

function sendLocalMessage(x, y, z, message, distance, r, g, b)
    for _, player in ipairs(getElementsWithinRange(x, y, z, distance, 'player')) do
        outputChatBox(message, player, r or 255, g or 255, b or 255, true)
    end
end

function getPlayerColor(player)
    local premium = getElementData(player, 'player:premium')
    local rank = getElementData(player, 'player:rank')

    if rank and rank > 0 then
        if rankColors[rank] then
            return rankColors[rank]
        end

        color = rgbToHex(exports['m-admins']:getRankColor(rank))
        rankColors[rank] = color

        return color
    elseif premium then
        return '#ffcc00'
    end

    return '#cccccc'
end

addEventHandler('onPlayerChat', root, function(message, messageType)
    cancelEvent()

    if not getElementData(source, 'player:uid') or not getElementData(source, 'player:spawn') then return end
    if antySpam[source] and getTickCount() - antySpam[source] < 500 then
        exports['m-notis']:addNotification(source, 'error', 'Anty spam', 'Nie możesz wysyłać wiadomości tak szybko!')
        return
    end

    local timeLeft, admin = isPlayerMuted(source)
    if timeLeft then
        exports['m-notis']:addNotification(source, 'error', 'Wyciszenie', ('Jesteś wyciszony przez %s na %s z powodu: %s'):format(admin, timeLeft, 'elo'))
        return
    end

    local x, y, z = getElementPosition(source)
    local playerName = getPlayerName(source)
    local playerID = getElementData(source, 'player:id')
    local premium = getElementData(source, 'player:premium')
    local color = getPlayerColor(source)
    
    if messageType == 0 then -- local
        local message = ('%s(#ffffff%d%s) #ffffff%s: %s'):format(color, playerID, color, playerName, message)
        sendLocalMessage(x, y, z, message, 20, 255, 215, 125)
    elseif messageType == 1 then -- me
        local message = ('* (%d) %s %s'):format(playerID, playerName, message)
        sendLocalMessage(x, y, z, message, 20, 233, 66, 245)
    end

    antySpam[source] = getTickCount()
end)

addCommandHandler('do', function(player, command, ...)
    if not getElementData(player, 'player:uid') or not getElementData(player, 'player:spawn') then return end
    
    local timeLeft, admin = isPlayerMuted(player)
    if timeLeft then
        exports['m-notis']:addNotification(player, 'error', 'Wyciszenie', ('Jesteś wyciszony przez %s na %s z powodu: %s'):format(admin, timeLeft, 'elo'))
        return
    end

    local x, y, z = getElementPosition(player)
    local message = table.concat({...}, ' ')
    local playerName = getPlayerName(player)
    local playerID = getElementData(player, 'player:id')
    local premium = getElementData(player, 'player:premium')
    local color = getPlayerColor(player)

    local message = ('* %s (%s)'):format(message, playerName)
    sendLocalMessage(x, y, z, message, 20, 0, 112, 224)
end)

local respondTo = {}

function sendPm(fromPlayer, toPlayer, message)
    local timeLeft, admin = isPlayerMuted(fromPlayer)
    if timeLeft then
        exports['m-notis']:addNotification(fromPlayer, 'error', 'Wyciszenie', ('Jesteś wyciszony przez %s na %s z powodu: %s'):format(admin, timeLeft, 'elo'))
        return
    end

    if fromPlayer == toPlayer then
        exports['m-notis']:addNotification(fromPlayer, 'error', 'Błąd', 'Nie możesz wysłać wiadomości do siebie')
        return
    end

    local fromPlayerName = getPlayerName(fromPlayer)
    local fromPlayerID = getElementData(fromPlayer, 'player:id')
    local toPlayerName = getPlayerName(toPlayer)
    local toPlayerID = getElementData(toPlayer, 'player:id')
    local premium = getElementData(fromPlayer, 'player:premium')
    local color = getPlayerColor(fromPlayer)

    outputChatBox(('%s» [#ffffff%d%s] #ffffff%s: %s'):format(color, toPlayerID, color, toPlayerName, message), fromPlayer, 255, 255, 255, true)
    outputChatBox(('%s« [#ffffff%d%s] #ffffff%s: %s'):format(color, fromPlayerID, color, fromPlayerName, message), toPlayer, 255, 255, 255, true)

    respondTo[toPlayer] = fromPlayer
end

addCommandHandler('pm', function(player, command, playerToFind, ...)
    if not getElementData(player, 'player:uid') or not getElementData(player, 'player:spawn') then return end
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    local message = table.concat({...}, ' ')
    sendPm(player, foundPlayer, message)
end)

addCommandHandler('re', function(player, command, ...)
    if not getElementData(player, 'player:uid') or not getElementData(player, 'player:spawn') then return end
    local message = table.concat({...}, ' ')
    local toPlayer = respondTo[player]
    if not toPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie masz nikogo do odpowiedzi')
        return
    end

    sendPm(player, toPlayer, message)
end)