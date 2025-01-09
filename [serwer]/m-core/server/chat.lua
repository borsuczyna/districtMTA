local antySpam = {}
local rankColors = {}

local function rgbToHex(r, g, b)
    return ('#%02x%02x%02x'):format(r, g, b)
end

local function removeHex(text)
    return text:gsub('#%x%x%x%x%x%x', '')
end

function sendLocalMessage(x, y, z, dimension, message, distance, r, g, b)
    for _, player in ipairs(getElementsWithinRange(x, y, z, distance, 'player')) do
        local dim = getElementDimension(player)
        if dim == dimension then
            outputChatBox(message, player, r or 255, g or 255, b or 255, true)
        end
    end

    outputServerLog(removeHex(message))
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

    local timeLeft, admin, reason = isPlayerMuted(source)
    if timeLeft then
        exports['m-notis']:addNotification(source, 'error', 'Wyciszenie', ('Jesteś wyciszony przez %s na %s z powodu: %s'):format(admin, timeLeft, reason))
        return
    end

    local x, y, z = getElementPosition(source)
    local dimension = getElementDimension(source)
    local playerName = getPlayerName(source)
    local playerID = getElementData(source, 'player:id')
    local playerUID = getElementData(source, 'player:uid')
    local premium = getElementData(source, 'player:premium')
    local color = getPlayerColor(source)
    message = removeHex(message)
    
    if messageType == 0 then -- local
        local message = ('%s(#ffffff%d%s) #dddddd%s: #eeeeee%s'):format(color, playerID, color, playerName, message)
        sendLocalMessage(x, y, z, dimension, message, 20, 255, 215, 125)
        exports['m-admins']:addLog('chat', message, {
            {'teleport', 'teleport-uid', playerUID}
        }) 
    elseif messageType == 1 then -- me
        local message = ('* %s (%s)'):format(message, playerName)
        sendLocalMessage(x, y, z, dimension, message, 20, 233, 66, 245)
        exports['m-admins']:addLog('chat', '#ff99cc' .. message, {
            {'teleport', 'teleport-uid', playerUID}
        })
    end

    triggerClientEvent('chat:addBubble', source, message)
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
    local message = removeHex(table.concat({...}, ' '))
    local dimension = getElementDimension(player)
    local playerName = getPlayerName(player)
    local playerID = getElementData(player, 'player:id')
    local playerUID = getElementData(player, 'player:uid')
    local premium = getElementData(player, 'player:premium')
    local color = getPlayerColor(player)

    local message = ('** %s (%s)'):format(message, playerName)
    sendLocalMessage(x, y, z, dimension, message, 20, 0, 112, 224)
    exports['m-admins']:addLog('chat', '#70aaff' .. message, {
        {'teleport', 'teleport-uid', playerUID}
    })
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
    local fromColor = getPlayerColor(fromPlayer)
    local toColor = getPlayerColor(toPlayer)
    message = removeHex(message)

    outputChatBox(('%s» [#ffffff%d%s] #ffffff%s: %s'):format(toColor, toPlayerID, toColor, toPlayerName, message), fromPlayer, 255, 255, 255, true)
    outputChatBox(('%s« [#ffffff%d%s] #ffffff%s: %s'):format(fromColor, fromPlayerID, fromColor, fromPlayerName, message), toPlayer, 255, 255, 255, true)
    
    outputServerLog(('(%d) %s -> (%d) %s: %s'):format(fromPlayerID, fromPlayerName, toPlayerID, toPlayerName, message))
    exports['m-admins']:addLog('pm', ('%s(#ffffff%d%s) #ffffff%s -> %s(#ffffff%d%s) #ffffff%s: %s'):format(getPlayerColor(fromPlayer), fromPlayerID, getPlayerColor(fromPlayer), fromPlayerName, getPlayerColor(toPlayer), toPlayerID, getPlayerColor(toPlayer), toPlayerName, message))

    triggerClientEvent(toPlayer, 'onClientPlayPrivateMessageSound', resourceRoot)
    respondTo[toPlayer] = fromPlayer
end

addCommandHandler('pm', function(player, command, playerToFind, ...)
    if not getElementData(player, 'player:uid') or not getElementData(player, 'player:spawn') then return end
    
    local foundPlayer = exports['m-core']:getPlayerFromPartialName(playerToFind)
    if not foundPlayer then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Nie znaleziono gracza')
        return
    end

    if not getElementData(foundPlayer, 'player:uid') or not getElementData(foundPlayer, 'player:spawn') then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', 'Gracz nie jest zalogowany')
        return
    end

    local blockedDMs = getElementData(foundPlayer, 'player:blockedDMs')
    local blockedDMsReason = getElementData(foundPlayer, 'player:blockedDMsReason')
    
    if blockedDMs then
        exports['m-notis']:addNotification(player, 'error', 'Błąd', ('Gracz posiada zablokowane wiadomości prywatne z powodu: %s'):format(blockedDMsReason or 'Nie podano'))
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