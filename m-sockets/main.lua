if sockOpen == nil then
    exports['m-logs']:sendLog('general', 'error', 'Nie znaleziono modułu socketów')
    return
end

local socketApiKey = 'MhM4PTCp2Ww8ez9hGXZhp4EV18vdQ97NxmwoTMvLSmrux5dOjnfK8aODTdpn5ejO'
local discordBot = sockOpen('127.0.0.1', 32800)

function sendSocketMessage(type, message)
    sockWrite(discordBot, toJSON({type = type, message = message}))
end

addEventHandler('onSockOpened', root, function(socket)
    if socket ~= discordBot then return end

    sendSocketMessage('auth', {apiKey = socketApiKey})
end)

addEventHandler('onSockData', root, function(socket, data)
    if socket == discordBot then
        outputServerLog('[SOCKET] ' .. data)
    end
end)

addEventHandler('onSockClosed', root, function (socket)
    if socket == discordBot then
        outputServerLog('discord bot disconnected!')
    end
end)

function disconnect()
   sockClose(discordBot)
end