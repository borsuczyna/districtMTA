addEvent('missions:saveMission', true)
addEvent('missions:testMission', true)
addEvent('missions:loadMission', true)
addEvent('missions:loadTestMission', true)

allowedMissionVehicles = {}
allowedMissionPeds = {}

local function doesContainLuaSpecialChars(str)
    return str:find('[^%w_]')
end

local function formatValue(value, toCode)
    return toCode and toCode(value) or value
end

local function generateActionPromise(actionData, action)
    return actionData.promise.toCode(action.arguments)
end

local function generateAction(action, tabs)
    local actionData = getAction(action.name).data
    local tabsCode = ('\t'):rep(tabs)

    -- Arguments generation
    local arguments = action.arguments or {}
    local actionArguments = {}

    -- Special ID argument
    if actionData.specialId then
        table.insert(actionArguments, ('%q'):format(arguments['-1'] or ''))
    end

    -- Normal arguments
    for i = 1, #actionData.arguments do
        local defaultValue = actionData.arguments[i].default
        -- local value = arguments[tostring(i)] or defaultValue
        local value = arguments[tostring(i)]
        if value == nil then
            value = defaultValue or ''
        end
        value = formatValue(value, actionData.arguments[i].toCode)

        table.insert(actionArguments, ('%s'):format(value))
    end

    -- Code generation
    if actionData.codeGeneration then
        local realArguments = {loadstring('return ' .. table.concat(actionArguments, ', '))()}
        local generationValue = actionData.codeGeneration(unpack(realArguments))
        if generationValue then
            table.insert(actionArguments, generationValue)
        end
    end

    local actionCode = ('%scontext:%s(%s)'):format(tabsCode, actionData.name, table.concat(actionArguments, ', '))

    -- Promise
    if action.promise and actionData.promise then
        actionCode = actionCode .. '\n' .. ('%sawait(%s)'):format(tabsCode, generateActionPromise(actionData, action))
    end

    return actionCode
end

local function generateEvent(event)
    local specialChars = doesContainLuaSpecialChars(event.name)
    local eventName = specialChars and ('[%q]'):format(event.name) or event.name
    local eventData = getEvent(event.name)

    -- Arguments generation
    local arguments = {}

    for i = 1, #eventData.arguments do
        local defaultValue = eventData.arguments[i].default
        local value = (event.arguments or {})[tostring(i)] or defaultValue or ''
        table.insert(arguments, value)
    end

    local eventGenerateData = eventData.generate and eventData.generate(unpack(arguments)) or {
        arguments = {},
        header = nil,
        footer = nil,
        tabs = 0,
    }
    
    -- Read event arguments
    local eventArguments = #eventGenerateData.arguments > 0 and (', %s'):format(table.concat(eventGenerateData.arguments, ', ')) or ''

    -- Generate event header
    local eventCode = ('\t{\n\t\tname = %q,\n\t\tcallback = async(function(context%s)\n'):format(eventName, eventArguments)
    if eventGenerateData.header then
        eventCode = ('%s\t\t\t%s\n'):format(eventCode, eventGenerateData.header)
    end

    -- Generate event actions
    for _, action in pairs(event.actions or {}) do
        eventCode = eventCode .. generateAction(action, eventGenerateData.tabs + 3) .. '\n'
    end

    -- Generate event footer
    if eventGenerateData.footer then
        eventCode = ('%s\t\t\t%s\n'):format(eventCode, eventGenerateData.footer)
    end

    eventCode = eventCode .. '\t\tend),\n\t},'

    return eventCode
end

local function generateAllowedVehicles()
    local code = '\tallowedVehicles = {\n'
    
    for index, vehicle in ipairs(allowedMissionVehicles) do
        code = code .. ('\t\t[%d] = %s,\n'):format(index, inspect(vehicle):gsub('\n', ''):gsub('\t', ''))
    end

    code = code .. '\t},'
    return code
end

local function generateAllowedPeds()
    local code = '\tallowedPeds = {\n'
    
    for index, ped in ipairs(allowedMissionPeds) do
        code = code .. ('\t\t[%d] = %s,\n'):format(index, inspect(ped):gsub('\n', ''):gsub('\t', ''))
    end

    code = code .. '\t},'
    return code
end

local function generateMission(data)
    allowedMissionVehicles = {}
    allowedMissionPeds = {}
    local missionCode = ''
    local missionName = data.name
    local missionData = data.data

    -- Generate mission header
    missionCode = missionCode .. ('missions["%s"] = {\n'):format(missionName)
    
    -- Generate events
    for _, event in pairs(missionData.events) do
        missionCode = missionCode .. generateEvent(event) .. '\n\n'
    end

    -- Generate allowed elements
    missionCode = missionCode .. generateAllowedVehicles() .. '\n'
    missionCode = missionCode .. generateAllowedPeds() .. '\n'

    -- Trim the last two newlines
    missionCode = missionCode:sub(1, -3)

    -- Generate mission footer
    missionCode = missionCode .. '\n}'

    return missionCode
end

addEventHandler('missions:saveMission', root, function(dataString)
    local data = fromJSON(dataString)
    if not data then return end

    local missionCode = generateMission(data)
    triggerLatentServerEvent('missions:saveMission', resourceRoot, data.name, missionCode, dataString)

    -- save dataString to missions folder
    local path = ('missions/%s.json'):format(data.name)
    if fileExists(path) then
        fileDelete(path)
    end

    local file = fileCreate(path)
    fileWrite(file, dataString)
    fileClose(file)
    exports['m-notis']:addNotification('info', 'Edytor misji', 'Pomyślnie zapisano misję')
end)

addEventHandler('missions:testMission', root, function(dataString)
    local data = fromJSON(dataString)
    if not data then return end

    local missionData = {
        name = '__temp_test_mission',
        data = data,
    }

    local missionCode = generateMission(missionData)
    loadstring(missionCode)()
    triggerServerEvent('missions:setTestMission', resourceRoot, missions['__temp_test_mission'])
end)

addEventHandler('missions:loadMission', root, function(missionName)
    local path = ('missions/%s.json'):format(missionName)
    if not fileExists(path) then
        exports['m-notis']:addNotification('error', 'Edytor misji', 'Nie znaleziono pliku misji o podanej nazwie.')
        return
    end

    local file = fileOpen(path)
    local dataString = fileRead(file, fileGetSize(file))
    fileClose(file)

    exports['m-ui']:triggerInterfaceEvent('missionEditor', 'loadMission', fromJSON(dataString).data)
    exports['m-notis']:addNotification('info', 'Edytor misji', 'Pomyślnie załadowano misję')
end)

addEventHandler('missions:loadTestMission', resourceRoot, function()
    startMission('__temp_test_mission')
    exports['m-notis']:addNotification('info', 'Edytor misji', 'Pomyślnie uruchomiono testową misję')
end)