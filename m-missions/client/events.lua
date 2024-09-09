local events = {}

function defineMissionEvent(data)
    events[data.name] = data
end

function getEvents()
    return events
end

function triggerMissionEvent(event, ...)
    local data = getCurrentMissionData()
    if not data then return end

    if data[event] then
        data[event](getActions(), ...)
    end
end