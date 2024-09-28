local sirens = {}
local horns = {}

function playVehicleSiren(veh, siren)
    sirens[veh] = sirens[veh] or {}
    sirens[veh][siren[1]] = playSound3D("data/sounds/" .. siren[1], 0, 0, 0, true)
    setSoundVolume(sirens[veh][siren[1]], siren[2])
    setSoundMinDistance(sirens[veh][siren[1]], siren[3])
    setSoundMaxDistance(sirens[veh][siren[1]], siren[4])
    attachElements(sirens[veh][siren[1]], veh)
end

addEvent("vehicle:sirens:start", true)
addEventHandler("vehicle:sirens:start", root, function(siren)
    playVehicleSiren(source, siren)
end)

addEvent("vehicle:sirens:stop", true)
addEventHandler("vehicle:sirens:stop", root, function(siren)
    if sirens[source] and sirens[source][siren[1]] and isElement(sirens[source][siren[1]]) then
        destroyElement(sirens[source][siren[1]])
        sirens[source][siren] = nil
    end
end)

-- iterate all vehicles and play the sirens
addEventHandler("onClientResourceStart", resourceRoot, function()
    for k,source in ipairs(getElementsByType("vehicle")) do
        local playingSounds = getElementData(source, "vehicle:sirens") or {}
        local sounds = getVehicleSounds(source) or {}

        for k,v in pairs(playingSounds) do
            if v then
                local data = sounds[k]
                if data then
                    playVehicleSiren(source, data)
                end
            end
        end
    end
end)

local function switchSiren(veh, key)
    local sounds = getVehicleSounds(veh)
    if not sounds then return end
    local sound = sounds[key]
    if not sound then return end

    local playingSounds = getElementData(veh, "vehicle:sirens") or {}
    for k,v in pairs(sirens[veh] or {}) do
        if tonumber(k) ~= tonumber(key) then
            triggerEvent("vehicle:sirens:stop", veh, {k})
            if playingSounds[k] then
                playingSounds[k] = false
            end
        end
    end

    playingSounds[key] = not playingSounds[key]

    if not playingSounds[key] then
        triggerServerEvent("vehicle:sirens:stop", veh, sound)
    else
        triggerServerEvent("vehicle:sirens:start", veh, sound)
        
        for k,v in pairs(playingSounds) do
            if k ~= key then
                playingSounds[k] = false
            end
        end
    end

    playSound("data/sounds/click.wav")

    setElementData(veh, "vehicle:sirens", playingSounds)
end

addEventHandler("onClientKey", root, function(key, state)
    if not state then return end
    key = tonumber(key)
    if not key then return end
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local driver = getVehicleOccupant(veh, 0)
    if driver ~= localPlayer then return end

    switchSiren(veh, key)
end)

function switchHorn(key, state)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local sounds = getVehicleSounds(veh)
    if not sounds then return end

    triggerServerEvent("vehicle:horn:" .. (state == "down" and "start" or "stop"), veh, key == "[" and 1 or 2)
end

addEvent("vehicle:horn:start", true)
addEventHandler("vehicle:horn:start", root, function(horn)
    local sounds = sirens[source] or {}
    -- make all sounds pause
    --[[for k,v in pairs(sounds) do
        if isElement(v) then
            setSoundPaused(v, true)
        end
    end]]

    if horns[source] then
        destroyElement(horns[source])
        horns[source] = nil
    end

    local sound = playSound3D("data/sounds/horn-" .. (horn == 1 and "G" or "F") .. ".mp3", 0, 0, 0, true)
    setSoundVolume(sound, 1)
    setSoundMinDistance(sound, 10)
    setSoundMaxDistance(sound, 50)
    attachElements(sound, source)
    horns[source] = sound
end)

addEvent("vehicle:horn:stop", true)
addEventHandler("vehicle:horn:stop", root, function()
    -- unpause all sounds
    --[[local sounds = sirens[source] or {}
    for k,v in pairs(sounds) do
        if isElement(v) then
            setSoundPaused(v, false)
        end
    end]]

    -- stop horn
    if horns[source] then
        destroyElement(horns[source])
        horns[source] = nil
    end
end)

addEvent("vehicle:siren-pause:start", true)
addEventHandler("vehicle:siren-pause:start", root, function()
    local sounds = sirens[source] or {}
    -- make all sounds pause
    for k,v in pairs(sounds) do
        if isElement(v) then
            setSoundPaused(v, true)
        end
    end
end)

addEvent("vehicle:siren-pause:stop", true)
addEventHandler("vehicle:siren-pause:stop", root, function()
    local sounds = sirens[source] or {}
    for k,v in pairs(sounds) do
        if isElement(v) then
            setSoundPaused(v, false)
        end
    end
end)

bindKey("[", "both", switchHorn)
bindKey("]", "both", switchHorn)

bindKey("-", "both", function(key, state)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local sounds = getVehicleSounds(veh)
    if not sounds then return end

    triggerServerEvent("vehicle:siren-pause:" .. (state == "down" and "start" or "stop"), veh)
end)