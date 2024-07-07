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

local function loadPrivateVehicle(data)
    destroyPrivateVehicle(data.uid)
    
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

    if data.lastDriver then
        setElementData(vehicle, 'vehicle:lastDriver', data.lastDriver)
    end

    if data.sharedPlayers then
        setElementData(vehicle, 'vehicle:sharedPlayers', map(split(data.sharedPlayers, ','), tonumber))
    end

    if data.sharedGroups then
        setElementData(vehicle, 'vehicle:sharedGroups', map(split(data.sharedGroups, ','), tonumber))
    end
end

function buildSavePrivateVehicleQuery(vehicle)
    local uid = getElementData(vehicle, 'vehicle:uid')
    local lastDriver = getElementData(vehicle, 'vehicle:lastDriver')
    local fuel = getElementData(vehicle, 'vehicle:fuel')
    local mileage = getElementData(vehicle, 'vehicle:mileage')
    local health = getElementHealth(vehicle)
    local color = {getVehicleColor(vehicle, true)}
    local tuning = getVehicleUpgrades(vehicle) or {}
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

local function loadPrivateVehiclesResult(queryResult)
    local result = dbPoll(queryResult, 0)
    
    for _, row in ipairs(result) do
        loadPrivateVehicle(row)
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

addEventHandler('onResourceStart', resourceRoot, loadPrivateVehicles)
addEventHandler('onResourceStop', resourceRoot, saveAllPrivateVehicles)
addEventHandler('onVehicleStartEnter', root, tryVehicleStartEnter)
setTimer(saveAllPrivateVehicles, 300000, 0) -- 5 minutes