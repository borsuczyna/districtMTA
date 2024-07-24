local waitingHashes = {}
local enbClients = {}
local loadedResources = {}

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

    if not client then return end
    if time < getTickCount() then return end

    waitingHashes[hash] = nil

    if not response[2] then
        local title = response[1] == 'login' and 'Błąd logowania' or 'Błąd rejestracji'
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = title, message = response[3]})
    else
        exports['m-ui']:respondToRequest(hash, {status = 'success', title = 'Sukces', message = response[3]})

        if response[1] == 'login' then
            exports['m-core']:assignPlayerData(client, response[4])
        end
    end
end)

addEvent('login:login')
addEventHandler('login:login', resourceRoot, function(hash, player, login, password)
    if getElementData(player, 'player:logged') or getElementData(player, 'player:uid') then
        exports['m-anticheat']:setPlayerTriggerLocked(player, true)
        return
    end

    local message = exports['m-core']:loginToAccount(hash, {usernameOrEmail = login, password = password})
    if message then

        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd logowania', message = message})
    end

    waitingHashes[hash] = {player, getTickCount() + 5000}
end)

addEvent("login:register")
addEventHandler('login:register', resourceRoot, function(hash, player, email, login, password)
    if getElementData(player, 'player:logged') or getElementData(player, 'player:uid') then
        exports['m-anticheat']:setPlayerTriggerLocked(player, true)
        return
    end

    local message = exports['m-core']:createAccount(hash, {
        username = login,
        password = password,
        email = email,
        ip = getPlayerIP(player),
        serial = getPlayerSerial(player),
    })
    if message then
        exports['m-ui']:respondToRequest(hash, {status = 'error', title = 'Błąd rejestracji', message = message})
    end

    waitingHashes[hash] = {player, getTickCount() + 5000}
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