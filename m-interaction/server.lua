local lastActionTime = {}
local windowStates = {}

local function getVehicleSpeed(vehicle)
    local vx, vy, vz = getElementVelocity(vehicle)
    return math.sqrt(vx^2 + vy^2 + vz^2) * 180
end

addEvent('interaction:action', true)
addEventHandler('interaction:action', resourceRoot, function(action, ...)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `interaction:action` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if lastActionTime[client] and getTickCount() - lastActionTime[client] < 150 then
        exports['m-notis']:addNotification(client, 'warning', 'Interakcja', 'Zbyt szybko wykonujesz akcje interakcji')
        return
    end
    
    lastActionTime[client] = getTickCount()
    local args = {...}
    local vehicle = getPedOccupiedVehicle(client)
    if not vehicle then return end
    local feedbackData = false

    if action == 'engine' then
        local uid = getElementData(vehicle, 'vehicle:uid')
        if uid and getElementData(vehicle, 'vehicle:fuel') <= 0 then
            exports['m-notis']:addNotification(client, 'error', 'Interakcja', 'Brak paliwa w pojeździe')
            return
        end

        setVehicleEngineState(vehicle, not getVehicleEngineState(vehicle))
    elseif action == 'lights' then
        setVehicleOverrideLights(vehicle, getVehicleOverrideLights(vehicle) ~= 2 and 2 or 1)
    elseif action == 'trunk' then
        setVehicleDoorOpenRatio(vehicle, 1, getVehicleDoorOpenRatio(vehicle, 1) > 0 and 0 or 1, 500)
        feedbackData = getVehicleDoorOpenRatio(vehicle, 1) > 0
    elseif action == 'hood' then
        setVehicleDoorOpenRatio(vehicle, 0, getVehicleDoorOpenRatio(vehicle, 0) > 0 and 0 or 1, 500)
        feedbackData = getVehicleDoorOpenRatio(vehicle, 0) > 0
    elseif action == 'window' then
        local seat = getPedOccupiedVehicleSeat(client)
        triggerClientEvent(root, 'interaction:window', resourceRoot, vehicle, seatsWindows[seat], args[1])

        if not windowStates[vehicle] then
            windowStates[vehicle] = {}
        end

        windowStates[vehicle][seatsWindows[seat]] = args[1]
    elseif action == 'handbrake' then
        if getVehicleSpeed(vehicle) > 2 then
            exports['m-notis']:addNotification(client, 'warning', 'Interakcja', 'Nie możesz zaciągnąć ręcznego podczas jazdy')
            return
        end
        setElementFrozen(vehicle, not isElementFrozen(vehicle))
    elseif action == 'door' then
        local seat = getPedOccupiedVehicleSeat(client)
        local door = seatsDoors[seat]
        setVehicleDoorOpenRatio(vehicle, door, getVehicleDoorOpenRatio(vehicle, door) > 0 and 0 or 1, 500)
        feedbackData = getVehicleDoorOpenRatio(vehicle, door) > 0
    elseif action == 'fuelType' then
        local uid = getElementData(vehicle, 'vehicle:uid')

        if uid and getElementData(vehicle, 'vehicle:lpg') then
            local state = getElementData(vehicle, 'vehicle:lpgState')
            setElementData(vehicle, 'vehicle:lpgState', not state)
        end
    end

    triggerClientEvent(client, 'interaction:action-feedback', resourceRoot, action, feedbackData)
end)

addEventHandler('onPlayerResourceStart', root, function(resource)
    if resource ~= getThisResource() then return end
    triggerClientEvent(source, 'interaction:sync', resourceRoot, windowStates)
end)

addEventHandler('onPlayerQuit', root, function()
    lastActionTime[source] = nil
end)