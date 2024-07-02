local antySpam = {}

function sendLocalMessage(x, y, z, message, distance, r, g, b)
    for _, player in ipairs(getElementsWithinRange(x, y, z, distance, 'player')) do
        outputChatBox(message, player, r or 255, g or 255, b or 255, true)
    end
end

function getPlayerColor(player)
    local color = '#cccccc'
    local premium = getElementData(player, 'player:premium')

    if premium then
        color = '#ffcc00'
    end

    return color
end

addEventHandler('onPlayerChat', root, function(message, messageType)
    cancelEvent()

    if antySpam[source] and getTickCount() - antySpam[source] < 500 then
        exports['m-notis']:addNotification(source, 'error', 'Anty spam', 'Nie możesz wysyłać wiadomości tak szybko!')
        return
    end

    local timeLeft = isPlayerMuted(source)
    if timeLeft then
        exports['m-notis']:addNotification(source, 'error', 'Wyciszenie', ('Jesteś wyciszony na %s z powodu: %s'):format(timeLeft, 'elo'))
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
    local x, y, z = getElementPosition(player)
    local message = table.concat({...}, ' ')
    local playerName = getPlayerName(player)
    local playerID = getElementData(player, 'player:id')
    local premium = getElementData(player, 'player:premium')
    local color = getPlayerColor(player)

    local message = ('* %s (%s)'):format(message, playerName)
    sendLocalMessage(x, y, z, message, 20, 0, 112, 224)
end)