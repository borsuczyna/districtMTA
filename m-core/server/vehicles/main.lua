local vehicles = {}

function getVehicleByUid(uid)
    return vehicles[uid]
end

local function destroyPrivateVehicle(uid)
    local vehicle = getVehicleByUid(uid)
    if not vehicle or not isElement(vehicle) then return end

    destroyElement(vehicle)
    vehicles[uid] = nil
end

local function uidToPlate(uid)
    return string.format('%s%04d', teaEncode(uid, 'district')
        :gsub(' ', '')
        :gsub('[^a-zA-Z]', '')
        :sub(1, 4)
        :upper(), uid % 10000)
end

local function loadPrivateVehicle(data, player, position)
    destroyPrivateVehicle(data.uid)

    if not player and data.parking and data.parking ~= 0 then return end
    
    local x, y, z = unpack(map(split(data.position, ','), tonumber))
    local rx, ry, rz = unpack(map(split(data.rotation, ','), tonumber))
    local fuel = data.fuel
    local mileage = data.mileage
    local health = data.health
    local color = map(split(data.color, ','), tonumber)
    local plate = data.plate or uidToPlate(data.uid)
    local panels = map(split(data.panels, ','), tonumber)
    local doors = map(split(data.doors, ','), tonumber)
    local lights = map(split(data.lights, ','), tonumber)
    local wheelStates = map(split(data.wheels, ','), tonumber)
    local tuning = map(split(data.tuning, ','), tonumber)
    local dirt = map(split(data.dirt, ','), tonumber)

    local vehicle = createVehicle(data.model, x, y, z, rx, ry, rz, plate)
    setElementData(vehicle, 'vehicle:uid', data.uid)
    vehicles[data.uid] = vehicle

    setElementData(vehicle, 'vehicle:fuel', tonumber(data.fuel))
    setElementData(vehicle, 'vehicle:mileage', tonumber(data.mileage))
    setElementHealth(vehicle, health)
    setVehicleColor(vehicle, unpack(color))
    setVehicleHeadLightColor(vehicle, color[13] or 255, color[14] or 255, color[15] or 255)
    setElementData(vehicle, 'vehicle:owner', data.owner)

    for i = 0, 6 do
        setVehiclePanelState(vehicle, i, panels[i + 1] or 0)
    end

    for i = 0, 5 do
        setVehicleDoorState(vehicle, i, doors[i + 1] or 0)
    end

    for i = 0, 3 do
        setVehicleLightState(vehicle, i, lights[i + 1] or 0)
    end

    setVehicleWheelStates(vehicle, unpack(wheelStates))

    for _, tuning in pairs(tuning) do
        addVehicleUpgrade(vehicle, tuning)
    end
    
    exports['m-dirt']:setVehicleDirtLevel(vehicle, dirt[1])
    exports['m-dirt']:setVehicleDirtProgress(vehicle, dirt[2])

    if data.lastDriver then
        setElementData(vehicle, 'vehicle:lastDriver', data.lastDriver)
    end

    if data.sharedPlayers then
        setElementData(vehicle, 'vehicle:sharedPlayers', map(split(data.sharedPlayers, ','), tonumber))
    end

    if data.sharedGroups then
        setElementData(vehicle, 'vehicle:sharedGroups', map(split(data.sharedGroups, ','), tonumber))
    end

    if player then
        warpPedIntoVehicle(player, vehicle)
    end

    if position then
        setElementPosition(vehicle, position.x, position.y, position.z)
    end
end

function putVehicleIntoParking(vehicle)
    local uid = getElementData(vehicle, 'vehicle:uid')
    if not uid then return false, 'Brak identyfikatora pojazdu' end

    local connection = exports['m-mysql']:getConnection()
    if not connection then
        return false, 'Nie udało się schować pojazdu'
    end

    local query = 'UPDATE `m-vehicles` SET `parking` = 1, `parkingDate` = NOW() WHERE `uid` = ?'
    dbExec(connection, query, uid)

    savePrivateVehicle(vehicle)
    destroyPrivateVehicle(uid)
    return true
end

