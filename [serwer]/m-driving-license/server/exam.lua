addEvent('drivingLicense:finishExam', true)

local vehicles = {}
local peds = {}
local doingExams = {}

local function destroyExamVehicle(player)
    if isElement(vehicles[player]) then
        destroyElement(vehicles[player])
    end

    if isElement(peds[player]) then
        destroyElement(peds[player])
    end
end

function startExam(player, category)
    if not examsData[category] then
        return
    end

    destroyExamVehicle(player)

    local exam = examsData[category]
    local vehicle = createVehicle(exam.vehicle, exam.spawn[1], exam.spawn[2], exam.spawn[3], exam.spawn[4], exam.spawn[5], exam.spawn[6])
    local ped = createPed(8, 0, 0, 0)
    warpPedIntoVehicle(player, vehicle)
    warpPedIntoVehicle(ped, vehicle, 1)
    setElementData(vehicle, 'vehicle:engineCapacity', 0.0)
    setElementData(vehicle, 'element:ghostmode', true)
    setElementInterior(player, 0)
    setElementFrozen(vehicle, true)
    vehicles[player] = vehicle
    peds[player] = ped

    triggerClientEvent(player, 'drivingLicense:startExam', resourceRoot, category, vehicle)
    doingExams[player] = category
end

function stopExam(player)
    destroyExamVehicle(player)
end

local function teleportBack(player, position, dimension, interior)
    removePedFromVehicle(player)
    setElementPosition(player, unpack(position))
    setElementDimension(player, dimension)
    setElementInterior(player, interior)
end

addEventHandler('drivingLicense:finishExam', resourceRoot, function(passed)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `drivingLicense:finishExam` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    local uid = getElementData(client, 'player:uid')
    if not uid then return end
    if exports['m-anticheat']:isPlayerTriggerLocked(client) then return end
    
    if not doingExams[client] then
        exports['m-notis']:addNotification(client, 'error', 'Egzamin', 'Nie jesteś w trakcie egzaminu.')
        return
    end
    
    local category = doingExams[client]
    local exam = examsData[category]

    if passed then
        exports['m-notis']:addNotification(client, 'success', 'Egzamin', 'Gratulacje! Zdałeś egzamin.')
        exports['m-core']:addPlayerLicense(client, category)
    end
    
    destroyExamVehicle(client)
    doingExams[client] = nil

    teleportBack(client, exam.finish.position, exam.finish.dimension, exam.finish.interior)
    -- setTimer(teleportBack, 1000, 1, client, exam.finish.position, exam.finish.dimension, exam.finish.interior)
end)

addEventHandler('onVehicleStartExit', root, function(ped, seat)
    if seat ~= 0 then return end
    if vehicles[ped] == source then
        cancelEvent()
    end
end)

addEventHandler('onVehicleStartEnter', root, function(ped, seat)
    local isExamVehicle = false
    for player, vehicle in pairs(vehicles) do
        if vehicle == source then
            isExamVehicle = true
            break
        end
    end

    if isExamVehicle then
        cancelEvent()
    end
end)

addEventHandler('onVehicleDamage', root, function()
    local health = getElementHealth(source)
    if health > 950 then return end

    for player, vehicle in pairs(vehicles) do
        if vehicle == source then
            destroyExamVehicle(player)
            local category = doingExams[player]
            local exam = examsData[category]

            doingExams[player] = nil
            exports['m-notis']:addNotification(player, 'error', 'Egzamin', 'Zniszczyłeś pojazd egzaminacyjny.')
            triggerClientEvent(player, 'drivingLicense:finishExam', resourceRoot, false, true)
            -- setTimer(teleportBack, 1000, 1, player, exam.finish.position, exam.finish.dimension, exam.finish.interior)
            teleportBack(player, exam.finish.position, exam.finish.dimension, exam.finish.interior)
            break
        end
    end
end)

addEventHandler('onPlayerQuit', root, function()
    destroyExamVehicle(source)
end)