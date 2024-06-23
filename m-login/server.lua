local waitingHashes = {}

addEvent('login:login', true)
addEvent('login:register', true)
addEvent('onAccountResponse', true)

addEventHandler('onAccountResponse', root, function(hash, response)
    local client = waitingHashes[hash]
    if not client then return end

    if not response[2] then
        outputChatBox(response[3], client, 255, 0, 0)
    end

    triggerClientEvent(client, 'login:' .. response[1] .. '-response', resourceRoot, response[2])
end)

addEventHandler('login:login', resourceRoot, function(login, password)
    if getElementData(client, 'player:logged') or getElementData(client, 'player:uid') then return end

    local hash, message = exports['m-core']:loginToAccount({usernameOrEmail = login, password = password})
    if not hash then
        outputChatBox(message, client, 255, 0, 0)
        triggerClientEvent(client, 'login:login-response', resourceRoot, false)
    end

    waitingHashes[hash] = client
end)

addEventHandler('login:register', resourceRoot, function(email, login, password)
    if getElementData(client, 'player:logged') or getElementData(client, 'player:uid') then return end

    local hash, message = exports['m-core']:createAccount({
        username = login,
        password = password,
        email = email,
        ip = getPlayerIP(client),
        serial = getPlayerSerial(client)
    })
    if not hash then
        outputChatBox(message, client, 255, 0, 0)
        triggerClientEvent(client, 'login:register-response', resourceRoot, false)
    end

    waitingHashes[hash] = client
end)