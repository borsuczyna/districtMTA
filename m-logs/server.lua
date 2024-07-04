local logChannels = {
    general = 'https://discord.com/api/webhooks/1255555992385618023/LQrzBTVevkjhxfCUAwFaugH0fCAgtDuHzym8A9fp7bqNzOqCV4ZKhfbylZt8c_74yX8V',
    accounts = 'https://discord.com/api/webhooks/1255555450796245033/rKZhMAvzFoTrVpl67Jj23WCeB_NxJt6OHkSWRv8JtxbOx5Z_fbezxCuECv5ZwpqAtNwo',
    vehicles = 'https://discord.com/api/webhooks/1257078940200210585/u5Zpvc8rkOjRYNh_KCQdSDEe43p6iuU4CwQVDXN-tPbu6F8L3no3EI7sneJQHA1N8eFw',
    anticheat = 'https://discord.com/api/webhooks/1258419787957141605/HNzaRcnEWG4vVvbfBBn1jdA5zmEPRZ2B5L7bWqKO5u0Diij1CffY9-YGoqMxgmAEclss',
    bans = 'https://discord.com/api/webhooks/1257432355203711056/qUAR4s2mW1wi8ta7f5JczUoNVgB76N7m4SzkTVjgMKWur_9jgM5oNfFF4_6PZ1Youyb2',
    admin = 'https://discord.com/api/webhooks/1257714046023630898/7q7mxNBL04RGbPNiv9I7Sq18RMSuSaRdFkhjYpDZeaepzDk0EXRTOvxJWjImxXuo5vGP',
    reports = 'https://discord.com/api/webhooks/1258091355050082439/ChhbMnteB9NmP_CPIrqCq-INIzrOogw7NEVpdNUwWe-RMubPjVS6cosK7qGueAp0kkSF',
}

local icons = {
    error = '🔴',
    warning = '🟡',
    info = '🔵',
    success = '🟢',
}

function sendDiscordWebhook(url, message)
    local sendOptions = {
        formFields = {
            content = message,
        },
        queueName = 'logs',
        connectionAttempts = 1,
        connectTimeout = 5000,
    }
    
    fetchRemote(url, sendOptions, function() end)
end

function sendLog(channel, type, originalMessage)
    if not logChannels[channel] then channel = 'general' end
    if not icons[type] then type = 'info' end
    
    local currentTimestamp = getRealTime().timestamp
    local message = string.format('`%s` <t:%d:R> - %s', icons[type], currentTimestamp, originalMessage)
    
    sendDiscordWebhook(logChannels[channel], message)
    outputServerLog(string.format('[%s] %s', channel, originalMessage))
end

sendLog('general', 'info', 'Server has started')