function getVehicleFromParking(player, hash, vehicleId, position, rotation)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local positionString = ('%s,%s,%s'):format(position.x, position.y, position.z)
    local rotationString = ('%s,%s,%s'):format(rotation.x, rotation.y, rotation.z)
    
    local whereQuery, queryArgs = createWhereOwnerQuery(player, shared, group)
    local query = 'UPDATE `m-vehicles` SET `parking` = 0, `position` = ?, `rotation` = ? WHERE `uid` = ? AND ' .. whereQuery
    
    dbExec(connection, query, positionString, rotationString, vehicleId, unpack(queryArgs))
    dbQuery(loadPrivateVehiclesResult, {player, hash}, connection, 'SELECT * FROM `m-vehicles` WHERE `uid` = ? AND ' .. whereQuery, vehicleId, unpack(queryArgs))
end

function buildSavePrivateVehicleQuery(vehicle)
    local uid = getElementData(vehicle, 'vehicle:uid')
    local lastDriver = getElementData(vehicle, 'vehicle:lastDriver')
    local fuel = getElementData(vehicle, 'vehicle:fuel')
    local mileage = getElementData(vehicle, 'vehicle:mileage')
    local health = getElementHealth(vehicle)
    local color = {getVehicleColor(vehicle, true)}
    local tuning = getVehicleUpgrades(vehicle) or {}
    local dirt = {exports['m-dirt']:getVehicleDirtLevel(vehicle), exports['m-dirt']:getVehicleDirtProgress(vehicle)}
    local r, g, b = getVehicleHeadLightColor(vehicle)
    table.insert(color, r); table.insert(color, g); table.insert(color, b)

    local saveData = {
        lastDriver = lastDriver,
        fuel = fuel,
        mileage = mileage,
        health = health,
        position = table.concat({getElementPosition(vehicle)}, ','),
        rotation = table.concat({getElementRotation(vehicle)}, ','),
        color = table.concat(color, ','),
        panels = table.concat(iter(0, 6, function(i)
            return getVehiclePanelState(vehicle, i)
        end), ','),
        doors = table.concat(iter(0, 5, function(i)
            return getVehicleDoorState(vehicle, i)
        end), ','),
        lights = table.concat(iter(0, 3, function(i)
            return getVehicleLightState(vehicle, i)
        end), ','),
        wheels = table.concat({getVehicleWheelStates(vehicle)}, ','),
        tuning = table.concat(tuning, ','),
        dirt = table.concat(dirt, ','),
    }

    local query = 'UPDATE `m-vehicles` SET ' .. table.concat(mapk(saveData, function(value, key)
        return '`' .. key .. '` = ?'
    end), ', ') .. ' WHERE `uid` = ?'
    local values = mapk(saveData, function(value)
        return value
    end)
    table.insert(values, uid)

    return query, values, uid
end

function savePrivateVehicle(vehicle)
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        outputDebugString('Brak połączenia z bazą danych', 1)
        return
    end

    local query, values, uid = buildSavePrivateVehicleQuery(vehicle)
    dbExec(connection, query, unpack(values))
end

function saveAllPrivateVehicles()
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        outputDebugString('Brak połączenia z bazą danych', 1)
        return
    end

    local startTime = getTickCount()
    for _, vehicle in pairs(vehicles) do
        savePrivateVehicle(vehicle)
    end

    exports['m-logs']:sendLog('vehicles', 'info', 'Zapisano dane wszystkich pojazdów (' .. getTickCount() - startTime .. 'ms)')
end

function loadPrivateVehiclesResult(queryResult, player, hash)
    local result = dbPoll(queryResult, 0)

    if hash then
        if #result == 0 then
            exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie udało się wyjąć pojazdu'})
        else
            exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Pomyślnie wyjęto pojazd z parkingu'})
        end
    end

    for _, row in ipairs(result) do
        loadPrivateVehicle(row, player)
    end
end

local function loadPrivateVehicles()
    local connection = exports['m-mysql']:getConnection()
    if not connection then
        outputDebugString('Brak połączenia z bazą danych', 1)
        return
    end

    dbQuery(loadPrivateVehiclesResult, {}, connection, 'SELECT * FROM `m-vehicles`')
