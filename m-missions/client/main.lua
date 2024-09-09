local currentMission = nil
missions = {}
missionData = {}

function addSpecialMissionElement(name, element)
    destroyMissionElement(name)
    missionData[name] = element

    if isElement(element) then
        setElementData(element, 'mission:element', name)
    end
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
end

function startMission(id)
    if not missions[id] then return end

    currentMission = id
    destroyAllMissionElements()
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