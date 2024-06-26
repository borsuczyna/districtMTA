local logChannels = {
    general = 'https://discord.com/api/webhooks/1255555992385618023/LQrzBTVevkjhxfCUAwFaugH0fCAgtDuHzym8A9fp7bqNzOqCV4ZKhfbylZt8c_74yX8V',
    accounts = 'https://discord.com/api/webhooks/1255555450796245033/rKZhMAvzFoTrVpl67Jj23WCeB_NxJt6OHkSWRv8JtxbOx5Z_fbezxCuECv5ZwpqAtNwo',
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