local currentMission = nil
missions = {}
missionData = {}
playedPlaybacks = {}

function addSpecialMissionElement(name, element)
    destroyMissionElement(name)
    missionData[name] = element

    if isElement(element) then
        setElementData(element, 'mission:element', name)
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

    for _, playback in pairs(playedPlaybacks) do
        exports['m-record']:destroyPlaybackElements(playback)
    end

    currentMission = nil
end

function startMission(id)
    if not missions[id] then return end

    stopMission()
    currentMission = id
    addSpecialMissionElement('me', localPlayer)
    
    triggerMissionEvent('onStart')
end

function getCurrentMissionData()
    if not currentMission then return end
    return missions[currentMission]
end

-- debug
-- addEventHandler('onClientResourceStart', resourceRoot, function()
--     startMission(1)
-- end)