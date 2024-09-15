local recording = false
local settings = {
    vehicleSnapshotInterval = 50,
    fixedVehicleSnapshotInterval = 500,
    snapshotInterval = 50,
}

local function uploadFile(name)
    local file = fileOpen("recordings/" .. name .. ".json", true)
    if not file then
        return print("Failed to open file")
    end

    local data = fileRead(file, fileGetSize(file))
    fileClose(file)

    triggerLatentServerEvent("onClientUploadRecording", 5000, resourceRoot, name, data)
end

local function stopRecording()
    if not recording then return end

    local file = fileCreate("recordings/" .. recording.name .. ".json")
    if not file then
        return print("Failed to create file")
    end

    for _, vehicleData in ipairs(recording.vehicles) do
        vehicleData.vehicle = nil
    end

    fileWrite(file, toJSON(recording))
    fileClose(file)

    outputChatBox("Recording stopped, saved as " .. recording.name .. ".json", 0, 255, 0)
    uploadFile(recording.name)
    recording = false
end

local function createVehicleSnapshot(vehicle)
    local vehicleData = getRecordingVehicle(vehicle)
    -- local matrix = {getElementMatrix(vehicle)}
    local position = {getElementPosition(vehicle)}
    local rotation = {getElementRotation(vehicle)}
    local velocity = {getElementVelocity(vehicle)}
    local angularVelocity = {getElementAngularVelocity(vehicle)}

    local snapshot = {
        -- matrix = matrix,
        position = position,
        rotation = rotation,
        velocity = velocity,
        angularVelocity = angularVelocity,
        tick = getTickCount() - recording.tick,
    }

    table.insert(vehicleData.data, snapshot)
    outputChatBox("Vehicle snapshot created", 255, 255, 0)
end

function getRecordingVehicle(vehicle)
    for i, v in ipairs(recording.vehicles) do
        if v.vehicle == vehicle then
            return v, i
        end
    end

    local vehicleData = {
        vehicle = vehicle,
        model = getElementModel(vehicle),
        matrix = {getElementMatrix(vehicle)},
        velocity = {getElementVelocity(vehicle)},
        angularVelocity = {getElementAngularVelocity(vehicle)},
        panels = iter(0, 6, function(i)
            return getVehiclePanelState(vehicle, i)
        end),
        doors = iter(0, 5, function(i)
            return getVehicleDoorState(vehicle, i)
        end),
        lights = iter(0, 3, function(i)
            return getVehicleLightState(vehicle, i)
        end),
        wheels = {getVehicleWheelStates(vehicle)},
        upgrades = getVehicleUpgrades(vehicle),
        health = getElementHealth(vehicle),
        data = {},
    }

    table.insert(recording.vehicles, vehicleData)
    createVehicleSnapshot(vehicle)
    return getRecordingVehicle(vehicle)
end

local function createSnapshot()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    local rotation = {getElementRotation(localPlayer)}
    local aimTarget = {getPedTargetEnd(localPlayer)}
    local vehicleIndex = false

    if vehicle then
        local vehicleData, index = getRecordingVehicle(vehicle)
        vehicleIndex = index
    end

    local snapshot
    if vehicleIndex then
        snapshot = {
            controls = getPedControlStates(localPlayer),
            weaponSlot = getPedWeaponSlot(localPlayer),
            insideVehicle = vehicleIndex,
            type = "vehicle",
            tick = getTickCount() - recording.tick,
        }
    else
        local animation = {getPedAnimation(localPlayer)}
        if animation[1] == false then
            animation = false
        end

        snapshot = {
            matrix = {getElementMatrix(localPlayer)},
            controls = getPedControlStates(localPlayer),
            rotation = rotation[3],
            weaponSlot = getPedWeaponSlot(localPlayer),
            aimTarget = getPedControlState(localPlayer, "aim_weapon") and aimTarget or false,
            animation = animation,
            type = "onfoot",
            tick = getTickCount() - recording.tick,
        }
    end

    outputChatBox("Snapshot created", 0, 255, 0)
    table.insert(recording.data, snapshot)
end

local function addEnterSnapshot(player, seat)
    if player ~= localPlayer then return end
    if not recording then return end

    local vehicle = source
    local vehicleData, index = getRecordingVehicle(vehicle)
    local snapshot = {
        type = "enter",
        vehicle = index,
        seat = seat,
        tick = getTickCount() - recording.tick,
    }

    table.insert(recording.data, snapshot)
    createSnapshot()
    outputChatBox("Enter snapshot created", 0, 255, 0)
end

