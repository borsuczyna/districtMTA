local logChannels = {
    general = 'https://discord.com/api/webhooks/1289600086543695963/lvB9tCsz02QtzuoRQQBRnV7bxyhd9KwvUMQDd26-pAE4mAwW13AvYjn8aniNxSQopSP7',
    accounts = 'https://discord.com/api/webhooks/1289599172097605653/N3P6LHC1ONKjSmh5DaldUkw27VEo97tVjNfRFd83D10ZX5tTuR72BRqBrH5XA6-a5cVD',
    vehicles = 'https://discord.com/api/webhooks/1289598780299018373/IkViiHgDT6u8F3u5LGyjLkH0I_3cv8TmYO0tLYSJTlu_P1z85_s5og_YxeU1qiWdon_H',
    anticheat = 'https://discord.com/api/webhooks/1289599212996263936/C_or1IeRAZwOIfZDRoQU2AqgF9AFMv5a-Uqs_xZ0l9E6FXzIRRoiDfD3sGvadUN9wIjb',
    bans = 'https://discord.com/api/webhooks/1289599216632725528/Radja5qdps914Pz8VqTfaPHnh1Vl1w-JVSy08v1Lh5r58q-H71j4jp6ky7Hjx0WeRw9B',
    admin = 'https://discord.com/api/webhooks/1289599221132955700/IadY7xIz79yC_AafdStApBf6T4vUjv9-TOfwX9y9w8lHD6xuFbt0IqVGib-2pLj6defN',
    reports = 'https://discord.com/api/webhooks/1289599679063130203/clGm0pKHVhB6NPNz09Y9jG1AeA7AxErZow-pHOJG9HVisxbGyxzd0gUpGmz5TPi5rysZ',
    trade = 'https://discord.com/api/webhooks/1289599701523632150/srfuIX3LU-VQw6QJY55BMpVFLo85MQGhlYr-cHB-12AwkNfZV4JpByra5ay0CmqqEuRj',
    houses = 'https://discord.com/api/webhooks/1289599705055232021/KRZCilbEW9mXEEN8VIfddzG2WlSAEkiXN4ECKb2SjWAIDcrvGcLY_yzK9cM1e7HF1rLF',
    items = 'https://discord.com/api/webhooks/1289599707429208157/1U5mPEfLgJzwBNM1YYl8eCsOuYHvnQiUPYd-gvbMPnb3v9moCbS-kRb1V1zxXWQbMr9H',
    transfers = 'https://discord.com/api/webhooks/1296561740552867912/CIQN_wthbR2S7mNQ1wR6Gn3GFnPCOllzTu75tH4lB0oKZbX0bTTUPVthehGuhaUmKl_5',
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