end

function canUidEnterVehicle(uid, vehicle)
    local owner = getElementData(vehicle, 'vehicle:owner')
    if owner == uid then return true end

    local sharedPlayers = getElementData(vehicle, 'vehicle:sharedPlayers')
    if sharedPlayers and table.find(sharedPlayers, uid) then return true end

    -- local sharedGroups = getElementData(vehicle, 'vehicle:sharedGroups')
    

    return false
end

function tryVehicleStartEnter(player, seat)
    local uid = getElementData(player, 'player:uid')
    if not uid then return cancelEvent() end

    local timeLeft, admin, reason = exports['m-core']:isPlayerHaveTakenLicense(player)
    if timeLeft then
        if seat == 0 then
            cancelEvent()
            exports['m-notis']:addNotification(player, 'error', 'Prawo jazdy', ('Posiadasz zabrane prawo jazdy przez %s na %s z powodu: %s'):format(admin, timeLeft, reason))
        else
            local vehicleOccupants = #getVehicleOccupants(source)
            if vehicleOccupants == 0 then cancelEvent() end
        end
    end

    local vehicleUid = getElementData(source, 'vehicle:uid')
    if not vehicleUid then return end

    if not canUidEnterVehicle(uid, source) then
        if seat == 0 then
            cancelEvent()
            exports['m-notis']:addNotification(player, 'warning', 'Pojazd', 'Nie masz dostępu do tego pojazdu')
        else
            local vehicleOccupants = #getVehicleOccupants(source)
            if vehicleOccupants == 0 then cancelEvent() end
        end
    end

    setElementData(source, 'vehicle:lastDriver', uid)
end

local function getPlayerVehiclesResult(queryHandle, player, hash)
    local result = dbPoll(queryHandle, 0)
    if not result then
        exports['m-ui']:respondToRequest(hash, {status = 'error', message = 'Nie udało się pobrać danych'})
        return
    end
    
    exports['m-ui']:respondToRequest(hash, {status = 'success', data = result})
end

function createWhereOwnerQuery(player, shared, group, footer)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    if shared == nil then shared = true end
    if group == nil then group = true end
    footer = footer or ''

    local query = '(' .. footer .. '`owner` = ?'
    local queryArgs = {uid}

    if shared then
        query = query .. ' OR FIND_IN_SET(?, ' .. footer .. '`sharedPlayers`))'
        table.insert(queryArgs, uid)
    else
        query = query .. ')'
    end

    -- TODO: sharedGroups

    return query, queryArgs
end

function getPlayerVehicles(player, hash, parking, shared, group)
    local uid = getElementData(player, 'player:uid')
    if not uid then return end

    if shared == nil then shared = true end
    if group == nil then group = true end

    local connection = exports['m-mysql']:getConnection()
    if not connection then return end

    local query = [[
        SELECT v.*, u.username AS ownerName, ud.username AS lastDriverName
        FROM `m-vehicles` v
        JOIN `m-users` u ON u.`uid` = v.`owner`
        LEFT JOIN `m-users` ud ON ud.`uid` = v.`lastDriver`
    ]]

    local whereQuery, queryArgs = createWhereOwnerQuery(player, shared, group, 'v.')
    query = query .. ' WHERE ' .. whereQuery

    if parking ~= nil then
        query = query .. ' AND `parking` = ' .. (parking and 1 or 0)
    end

    dbQuery(getPlayerVehiclesResult, {player, hash}, connection, query, unpack(queryArgs))
end

addEventHandler('onResourceStart', resourceRoot, loadPrivateVehicles)
addEventHandler('onResourceStop', resourceRoot, saveAllPrivateVehicles)
addEventHandler('onVehicleStartEnter', root, tryVehicleStartEnter)
setTimer(saveAllPrivateVehicles, 300000, 0) -- 5 minutes

addEventHandler('onVehicleEnter', root, function(player, seat)
    setElementData(player, 'player:occupiedVehicle', source)
end)

addEventHandler('onVehicleExit', root, function(player, seat)
    setElementData(player, 'player:occupiedVehicle', false)
end)