local vehicleSeats = {
    [408] = {
        {1, -4.6, 0, 0, 0, 0, 'CAR_CHAT', 'car_talkm_loop'},
        {-1, -4.6, 0, 0, 0, 0, 'CAR_CHAT', 'car_talkm_loop'},
    }
}

function _isPlayerInVehicle(player)
    return not not getElementData(player, 'player:occupiedVehicle')
end

function getVehicleFreeAdditionalSeat(vehicle)
    if not isElement(vehicle) then return end
    local seats = vehicleSeats[getElementModel(vehicle)]
    if not seats then return end

    local usedSeats = getElementData(vehicle, 'vehicle:additionalSeats') or {}
    for i = 1, #seats do
        if 
            not usedSeats[i] or
            not isElement(usedSeats[i]) or
            getElementData(usedSeats[i], 'player:attachedVehicle') ~= vehicle or
            getElementData(usedSeats[i], 'player:attachedVehicleSeat') ~= i
        then
            return i, seats[i]
        end
    end

    return false
end

function findEmptyCarSeat(vehicle)
    local max = getVehicleMaxPassengers(vehicle)
    local pas = getVehicleOccupants(vehicle)
    for i = 1, max do
        if not pas[i] then
            return i
        end
    end

    return false
end

function enterAdditionalSeat(player, vehicle)
    local seatId, seatPosition = getVehicleFreeAdditionalSeat(vehicle)
    if not seatId then return end

    local usedSeats = getElementData(vehicle, 'vehicle:additionalSeats') or {}
    usedSeats[seatId] = player
    local _, _, rot = getElementRotation(vehicle)

    setElementData(vehicle, 'vehicle:additionalSeats', usedSeats)
    toggleAllControls(player, false, true, false)
    setElementData(player, 'player:attachedVehicle', vehicle)
    setElementData(player, 'player:attachedVehicleSeat', seatId)
    setElementData(player, 'player:attachedVehicleRot', seatPosition[6])
    attachElements(player, vehicle, unpack(seatPosition))
    setCameraTarget(player, vehicle)

    if seatPosition[7] then
        setPedAnimation(player, seatPosition[7], seatPosition[8], -1, true, false, false, false)
    end

    bindKey(player, 'f', 'down', exitAdditionalSeat)
end

function exitAdditionalSeat(player)
    local vehicle = getElementData(player, 'player:attachedVehicle')
    if not vehicle or not isElement(vehicle) then return end

    local seatId = false
    local usedSeats = getElementData(vehicle, 'vehicle:additionalSeats') or {}
    for i, v in pairs(usedSeats) do
        if v == player then
            seatId = i
            break
        end
    end

    if not seatId then return end

    usedSeats[seatId] = false
    setElementData(vehicle, 'vehicle:additionalSeats', usedSeats)
    detachElements(player, vehicle)
    setCameraTarget(player, player)
    setPedAnimation(player)
    toggleAllControls(player, true)
    setElementData(player, 'player:attachedVehicle', false)

    unbindKey(player, 'f', 'down', exitAdditionalSeat)
end

function allowVehicleAttach(player, vehicle)
    setElementData(player, 'player:attachVehicle', vehicle)
    bindKey(player, 'g', 'down', tryEnterAdditionalSeat)
end

function disAllowVehicleAttach(player)
    setElementData(player, 'player:attachVehicle', false)
    unbindKey(player, 'g', 'down', tryEnterAdditionalSeat)
end

function tryEnterAdditionalSeat(player)
    if getElementData(player, 'player:carryBin') then return end
    if not isControlEnabled(player, 'enter_exit') or not isControlEnabled(player, 'enter_passenger') then return end
    local attachVehicle = getElementData(player, 'player:attachVehicle')
    if not attachVehicle then return end
    if getElementData(player, 'player:attachedVehicle') then return end

    local x, y, z = getElementPosition(player)

    local seat, position = getVehicleFreeAdditionalSeat(attachVehicle)
    if not seat then return end

    local sx, sy, sz = getPositionFromElementOffset(attachVehicle, unpack(position))
    local distance = getDistanceBetweenPoints3D(x, y, z, sx, sy, sz)
    if distance > 4 then return end
    if _isPlayerInVehicle(player) then return end
    
    setElementPosition(player, x, y, z + 0.06)

    setTimer(enterAdditionalSeat, 100 + getPlayerPing(player) * 2, 1, player, attachVehicle)
end

-- reset all players player:attachedVehicle on start
addEventHandler('onResourceStart', resourceRoot, function()
    for _, player in ipairs(getElementsByType('player')) do
        setElementData(player, 'player:attachedVehicle', false)
    end
end)