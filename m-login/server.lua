local waitingHashes = {}

addEvent('login:login', true)
addEvent('login:register', true)
addEvent('login:spawn', true)
addEvent('onAccountResponse', true)

addEventHandler('onAccountResponse', root, function(hash, response)
    local client = waitingHashes[hash]
    if not client then return end

    if not response[2] then
        local title = response[1] == 'login' and 'Błąd logowania' or 'Błąd rejestracji'
        exports['m-notis']:addNotification(client, 'error', title, response[3], 5000)
    else
        exports['m-notis']:addNotification(client, 'success', 'Sukces', response[3], 5000)
    end

    triggerClientEvent(client, 'login:' .. response[1] .. '-response', resourceRoot, response[2])
end)

addEventHandler('login:login', resourceRoot, function(login, password)
    if getElementData(client, 'player:logged') or getElementData(client, 'player:uid') then return end

    local hash, message = exports['m-core']:loginToAccount({usernameOrEmail = login, password = password})
    if not hash then
        exports['m-notis']:addNotification(client, 'error', 'Błąd logowania', message, 5000)
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
        exports['m-notis']:addNotification(client, 'error', 'Błąd rejestracji', message, 5000)
        triggerClientEvent(client, 'login:register-response', resourceRoot, false)
    end

    waitingHashes[hash] = client
end)

addEventHandler('login:spawn', resourceRoot, function(data)
    -- if not getElementData(client, 'player:logged') or not getElementData(client, 'player:uid') then return end
    -- if getElementData(client, 'player:spawned') then return end

    local x, y, z = data['2'], data['3'], data['4']
    spawnPlayer(client, x, y, z)
    setElementData(client, 'player:spawned', true)
    setCameraTarget(client, client)
end)