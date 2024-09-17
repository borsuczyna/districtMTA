local logChannels = {
    general = 'https://discord.com/api/webhooks/1255555992385618023/LQrzBTVevkjhxfCUAwFaugH0fCAgtDuHzym8A9fp7bqNzOqCV4ZKhfbylZt8c_74yX8V',
    accounts = 'https://discord.com/api/webhooks/1255555450796245033/rKZhMAvzFoTrVpl67Jj23WCeB_NxJt6OHkSWRv8JtxbOx5Z_fbezxCuECv5ZwpqAtNwo',
    vehicles = 'https://discord.com/api/webhooks/1257078940200210585/u5Zpvc8rkOjRYNh_KCQdSDEe43p6iuU4CwQVDXN-tPbu6F8L3no3EI7sneJQHA1N8eFw',
    anticheat = 'https://discord.com/api/webhooks/1258419787957141605/HNzaRcnEWG4vVvbfBBn1jdA5zmEPRZ2B5L7bWqKO5u0Diij1CffY9-YGoqMxgmAEclss',
    bans = 'https://discord.com/api/webhooks/1257432355203711056/qUAR4s2mW1wi8ta7f5JczUoNVgB76N7m4SzkTVjgMKWur_9jgM5oNfFF4_6PZ1Youyb2',
    admin = 'https://discord.com/api/webhooks/1257714046023630898/7q7mxNBL04RGbPNiv9I7Sq18RMSuSaRdFkhjYpDZeaepzDk0EXRTOvxJWjImxXuo5vGP',
    reports = 'https://discord.com/api/webhooks/1258091355050082439/ChhbMnteB9NmP_CPIrqCq-INIzrOogw7NEVpdNUwWe-RMubPjVS6cosK7qGueAp0kkSF',
    trade = 'https://discordapp.com/api/webhooks/1269364540101890191/1ypT9BzZCd7zCA_ZSElRV_wYw23FS-5umn6GCXPfYlQGGdLPz5o7kMcB9UH0kmUWeCrH',
    houses = 'https://discord.com/api/webhooks/1277312069225545850/g9NB6xWXn-8Eo6KybZkUIRfgtYsjOZ6IW7zho5oQzTc1sX_5xRu4zqDojAxa85UpAtwF',
    items = 'https://discord.com/api/webhooks/1285275403522412625/HBUBGqumUxPr_AREzwpw8ibI2d_3dZKLPPWO3gfuSHFCRWV-ChlGtNjt_G1I6sSkKiUb',
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