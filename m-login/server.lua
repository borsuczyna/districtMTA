local waitingHashes = {}
local enbClients = {}
local loadedResources = {}

addEvent('login:login', true)
addEvent('login:register', true)
addEvent('login:spawn', true)
addEvent('onAccountResponse', true)

addEventHandler('onPlayerResourceStart', root, function(resource)
    if resource ~= getThisResource() then return end
    loadedResources[source] = true

    if enbClients[source] then
        triggerClientEvent(source, 'core:enbDetected', root)
    end
end)

function handleOnPlayerACInfo(detectedACList, d3d9Size, d3d9MD5, d3d9SHA256)
    if d3d9Size == 0 then return end

    enbClients[source] = true
    if loadedResources[source] then
        triggerClientEvent(source, 'core:enbDetected', root)
    end
end
	
addEventHandler("onPlayerACInfo", root, handleOnPlayerACInfo)

addEventHandler('onAccountResponse', root, function(hash, response)
    local data = waitingHashes[hash]
    if not data then return end
    local client = data[1]
    local time = data[2]
    local timer = data[3]

    if not client then return end
    if time < getTickCount() then return end

    killTimer(timer)
    waitingHashes[hash] = nil

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
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    if getElementData(client, 'player:logged') or getElementData(client, 'player:uid') then
        exports['m-anticheat']:setPlayerTriggerLocked(client, true)
        return
    end

    local hash, message = exports['m-core']:loginToAccount({usernameOrEmail = login, password = password})
    if not hash then
        exports['m-notis']:addNotification(client, 'error', 'Błąd logowania', message)
        triggerClientEvent(client, 'login:login-response', resourceRoot, false)
    end

    local timer = setTimer(loginFailed, 5000, 1, client, hash)
    waitingHashes[hash] = {client, getTickCount() + 5000, timer}
end)

addEventHandler('login:register', resourceRoot, function(email, login, password)
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    if getElementData(client, 'player:logged') or getElementData(client, 'player:uid') then
        exports['m-anticheat']:setPlayerTriggerLocked(client, true)
        return
    end

    local hash, message = exports['m-core']:createAccount({
        username = login,
        password = password,
        email = email,
        ip = getPlayerIP(client),
        serial = getPlayerSerial(client),
    })
    if not hash then
        exports['m-notis']:addNotification(client, 'error', 'Błąd rejestracji', message)
        triggerClientEvent(client, 'login:register-response', resourceRoot, false)
    end

    local timer = setTimer(loginFailed, 5000, 1, client, hash)
    waitingHashes[hash] = {client, getTickCount() + 5000, timer}
end)

addEventHandler('login:spawn', resourceRoot, function(data)
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    if not getElementData(client, 'player:logged') or not getElementData(client, 'player:uid') or getElementData(client, 'player:spawn') then
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Tried to spawn without being logged in/while being already spawned')
        return
    end

    if type(data) ~= 'table' then
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Tried to spawn with invalid spawn data')
        return
    end

    local x, y, z = data['2'], data['3'], data['4']
    if type(x) ~= 'number' or type(y) ~= 'number' or type(z) ~= 'number' then
        exports['m-anticheat']:setPlayerTriggerLocked(client, true, 'Tried to spawn with invalid spawn data')
        return
    end

    spawnPlayer(client, x, y, z, 0, getElementData(client, 'player:skin'))
    setElementData(client, 'player:spawn', {x, y, z})
    setCameraTarget(client, client)
end)