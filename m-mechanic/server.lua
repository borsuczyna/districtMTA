addEvent('mechanic:repair', true)
addEvent('mechanic:getServerTick', true)

local function loadRepairShop(data)
    local repairMarker = createMarker(data.marker[1], data.marker[2], data.marker[3] - 0.95, 'cylinder', 1, 255, 100, 0, 0)
    local repairColShape = createColSphere(data.colShape[1], data.colShape[2], data.colShape[3] - 1, 3)
    local repairPreviewMarker = createMarker(data.colShape[1], data.colShape[2], data.colShape[3] - 1, 'cylinder', 1, 255, 100, 0, 0)
    local repairGate = createObject(17951, data.gate[1], data.gate[2], data.gate[3] - 3.3, 0, 0, data.rot + 90)
    setObjectScale(repairGate, 0.93)

    setElementData(repairMarker, 'marker:title', 'Mechanik')
    setElementData(repairMarker, 'marker:desc', 'Stanowisko naprawcze')
    setElementData(repairMarker, 'marker:icon', 'mechanic')

    setElementData(repairPreviewMarker, 'marker:square', {3, 6, data.rot})
    setElementData(repairPreviewMarker, 'marker:title', '')
    setElementData(repairPreviewMarker, 'marker:desc', '')
    setElementData(repairPreviewMarker, 'marker:icon', 'none')

    local renderElement = createElement('repair:render')
    setElementPosition(renderElement, data.render[1], data.render[2], data.render[3])
    setElementData(renderElement, 'repair:colShape', repairColShape)
    setElementData(renderElement, 'repair:marker', repairMarker)
    setElementData(renderElement, 'repair:state', 0)
    setElementData(renderElement, 'repair:data', data.render)
    setElementData(repairColShape, 'repair:render', renderElement)
    setElementData(repairMarker, 'repair:render', renderElement)

    addEventHandler('onColShapeHit', repairColShape, repairColShapeHit)
    addEventHandler('onColShapeLeave', repairColShape, repairColShapeLeave)
    addEventHandler('onMarkerHit', repairMarker, repairMarkerHit)
    addEventHandler('onMarkerLeave', repairMarker, repairMarkerLeave)

    data.repairColShape = repairColShape
    data.repairMarker = repairMarker
    data.repairPreviewMarker = repairPreviewMarker
    data.repairGate = repairGate
    data.renderElement = renderElement
end

local function openGate(gate)
    local x, y, z = getElementPosition(gate)
    moveObject(gate, 2000, x, y, z - 3.3)
    
    local nearbyPlayers = getElementsWithinRange(x, y, z, 30, 'player')
    triggerClientEvent(nearbyPlayers, 'mechanic:gateSound', resourceRoot, x, y, z)
end

local function closeGate(gate)
    local x, y, z = getElementPosition(gate)
    moveObject(gate, 2000, x, y, z + 3.3)
    
    local nearbyPlayers = getElementsWithinRange(x, y, z, 30, 'player')
    triggerClientEvent(nearbyPlayers, 'mechanic:gateSound', resourceRoot, x, y, z)
end

local function updateColShapeState(colShape)
    local renderElement = getElementData(colShape, 'repair:render')
    local state = getElementData(renderElement, 'repair:state')

    if state >= 0 and state <= 2 then
        local elementsInside = getElementsWithinColShape(colShape, 'vehicle')

        setElementData(renderElement, 'repair:vehicle', nil)
        
        if #elementsInside == 0 then
            setElementData(renderElement, 'repair:state', 0)
        elseif #elementsInside == 1 then
            setElementData(renderElement, 'repair:state', 1)
            setElementData(renderElement, 'repair:vehicle', elementsInside[1])
        else
            setElementData(renderElement, 'repair:state', 2)
        end
    end
end

local function isVehicleInsideAnyRepairColShape(vehicle)
    for i, repairPosition in ipairs(repairPositions) do
        if isElementWithinColShape(vehicle, repairPosition.repairColShape) then
            return repairPosition
        end
    end

    return false
end

function repairColShapeHit()
    updateColShapeState(source)
end

function repairColShapeLeave()
    updateColShapeState(source)
end

function repairMarkerHit(hitElement, matchingDimension)
    if getElementType(hitElement) ~= 'player' then return end
    if getPedOccupiedVehicle(hitElement) then return end

    local renderElement = getElementData(source, 'repair:render')
    local repairState = getElementData(renderElement, 'repair:state')
    local vehicle = getElementData(renderElement, 'repair:vehicle')

    if repairState == 0 then
        exports['m-notis']:addNotification(hitElement, 'warning', 'Stanowisko naprawcze', 'Stanoisko naprawcze jest puste')
    elseif repairState == 1 then
        local repairs = getVehiclePossibleRepairs(vehicle)
        triggerClientEvent(hitElement, 'mechanic:showRepairWindow', resourceRoot, repairs, vehicle)
    elseif repairState == 2 then
        exports['m-notis']:addNotification(hitElement, 'warning', 'Stanowisko naprawcze', 'Na stanoisku jest zbyt wiele pojazdów')
    end
end

