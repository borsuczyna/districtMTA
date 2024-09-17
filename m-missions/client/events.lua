local events = {}

function defineMissionEvent(data)
    events[data.name] = data
end

function getEvents()
    return events
end

function getEvent(name)
    return events[name]
end

function triggerMissionEvent(event, ...)
    local data = getCurrentMissionData()
    if not data then return end

    for i, v in ipairs(data) do
        if v.name == event then
            v.callback(getActions(), ...)
        end
    end
end