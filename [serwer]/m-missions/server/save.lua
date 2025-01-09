addEvent('missions:getCurrentPosition', false)
addEvent('missions:getCurrentRotation', false)
addEvent('missions:saveMission', true)
addEvent('missions:setTestMission', true)

addEventHandler('missions:getCurrentPosition', root, function(hash, player)
    local vehicle = getPedOccupiedVehicle(player)
    local element = vehicle or player
    local x, y, z = getElementPosition(element)

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Ustawiono pozycję gracza', data = {x = x, y = y, z = z}})
end)

addEventHandler('missions:getCurrentRotation', root, function(hash, player)
    local vehicle = getPedOccupiedVehicle(player)
    local element = vehicle or player
    local rx, ry, rz = getElementRotation(element)

    exports['m-ui']:respondToRequest(hash, {status = 'success', message = 'Ustawiono rotację gracza', data = {rx = rx, ry = ry, rz = rz}})
end)

local function addScriptToMeta(path)
    if not fileExists(path) then return end

    local meta = xmlLoadFile('meta.xml')
    if not meta then return end

    local file = xmlCreateChild(meta, 'script')
    xmlNodeSetAttribute(file, 'src', path)
    xmlNodeSetAttribute(file, 'type', 'shared')
    xmlNodeSetAttribute(file, 'cache', 'false')
    xmlSaveFile(meta)
    xmlUnloadFile(meta)
end

local function isScriptAddedToMeta(path)
    local meta = xmlLoadFile('meta.xml')
    if not meta then return false end

    local scripts = xmlNodeGetChildren(meta)
    for i, script in ipairs(scripts) do
        if xmlNodeGetAttribute(script, 'src') == path and xmlNodeGetAttribute(script, 'type') == 'shared' then
            xmlUnloadFile(meta)
            return true
        end
    end

    xmlUnloadFile(meta)
    return false
end

addEventHandler('missions:saveMission', resourceRoot, function(name, data)
    local path = ('missions/%s.lua'):format(name)
    if fileExists(path) then
        fileDelete(path)
    end
    
    local file = fileCreate(path)
    fileWrite(file, data)
    fileClose(file)

    if isScriptAddedToMeta(path) then return end
    addScriptToMeta(path)
end)

addEventHandler('missions:setTestMission', resourceRoot, function(data)
    missions['__temp_test_mission'] = data
    triggerClientEvent(client, 'missions:loadTestMission', resourceRoot, data)
end)