function repairMarkerLeave(hitElement, matchingDimension)
    if getElementType(hitElement) ~= 'player' then return end
    triggerClientEvent(hitElement, 'mechanic:hide', resourceRoot)
end

local function loadRepairShops()
    for i, repairPosition in ipairs(repairPositions) do
        loadRepairShop(repairPosition)
    end

    for i, pos in ipairs(repairBlips) do
        local blip = createBlip(pos[1], pos[2], pos[3], 48, 2, 255, 255, 255, 255, 0, 9999)
        setElementData(blip, 'blip:hoverText', 'Mechanik')
    end
end

addEventHandler('onResourceStart', resourceRoot, loadRepairShops)

setTimer(function()
    for i, repairPosition in ipairs(repairPositions) do
        updateColShapeState(repairPosition.repairColShape)
    end
end, 10000, 0)

-- repairing

local function finishRepair(inside, vehicle, repairs)
    setElementData(inside.renderElement, 'repair:state', 0)
    setElementData(inside.renderElement, 'repair:time', 0)

    if vehicle and isElement(vehicle) then
        setElementFrozen(vehicle, false)
        setElementData(vehicle, 'vehicle:repairing', false)
        
        repairs = getRepairsByNames(repairs)
        for i, repair in ipairs(repairs) do
            repair.repair(vehicle)
        end
    end

    openGate(inside.repairGate)
end

addEventHandler('mechanic:repair', resourceRoot, function(vehicle, repair)
    if source ~= resourceRoot then
        local __args = ''; local __i = 1; while true do local name, value = debug.getlocal(1, __i); if not name then break end; if name ~= '__args' and name ~= '__i' then __args = __args .. ('`%s`: `%s`\n'):format(name, inspect(value)); end __i = __i + 1 end; __args = __args:sub(1, -2)
        local banMessage = ('Tried to trigger `mechanic:repair` event with wrong source (%s)\nArguments:\n%s'):format(tostring(source), __args)
        return exports['m-anticheat']:ban(client, 'Trigger hack', banMessage)
    end

    if not isElement(vehicle) or getElementType(vehicle) ~= 'vehicle' then return end

    local inside = isVehicleInsideAnyRepairColShape(vehicle)
    if not inside then
        exports['m-notis']:addNotification(client, 'error', 'Naprawa', 'Pojazd nie znajduje się na stanowisku naprawczym')
        triggerClientEvent(client, 'mechanic:respond', resourceRoot, false)
        return
    end

    local occupants = getVehicleOccupants(vehicle)
    local controller = getVehicleController(vehicle)
    if #occupants ~= 0 or controller then
        exports['m-notis']:addNotification(client, 'error', 'Naprawa', 'Pojazd musi być pusty podczas naprawy')
        triggerClientEvent(client, 'mechanic:respond', resourceRoot, false)
        return
    end

    local repairs = getRepairsByNames(split(repair, ','))
    local totalPrice = 0
    local totalTime = 0

    for i, repair in ipairs(repairs) do
        totalPrice = totalPrice + repair.price(vehicle)
        totalTime = totalTime + repair.time(vehicle)
    end

    if getPlayerMoney(client) < totalPrice then
        exports['m-notis']:addNotification(client, 'error', 'Naprawa', 'Nie posiadasz wystarczająco pieniędzy na naprawę pojazdu')
        triggerClientEvent(client, 'mechanic:respond', resourceRoot, false)
        return
    end

    exports['m-core']:givePlayerMoney(client, 'repair', ('Naprawa pojazdu %s'):format(getVehicleName(vehicle)), -totalPrice)

    setElementData(inside.renderElement, 'repair:state', 3)
    setElementData(inside.renderElement, 'repair:time', getTickCount() + totalTime * 1000)
    closeGate(inside.repairGate)
    setElementFrozen(vehicle, true)
    setElementData(vehicle, 'vehicle:repairing', true)
    setTimer(finishRepair, totalTime * 1000, 1, inside, vehicle, split(repair, ','))
    
    local minutes = math.floor(totalTime / 60)
    local seconds = totalTime % 60
    exports['m-notis']:addNotification(client, 'success', 'Naprawa', ('Naprawa została rozpoczęta.<br>Czas naprawy: %d minut %d sekund'):format(minutes, seconds))
    triggerClientEvent(client, 'mechanic:respond', resourceRoot, true)
end)

addEventHandler('onVehicleStartEnter', root, function(player, seat, jacked)
    if getElementData(source, 'vehicle:repairing') then
        cancelEvent()
        exports['m-notis']:addNotification(player, 'error', 'Naprawa', 'Pojazd jest obecnie w naprawie')
    end
end)

addEventHandler('mechanic:getServerTick', root, function()
    triggerClientEvent(client, 'mechanic:serverTickResponse', resourceRoot, getTickCount())
end)

-- on resource start remove all vehicles repairing
setTimer(function()
    for i, vehicle in ipairs(getElementsByType('vehicle')) do
        if getElementData(vehicle, 'vehicle:repairing') then
            setElementData(vehicle, 'vehicle:repairing', false)
            setElementFrozen(vehicle, false)
        end
    end
end, 1000, 1)