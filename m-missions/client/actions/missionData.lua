function setMissionData(name, value)
    missionVariables[name] = value
end

function getMissionData(name)
    return missionVariables[name]
end