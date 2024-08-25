local playing = {}

local function stopPlayback(index)
    local playback = playing[index]
    if not playback then return end

    destroyElement(playback.ped)
    playing[index] = nil

    outputChatBox("Playback have finished", 255, 0, 0)
end

local function getVehicleByIndex(index, vehicleIndex)
    local playback = playing[index]
    if not playback then return end

    local vehicleData = playback.vehicles[vehicleIndex]
    if not vehicleData then return end
    
    return vehicleData.vehicle
end

local function setPlaybackNextFrame(index)
    local playback = playing[index]
    if not playback then return end

    local snapshot = playback.data.data[playback.index]
    if not snapshot then
        stopPlayback(index)
        return
    end

    if snapshot.type == 'enter' then
        local vehicle = getVehicleByIndex(index, snapshot.vehicle)
        if vehicle then
            -- outputChatBox("Entering vehicle" .. snapshot.vehicle)
            setPedEnterVehicle(playback.ped, vehicle, snapshot.seat > 0)
            outputChatBox("Entering vehicle " .. snapshot.vehicle)
            playback.enteringVehicle = snapshot.vehicle
        end
    else
        if playback.enteringVehicle and not getPedOccupiedVehicle(playback.ped) then
            outputChatBox("Waiting to enter vehicle", 255, 0, 0)
            setPedEnterVehicle(playback.ped, getVehicleByIndex(index, playback.enteringVehicle))
        else
            for _, control in ipairs(controlTable) do
                setPedControlState(playback.ped, control, table.find(snapshot.controls, control) ~= nil)
            end

            setPedWeaponSlot(playback.ped, snapshot.weaponSlot)

            if snapshot.type == 'vehicle' then
                local vehicle = getVehicleByIndex(index, snapshot.insideVehicle)
                if vehicle then
                    warpPedIntoVehicle(playback.ped, vehicle)
                end
            else
                if getPedOccupiedVehicle(playback.ped) then
                    removePedFromVehicle(playback.ped)
                end

                setElementMatrix(playback.ped, unpack(snapshot.matrix))

                if snapshot.aimTarget then
                    setPedAimTarget(playback.ped, unpack(snapshot.aimTarget))
                end
            end
        end
    end

    local nextFrame = playback.data.data[playback.index + 1]
    if not nextFrame then
        stopPlayback(index)
        return
    end

    local currentFrameTime = snapshot.tick
    local nextFrameTime = nextFrame.tick
    local timeDiff = nextFrameTime - currentFrameTime

    playback.index = playback.index + 1
    setTimer(setPlaybackNextFrame, timeDiff, 1, index)
end

local function setPlaybackVehicleNextFrame(index, vehicleIndex)
    local playback = playing[index]
    if not playback then return end

    local vehicleData = playback.vehicles[vehicleIndex]
    if not vehicleData then return end

    local snapshot = vehicleData.data[vehicleData.index]
    if not snapshot then
        destroyElement(vehicleData.vehicle)
        playback.vehicles[vehicleIndex] = nil
        return
    end

    -- setElementMatrix(vehicleData.vehicle, unpack(snapshot.matrix))
    setElementPosition(vehicleData.vehicle, unpack(snapshot.position))
    setElementRotation(vehicleData.vehicle, unpack(snapshot.rotation))
    setElementVelocity(vehicleData.vehicle, unpack(snapshot.velocity))
    setElementAngularVelocity(vehicleData.vehicle, unpack(snapshot.angularVelocity))

    local nextFrame = vehicleData.data[vehicleData.index + 1]
    if not nextFrame then
        -- destroyElement(vehicleData.vehicle)
        -- playback.vehicles[vehicleIndex] = nil
        return
    end

    local currentFrameTime = snapshot.tick
    local nextFrameTime = nextFrame.tick
    local timeDiff = nextFrameTime - currentFrameTime

    vehicleData.index = vehicleData.index + 1
    setTimer(setPlaybackVehicleNextFrame, timeDiff, 1, index, vehicleIndex)
end

local function updatePlayback(playback)
    local snapshot = playback.data.data[playback.index]
    if not snapshot then return end

    if playback.enteringVehicle then return end
    local rot = snapshot.rotation
    if rot then
        setElementRotation(playback.ped, 0, 0, rot, "default", true)
    end
end

local function updatePlaybacks()
    for index, playback in pairs(playing) do
        if not isElement(playback.ped) then
            stopPlayback(index)
        else
            updatePlayback(playback)
        end
    end
end

local function createPlaybackVehicle(index, data)
    local vehicle = createVehicle(data.model, 0, 0, 0)
    setElementMatrix(vehicle, unpack(data.matrix))

    local data = {
        vehicle = vehicle,
        data = data.data,
        tick = getTickCount(),
        index = 1,
    }

    local playingData = playing[index]
    local vehicleIndex = #playingData.vehicles + 1
    playingData.vehicles[vehicleIndex] = data

    local firstSnapshot = data.data[1]
    setTimer(setPlaybackVehicleNextFrame, firstSnapshot.tick, 1, index, vehicleIndex)
end

local function startPlayback(name)
    local file = fileOpen("recordings/" .. name .. ".json")
    if not file then
        return print("Failed to open file")
    end

    local data = fromJSON(fileRead(file, fileGetSize(file)))
    fileClose(file)

    local ped = createPed(data.model, 0, 0, 0)
    setElementMatrix(ped, unpack(data.matrix))

    for _, weapon in ipairs(data.weapons) do
        givePedWeapon(ped, weapon[1], weapon[2])
    end

    local playback = {
        name = name,
        ped = ped,
        data = data,
        vehicles = {},
        tick = getTickCount(),
        index = 1,
    }

    local index = #playing + 1
    playing[index] = playback

    for _, vehicleData in ipairs(data.vehicles) do
        createPlaybackVehicle(index, vehicleData)
    end

    local firstSnapshot = data.data[1]
    setTimer(setPlaybackNextFrame, firstSnapshot.tick, 1, index)
    outputChatBox("Playback started", 0, 255, 0)
end

local function startPlaybackCommand(cmd, name)
    if not name or #name == 0 then
        return print("Syntax: /play <name>")
    end

    startPlayback(name)
end

addEventHandler('onClientPedsProcessed', root, updatePlaybacks)
addCommandHandler("play", startPlaybackCommand)