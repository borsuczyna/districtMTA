if sockOpen == nil then
    exports['m-logs']:sendLog('general', 'error', 'Nie znaleziono modułu socketów')
    outputDebugString('Nie znaleziono modułu socketów')
    return
end

addEvent('socket:onAuthenticated', true)

local socketApiKey = 'MhM4PTCp2Ww8ez9hGXZhp4EV18vdQ97NxmwoTMvLSmrux5dOjnfK8aODTdpn5ejO'
local discordBot = sockOpen('127.0.0.1', 32800)

function log(message)
    outputServerLog('[SOCKET] ' .. message)
end

function handleMessage(message)
    if message.type == 'auth' then
        handleAuthMessage(message.message)
    elseif message.type == 'clearAvatar' then
        handleClearAvatar(message.message)
    elseif message.type == 'connectAccount' then
        handleConnectAccount(message.message)
    elseif message.type == 'getAllPlayers' then
        getAllPlayers()
    elseif message.type == 'paymentCreated' then
        handlePaymentCreatedMessage(message.message)
    elseif message.type == 'paymentFinished' then
        handlePaymentFinishedMessage(message.message)
    end
end

function sendSocketMessage(type, message)
    sockWrite(discordBot, toJSON({type = type, message = message}))
end

addEventHandler('onSockOpened', root, function(socket)
    if socket ~= discordBot then return end

    sendSocketMessage('auth', {apiKey = socketApiKey})
end)

addEventHandler('onSockData', root, function(socket, data)
    if socket == discordBot then
        local message = fromJSON(data)
        handleMessage(message)
    end
end)

addEventHandler('onSockClosed', root, function (socket)
    if socket == discordBot then
        log('Connection closed')
    end
end)

function disconnect()
   sockClose(discordBot)
end