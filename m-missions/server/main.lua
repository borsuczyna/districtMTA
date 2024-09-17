addEvent('missions:requestServerSideVehicle', true)
addEvent('missions:requestServerSidePed', true)
addEvent('missions:warpIntoMissionVehicle', true)
addEvent('missions:destroyMissionElements', true)
addEvent('missions:destroyMissionElement', true)
addEvent('missions:setEngineState', true)
addEvent('missions:setLightsState', true)
addEvent('missions:makeMePedSyncer', true)
addEvent('missions:removePedFromVehicle', true)
addEvent('missions:moveToMissionDimension', true)
addEvent('missions:moveOutOfMissionDimension', true)

local missionElements = {}
missions = {}

local function isMissionElement(player, element)
    if not missionElements[player] then return false end

    for _, missionElements in pairs(missionElements[player]) do
        if missionElements == element then
            return true
        end
    end

    return false
end

local function destroyMissionElement(player, index)
    if not missionElements[player] then return end

    local element = missionElements[player][index]
    if not element then return end

    destroyElement(element)
    missionElements[player][index] = nil
end

local function destroyMissionElements(player)
    if not missionElements[player] then return end

    for _, element in pairs(missionElements[player]) do
        destroyElement(element)
    end

    missionElements[player] = nil
end

addEventHandler('missions:requestServerSideVehicle', resourceRoot, function(mission, index)
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    if not missions[mission] then return end

    local vehicle = missions[mission].allowedVehicles[index]
    if not vehicle then return end

    local serverIndex = ('vehicle:%d'):format(index)

    missionElements[client] = missionElements[client] or {}
    destroyMissionElement(client, serverIndex)

    local vehicleElement = createVehicle(vehicle.model, vehicle.position.x, vehicle.position.y, vehicle.position.z, vehicle.rotation.x, vehicle.rotation.y, vehicle.rotation.z)
    setVehicleColor(vehicleElement, vehicle.primaryColor[1], vehicle.primaryColor[2], vehicle.primaryColor[3], vehicle.secondaryColor[1], vehicle.secondaryColor[2], vehicle.secondaryColor[3])
    missionElements[client][serverIndex] = vehicleElement
    setElementDimension(vehicleElement, 7000 + uid)

    triggerClientEvent(client, 'missions:receiveServerSideVehicle', resourceRoot, mission, index, vehicleElement)
end)

addEventHandler('missions:requestServerSidePed', resourceRoot, function(mission, index)
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    if not missions[mission] then return end

    local ped = missions[mission].allowedPeds[index]
    if not ped then return end

    local serverIndex = ('ped:%d'):format(index)

    missionElements[client] = missionElements[client] or {}
    destroyMissionElement(client, serverIndex)

    local ped = createPed(ped.model, ped.position.x, ped.position.y, ped.position.z, ped.rotation)
    missionElements[client][serverIndex] = ped
    setElementDimension(ped, 7000 + uid)

    triggerClientEvent(client, 'missions:receiveServerSidePed', resourceRoot, mission, index, ped)
end)

addEventHandler('missions:warpIntoMissionVehicle', resourceRoot, function(ped, vehicle, seat)
    if not isElement(vehicle) then return end
    if not isMissionElement(client, ped) and ped ~= client then return end
    if not isMissionElement(client, vehicle) then return end

    warpPedIntoVehicle(ped, vehicle, seat)
    triggerClientEvent(client, 'missions:warpedIntoMissionVehicle', resourceRoot, ped, vehicle, seat)
end)

addEventHandler('missions:destroyMissionElements', resourceRoot, function()
    destroyMissionElements(client)
end)

addEventHandler('missions:destroyMissionElement', resourceRoot, function(element, specialId)
    if not isElement(element) then return end
    if not isMissionElement(client, element) then return end
    
    destroyElement(element)
    triggerClientEvent(client, 'missions:destroyedMissionElement', resourceRoot, specialId)
end)

addEventHandler('missions:setEngineState', resourceRoot, function(vehicle, state)
    if not isElement(vehicle) then return end
    if not isMissionElement(client, vehicle) then return end

    setVehicleEngineState(vehicle, state)
    triggerClientEvent(client, 'missions:changedEngineState', resourceRoot, vehicle, state)
end)

addEventHandler('missions:setLightsState', resourceRoot, function(vehicle, state)
    if not isElement(vehicle) then return end
    if not isMissionElement(client, vehicle) then return end

    setVehicleOverrideLights(vehicle, state and 2 or 1)
    triggerClientEvent(client, 'missions:changedLightsState', resourceRoot, vehicle, state)
end)

addEventHandler('missions:makeMePedSyncer', resourceRoot, function(ped)
    if not isElement(ped) then return end
    if not isMissionElement(client, ped) then return end
    
    setElementSyncer(ped, client)
    triggerClientEvent(client, 'missions:madePedSyncer', resourceRoot, ped)
end)

addEventHandler('missions:removePedFromVehicle', resourceRoot, function(ped)
    if not isElement(ped) then return end
    if not isMissionElement(client, ped) then return end

    removePedFromVehicle(ped)
    triggerClientEvent(client, 'missions:removedPedFromVehicle', resourceRoot, ped)
end)

addEventHandler('missions:moveToMissionDimension', resourceRoot, function()
    local uid = getElementData(client, 'player:uid')
    if not uid then return end

    setElementDimension(client, 7000 + uid)
    triggerClientEvent(client, 'missions:movedToMissionDimension', resourceRoot)
end)

addEventHandler('missions:moveOutOfMissionDimension', resourceRoot, function()
    removePedFromVehicle(client)
    setElementDimension(client, 0)
    triggerClientEvent(client, 'missions:movedOutOfMissionDimension', resourceRoot)
end)

addEventHandler('onVehicleStartExit', root, function(ped)
    if getElementData(ped, 'missions:vehicleExitLocked') then
        cancelEvent()
    end
end)