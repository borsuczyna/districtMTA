addEvent('missions:startMission', true)

local currentMission = nil
currentMissionIndex = nil
repeatingMission = false
missions = {}
missionData = {}
missionVariables = {}
playedPlaybacks = {}

function addSpecialMissionElement(name, element)
    destroyMissionElement(name)
    missionData[name] = element

    if isElement(element) then
        setElementData(element, 'mission:element', name, false)
    end

    if element ~= localPlayer then
        setElementDimension(element, getElementDimension(localPlayer))
        setElementInterior(element, getElementInterior(localPlayer))
    end
end

function getMissionElement(name)
    return missionData[name]
end

function addMissionElement(element)
    table.insert(missionData, element)
end

function destroyMissionElement(name)
    if not missionData[name] then return end

    if isElement(missionData[name]) then
        destroyElement(missionData[name])
    end
end

function destroyAllMissionElements()
    for name, element in pairs(missionData) do
        destroyMissionElement(name)
    end

    killAllPromises()
end

function stopMission()
    destroyAllMissionElements()
    clearAllVoiceLines()
    setMissionTarget('')
    resetCamera()

    triggerServerEvent('missions:destroyMissionElements', resourceRoot)
    triggerServerEvent('missions:moveOutOfMissionDimension', resourceRoot)

    for _, playback in pairs(playedPlaybacks) do
        exports['m-record']:destroyPlaybackElements(playback)
    end

    calledCustomEvents = {}
    missionVariables = {}
    currentMission = nil
    setElementData(localPlayer, 'missions:vehicleExitLocked', false)
    setElementData(localPlayer, 'missions:vehicleEnterLocked', false)
    toggleAllControls(true)
end

function startMission(id)
    if not missions[id] then return end

    stopMission()
    currentMission = id
    currentMissionIndex = getMissionIndex(id)
    
    local missionData = getMissionDataByName(id)
    -- showMissionName(missionData[2])

    repeatingMission = false
    resetCamera()
    addSpecialMissionElement('me', localPlayer)
    
    triggerMissionEvent('onStart')
end

function restartMission()
    if not currentMission then return end
    startMission(currentMission)
end

function finishMission()
    if not currentMission then return end
    stopMission()

    if repeatingMission then
        triggerServerEvent('missions:stopRepeatingMission', resourceRoot)
    end
end

function getCurrentMissionData()
    if not currentMission then return end
    return missions[currentMission]
end

function getCurrentMission()
    return currentMission
end

addEventHandler('missions:startMission', resourceRoot, function(index)
    if currentMission then
        exports['m-notis']:addNotification('error', 'Misje', 'Już wykonujesz misję.')
        return
    end

    local mission = getMissionByIndex(index)
    if not mission then return end

    startMission(mission[1])
    exports['m-notis']:addNotification('info', 'Misje', ('Rozpoczęto misję %s<br>Aby przerwać powtarzanie misji, wpisz /mstop'):format(mission[2]))
    repeatingMission = true
end)

addCommandHandler('mstop', function()
    if not repeatingMission then
        exports['m-notis']:addNotification('error', 'Misje', 'Przerwanie powtarzania misji jest możliwe tylko podczas powtarzania misji.')
        return
    end

    finishMission()
    triggerServerEvent('missions:stopRepeatingMission', resourceRoot)
    exports['m-notis']:addNotification('info', 'Misje', 'Przerwano powtarzanie misji.')
end)

-- debug
-- addEventHandler('onClientResourceStart', resourceRoot, function()
--     if getPlayerName(localPlayer) == 'borsuczyna' then
--         startMission('investigation')
--     end
-- end)