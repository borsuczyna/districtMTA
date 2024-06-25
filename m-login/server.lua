local waitingHashes = {}

addEvent('login:login', true)
addEvent('login:register', true)
addEvent('login:spawn', true)
addEvent('onAccountResponse', true)

addEventHandler('onAccountResponse', root, function(hash, response)
    local data = waitingHashes[hash]
    if not data then return end
    local client = data[1]
    local time = data[2]
    local timer = data[3]

    if not client then return end
    if time < getTickCount() then return end

    killTimer(timer)

    if not response[2] then
        local title = response[1] == 'login' and 'Błąd logowania' or 'Błąd rejestracji'
        exports['m-notis']:addNotification(client, 'error', title, response[3])
    else
        exports['m-notis']:addNotification(client, 'success', 'Sukces', response[3])

        if response[1] == 'login' then
            exports['m-core']:assignPlayerData(client, response[4])
        end
    end

    triggerClientEvent(client, 'login:' .. response[1] .. '-response', resourceRoot, response[2])
end)

function loginFailed(client, hash)
    exports['m-notis']:addNotification(client, 'error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania')
    triggerClientEvent(client, 'login:login-response', resourceRoot, false)
    waitingHashes[hash] = nil
end

addEventHandler('login:login', resourceRoot, function(login, password)
    if getElementData(client, 'player:logged') or getElementData(client, 'player:uid') then return end

    local hash, message = exports['m-core']:loginToAccount({usernameOrEmail = login, password = password})
    if not hash then
        exports['m-notis']:addNotification(client, 'error', 'Błąd logowania', message)
        triggerClientEvent(client, 'login:login-response', resourceRoot, false)
    end

    local timer = setTimer(loginFailed, 5000, 1, client, hash)
    waitingHashes[hash] = {client, getTickCount() + 5000, timer}
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
        exports['m-notis']:addNotification(client, 'error', 'Błąd rejestracji', message)
        triggerClientEvent(client, 'login:register-response', resourceRoot, false)
    end

    local timer = setTimer(loginFailed, 5000, 1, client, hash)
    waitingHashes[hash] = {client, getTickCount() + 5000, timer}
end)

addEventHandler('login:spawn', resourceRoot, function(data)
    -- if not getElementData(client, 'player:logged') or not getElementData(client, 'player:uid') then return end
    -- if getElementData(client, 'player:spawned') then return end

    local x, y, z = data['2'], data['3'], data['4']
    spawnPlayer(client, x, y, z)
    setElementData(client, 'player:spawned', true)
    setElementData(client, 'player:spawn', {x, y, z})
    setCameraTarget(client, client)
end)