local function addExitSnapshot(player, seat)
    if player ~= localPlayer then return end
    if not recording then return end

    local vehicle = source
    local vehicleData, index = getRecordingVehicle(vehicle)
    local snapshot = {
        type = "exit",
        vehicle = index,
        seat = seat,
        tick = getTickCount() - recording.tick,
    }

    table.insert(recording.data, snapshot)
    createSnapshot()
    outputChatBox("Exit snapshot created", 0, 255, 0)
end

local function checkSnapshotIsNeeded()
    if not recording then return end

    local lastSnapshot = recording.data[#recording.data]
    local lastControls = lastSnapshot.controls
    local currentControls = getPedControlStates(localPlayer)
    local timeElapsed = getTickCount() - recording.tick - lastSnapshot.tick

    local controlsChanged = toJSON(lastControls) ~= toJSON(currentControls)
    
    local snapshotRequired = false
    if lastSnapshot.insideVehicle then
        snapshotRequired = controlsChanged
    else
        local lastAimTarget = lastSnapshot.aimTarget
        local currentAimTarget = getPedControlState(localPlayer, "aim_weapon") and {getPedTargetEnd(localPlayer)} or false
        local lastAnimation = lastSnapshot.animation
        local currentAnimation = {getPedAnimation(localPlayer)}
        if currentAnimation[1] == false then
            currentAnimation = false
        end
      
        local aimTargetChanged = (not lastAimTarget and currentAimTarget) or (lastAimTarget and not currentAimTarget) or Vector3Comparator(lastAimTarget, currentAimTarget)
        local weaponChanged = lastSnapshot.weaponSlot ~= getPedWeaponSlot(localPlayer)
        local rotationChanged = ('%.1f'):format(lastSnapshot.rotation) ~= ('%.1f'):format(({getElementRotation(localPlayer)})[3])
        local animationChanged = toJSON(lastAnimation) ~= toJSON(currentAnimation)

        snapshotRequired = controlsChanged or weaponChanged or (aimTargetChanged and timeElapsed > settings.snapshotInterval) or (rotationChanged and timeElapsed > settings.snapshotInterval) or animationChanged
    end

    if snapshotRequired then
        createSnapshot()
    end
end

local function checkVehicleSnapshotIsNeeded(vehicle)
    if not recording then return end

    local vehicleData, index = getRecordingVehicle(vehicle)
    local lastSnapshot = vehicleData.data[#vehicleData.data]
    local timeElapsed = getTickCount() - recording.tick - lastSnapshot.tick
    local position = {getElementPosition(vehicle)}
    local rotation = {getElementRotation(vehicle)}
    local velocity = {getElementVelocity(vehicle)}
    local angularVelocity = {getElementAngularVelocity(vehicle)}

    local positionChanged = Vector3Distance(lastSnapshot.position, position) > 0.5
    local rotationChanged = Vector3Distance(lastSnapshot.rotation, rotation) > 2
    local velocityChanged = Vector3Distance(lastSnapshot.velocity, velocity) > 0.05
    local angularVelocityChanged = Vector3Distance(lastSnapshot.angularVelocity, angularVelocity) > 0.05

    local snapshotRequired = ((positionChanged or rotationChanged or velocityChanged or angularVelocityChanged) and timeElapsed > settings.vehicleSnapshotInterval) or timeElapsed > settings.fixedVehicleSnapshotInterval
    if snapshotRequired then
        createVehicleSnapshot(vehicle)
    end
end

local function updateVehicles()
    if not recording then return end

    for _, vehicleData in ipairs(recording.vehicles) do
        checkVehicleSnapshotIsNeeded(vehicleData.vehicle)
    end
end

local function startRecording(cmd, name)
    if not name or #name == 0 then
        return print("Syntax: /record <name>")
    end

    if recording then
        stopRecording()
        return
    end

    if fileExists("recordings/" .. name .. ".json") then
        fileDelete("recordings/" .. name .. ".json")
    end

    recording = {
        name = name,
        model = getElementModel(localPlayer),
        matrix = {getElementMatrix(localPlayer)},
        tick = getTickCount(),
        weapons = getPedWeapons(localPlayer),
        data = {},
        vehicles = {},
    }

    createSnapshot()
    outputChatBox("Recording started", 0, 255, 0)
end

addEventHandler('onClientRender', root, checkSnapshotIsNeeded)
addEventHandler('onClientRender', root, updateVehicles)
addEventHandler('onClientVehicleStartEnter', root, addEnterSnapshot)
addEventHandler('onClientVehicleStartExit', root, addExitSnapshot)
addCommandHandler("record", startRecording)