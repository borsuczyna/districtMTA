local stretchers = {}
local stretchersColShapes = {}
local vehicleStretchers = {}
local ambulanceId = 416
local stretcherPosition = {0, 1.4, -0.45}

function findFreeSeat(vehicle, seats)
    for i, seat in ipairs(seats) do
        if not getVehicleOccupant(vehicle, seat) then
            return seat
        end
    end

    return false
end

function toggleStretcherControls(player, state)
    toggleControl(player, 'jump', state)
    toggleControl(player, 'sprint', state)
    toggleControl(player, 'enter_exit', state)
end

function onStretcherColShapeHit(hitElement, matchingDimension)
    if getElementType(hitElement) ~= 'player' then return end

    local owner = getElementData(source, 'stretcher:owner')
    if owner ~= hitElement then return end

    local stretcherObject = stretchers[hitElement]
    attachElements(stretcherObject, hitElement, unpack(stretcherPosition))
    destroyElement(source)
    bindKey(hitElement, 'h', 'down', leaveStretcher)
    toggleStretcherControls(hitElement, false)
end

function leaveStretcher(player)
    if not isElement(player) then return end
    if not isElement(stretchers[player]) then return end

    local stretcher = stretchers[player]
    detachElements(stretcher, player)
    unbindKey(player, 'h', 'down', leaveStretcher)
    local x, y, z = getPositionFromElementOffset(player, unpack(stretcherPosition))
    local rx, ry, rz = getElementRotation(player)
    setElementPosition(stretcher, x, y, z)
    setElementRotation(stretcher, rx, ry, rz)

    local colShape = createColSphere(0, 0, 0, 0.6)
    attachElements(colShape, stretcher)
    setElementData(colShape, 'stretcher:owner', player)

    addEventHandler('onColShapeHit', colShape, onStretcherColShapeHit)
    stretchersColShapes[player] = colShape
    toggleStretcherControls(player, true)
    exports['m-notis']:addNotification(player, 'info', 'Nosze', 'Nosze zostały opuszczone, aby je podnieść wejdź w nie')
end

function stopUsingStretcher(player, vehicle)
    if not isElement(player) then return end
    if not isElement(stretchers[player]) then return end

    local stretcherPlayer = getElementData(stretchers[player], 'stretchers:player')
    if isElement(stretcherPlayer) then
        removeFromStretcher(stretcherPlayer)
        if vehicle then
            warpPedIntoVehicle(stretcherPlayer, vehicle, findFreeSeat(vehicle, {2, 3, 1}))
        end
    end

    destroyElement(stretchers[player])
    stretchers[player] = nil

    if isElement(stretchersColShapes[player]) then
        destroyElement(stretchersColShapes[player])
        stretchersColShapes[player] = nil
    end
    
    unbindKey(player, 'h', 'down', leaveStretcher)
    toggleStretcherControls(player, true)
end

function useStretcher(player, vehicle)
    if stretchers[player] then
        stopUsingStretcher(player, vehicle)
        return
    end

    local stretcher = createObject(1337, 0, 0, 0)
    setElementCollisionsEnabled(stretcher, false)
    setElementData(stretcher, 'element:model', 'nosze')
    attachElements(stretcher, player, unpack(stretcherPosition))
    stretchers[player] = stretcher
    bindKey(player, 'h', 'down', leaveStretcher)
    exports['m-notis']:addNotification(player, 'info', 'Nosze', 'Naciśnij <kbd class="keycap">H</kbd> aby zostawić nosze')
    toggleStretcherControls(player, false)
end

function putOnStretcher(player, playerToPut)
    if not isElement(player) or not isElement(playerToPut) then return end
    if not isElement(stretchers[player]) then return end

    setElementData(playerToPut, 'player:stretcher', stretchers[player])
    setElementData(stretchers[player], 'stretchers:player', playerToPut)
    setElementCollisionsEnabled(playerToPut, false)
end

function removeFromStretcher(player)
    if not isElement(player) then return end

    local stretcher = getElementData(player, 'player:stretcher')
    if not isElement(stretcher) then return end

    removeElementData(player, 'player:stretcher')
    removeElementData(stretcher, 'stretchers:player')
    setElementCollisionsEnabled(player, true)
    local x, y, z = getPositionFromElementOffset(stretcher, 0, -2, 0)
    setElementPosition(player, x, y, z)
end

-- vehicle stretcher
function destroyVehicleStretcher(vehicle)
    if not isElement(vehicle) then return end
    if not isElement(vehicleStretchers[vehicle]) then return end
    destroyElement(vehicleStretchers[vehicle])
    vehicleStretchers[vehicle] = nil
end

function putStretcherInVehicle(vehicle)
    if not isElement(vehicle) then return end
    if isElement(vehicleStretchers[vehicle]) then return end

    local stretcher = createObject(1337, 0, 0, 0)
    setElementCollisionsEnabled(stretcher, false)
    setElementData(stretcher, 'element:model', 'nosze')
    attachElements(stretcher, vehicle, 0, -2.5, 0.2)
    vehicleStretchers[vehicle] = stretcher
end

-- on resource start create stretcher for ambulance
addEventHandler('onResourceStart', resourceRoot, function()
    for i, vehicle in ipairs(getElementsByType('vehicle')) do
        if getElementModel(vehicle) == ambulanceId then
            putStretcherInVehicle(vehicle)
        end
    end
end)

-- on vehicle destroy destroy stretcher
addEventHandler('onElementDestroy', root, function()
    if getElementType(source) == 'vehicle' then
        destroyVehicleStretcher(source)
    end
end)

-- on vehicle create create stretcher
addEventHandler('onElementStartSync', root, function()
    if getElementType(source) == 'vehicle' then
        if getElementModel(source) == ambulanceId then
            putStretcherInVehicle(source)
        end
    end
end)

-- on player leave
addEventHandler('onPlayerQuit', root, function()
    if isElement(stretchers[source]) then
        stopUsingStretcher(source)
    end
end)

-- debug
-- useStretcher(getPlayerFromName('borsuczyna'))
-- putOnStretcher(getPlayerFromName('borsuczyna'), getPlayerFromName('fuckltc'))
-- addCommandHandler('rem', function(player)
--     removeFromStretcher(player)
-- end)