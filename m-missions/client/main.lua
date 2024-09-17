local currentMission = nil
missions = {}
missionData = {}
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
    currentMission = nil
    setElementData(localPlayer, 'missions:vehicleExitLocked', false)
    setElementData(localPlayer, 'missions:vehicleEnterLocked', false)
    toggleAllControls(true)
end

function startMission(id)
    if not missions[id] then return end

    stopMission()
    currentMission = id
    resetCamera()
    addSpecialMissionElement('me', localPlayer)
    
    triggerMissionEvent('onStart')
end

function restartMission()
    if not currentMission then return end
    startMission(currentMission)
end

function getCurrentMissionData()
    if not currentMission then return end
    return missions[currentMission]
end

function getCurrentMission()
    return currentMission
end

-- debug
-- addEventHandler('onClientResourceStart', resourceRoot, function()
--     startMission('test4')
-- end)