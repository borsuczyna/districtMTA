function getDiscordAccountData(userId)
    sendSocketMessage('getAccountData', {userId = userId})
end