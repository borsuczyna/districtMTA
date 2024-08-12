function handleAuthMessage(data)
    if data.success then
        log('Authenticated successfully')
    else
        log('Authentication failed')
        disconnect()
    end
end