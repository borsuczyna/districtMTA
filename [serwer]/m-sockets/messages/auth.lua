function handleAuthMessage(data)
    if data.success then
        log('Authenticated successfully')
        triggerEvent('socket:onAuthenticated', root)
    else
        log('Authentication failed')
        disconnect()
    end
end