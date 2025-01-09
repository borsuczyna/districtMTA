addEvent("onPlaybackFinished", true)

local playing = {}

local function killPlayback(index)
    local playback = playing[index]
    if not playback then return end

    -- kill timers
    for _, timer in ipairs(playback.timers) do
        if isTimer(timer) then
            killTimer(timer)
        end
    end

    -- destroy vehicles
    for _, vehicleData in pairs(playback.vehicles) do
        if isElementLocal(vehicleData.vehicle) then
            destroyElement(vehicleData.vehicle)
            print("Destroyed vehicle")
        end
        -- destroyElement(vehicleData.vehicle)
    end
end

function destroyPlaybackElements(name)
    for index, playback in pairs(playing) do
        if playback.name == name then
            killPlayback(index)
            playing[index] = nil
            return
        end
    end
end

local function stopPlayback(index, trigger)
    local playback = playing[index]
    if not playback then return end

    playing[index] = nil

    -- outputChatBox("Playback have finished", 255, 0, 0)
    if trigger then
        triggerEvent("onPlaybackFinished", root, playback.name)
    end
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
        stopPlayback(index, true)
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
    elseif snapshot.type == 'exit' then
        setPedExitVehicle(playback.ped)
        outputChatBox("Exiting vehicle")
        playback.exitVehicle = true
    else
        if playback.enteringVehicle and not getPedOccupiedVehicle(playback.ped) then
            outputChatBox("Waiting to enter vehicle", 255, 0, 0)
            setPedEnterVehicle(playback.ped, getVehicleByIndex(index, playback.enteringVehicle))

            if snapshot.insideVehicle then
                -- warpPedIntoVehicle(playback.ped, getVehicleByIndex(index, snapshot.insideVehicle))
                playback.enteringVehicle = nil
            end
        elseif playback.exitVehicle and getPedOccupiedVehicle(playback.ped) then
            outputChatBox("Waiting to exit vehicle", 255, 0, 0)
            setPedExitVehicle(playback.ped)

            if not snapshot.insideVehicle then
                -- removePedFromVehicle(playback.ped)
                playback.exitVehicle = nil
            end
        else
            for _, control in ipairs(controlTable) do
                setPedControlState(playback.ped, control, table.find(snapshot.controls, control) ~= nil)
            end

            setPedWeaponSlot(playback.ped, snapshot.weaponSlot)

            if snapshot.type == 'vehicle' then
                local vehicle = getVehicleByIndex(index, snapshot.insideVehicle)
                if vehicle then
                    -- warpPedIntoVehicle(playback.ped, vehicle)
                end
            else
                if getPedOccupiedVehicle(playback.ped) then
                    -- removePedFromVehicle(playback.ped)
                end

                setElementMatrix(playback.ped, unpack(snapshot.matrix))

                if snapshot.aimTarget then
                    setPedAimTarget(playback.ped, unpack(snapshot.aimTarget))
                end

                if snapshot.animation then
                    setPedAnimation(playback.ped, snapshot.animation[1], snapshot.animation[2], unpack(snapshot.animation[3]))
                end
            end
        end
    end

    local nextFrame = playback.data.data[playback.index + 1]
    if not nextFrame then
        stopPlayback(index, true)
        return
    end

    local currentFrameTime = snapshot.tick
    local nextFrameTime = nextFrame.tick
    local timeDiff = nextFrameTime - currentFrameTime

    playback.index = playback.index + 1
    local timer = setTimer(setPlaybackNextFrame, timeDiff, 1, index)
    table.insert(playback.timers, timer)
end

local function setPlaybackVehicleNextFrame(index, vehicleIndex)
    local playback = playing[index]
    if not playback then return end

    local vehicleData = playback.vehicles[vehicleIndex]
    if not vehicleData then return end

    local snapshot = vehicleData.data[vehicleData.index]
    if not snapshot then
        -- destroyElement(vehicleData.vehicle)
        if isElementLocal(vehicleData.vehicle) then
            destroyElement(vehicleData.vehicle)
            print("Destroyed vehicle")
        end
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
    local timer = setTimer(setPlaybackVehicleNextFrame, timeDiff, 1, index, vehicleIndex)
    table.insert(playback.timers, timer)
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
    local vehicle;

    local playback = playing[index]
    if playback.ped == localPlayer then
        vehicle = getPedOccupiedVehicle(localPlayer)
    elseif getPedOccupiedVehicle(playback.ped) then
        vehicle = getPedOccupiedVehicle(playback.ped)
    else
        vehicle = createVehicle(data.model, 0, 0, 0)
    end

    setElementMatrix(vehicle, unpack(data.matrix))

    for i = 0, 6 do
        setVehiclePanelState(vehicle, i, data.panels[i + 1] or 0)
    end

    for i = 0, 5 do
        setVehicleDoorState(vehicle, i, data.doors[i + 1] or 0)
    end

    for i = 0, 3 do
        setVehicleLightState(vehicle, i, data.lights[i + 1] or 0)
    end

    setVehicleWheelStates(vehicle, unpack(data.wheels))

    for _, tuning in pairs(data.upgrades) do
        addVehicleUpgrade(vehicle, tuning)
    end

    setElementHealth(vehicle, data.health or 1000)

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
    local timer = setTimer(setPlaybackVehicleNextFrame, firstSnapshot.tick, 1, index, vehicleIndex)
    table.insert(playingData.timers, timer)
end

function startPlayback(name, defaultPed)
    local file = fileOpen("recordings/" .. name .. ".json", true)
    if not file then
        return print("Failed to open file")
    end

    local data = fromJSON(fileRead(file, fileGetSize(file)))
    fileClose(file)

    local ped = defaultPed or createPed(data.model, 0, 0, 0)
    setElementInterior(ped, getElementInterior(localPlayer))
    setElementDimension(ped, getElementDimension(localPlayer))
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
        timers = {}
    }

    local index = #playing + 1
    playing[index] = playback

    for _, vehicleData in ipairs(data.vehicles) do
        createPlaybackVehicle(index, vehicleData)
    end

    local firstSnapshot = data.data[1]
    local timer = setTimer(setPlaybackNextFrame, firstSnapshot.tick, 1, index)
    table.insert(playback.timers, timer)
    -- outputChatBox("Playback started", 0, 255, 0)
end

function stopPlaybackByName(name)
    for index, playback in pairs(playing) do
        if playback.name == name then
            stopPlayback(index)
            return
        end
    end
end

function startPlaybackCommand(cmd, name)
    if not name or #name == 0 then
        return print("Syntax: /play <name>")
    end

    -- startPlayback(name)
    for _, playback in pairs(split(name, ",")) do
        startPlayback(playback)
    end
end

addEventHandler('onClientPedsProcessed', root, updatePlaybacks)
addCommandHandler("play", startPlaybackCommand)