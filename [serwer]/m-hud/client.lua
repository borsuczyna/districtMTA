local hudLoaded = false
local hudVisible = false
local lastSentData = {}
local nextLevelExpCache = {}
local jobTimer = false
local jobNames = {}

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)
addEvent('avatars:onPlayerAvatarChange', true)

local function getJobName(key)
    if jobNames[key] then
        return jobNames[key]
    end

    local job = exports['m-jobs']:getJobName(key)
    jobNames[key] = job

    return job
end

function updateJobData()
    local jobData = false

    local job = getElementData(localPlayer, 'player:job')
    if job then
        local jobStart = getElementData(localPlayer, 'player:job-start')
        local coop = getElementData(localPlayer, 'player:job-players')
        local coopPlayers = false
        if #coop > 1 then
            coopPlayers = {}
            for k,v in ipairs(coop) do
                table.insert(coopPlayers, getPlayerName(v))
            end
        end

        jobData = {
            name = getJobName(job),
            workedTime = jobStart and (getRealTime().timestamp - jobStart) or 0,
            earned = getElementData(localPlayer, 'player:job-earned') or 0,
            coop = coopPlayers,
            endJob = getElementData(localPlayer, 'player:job-end'),
        }
    end

    exports['m-ui']:setInterfaceData('hud', 'hud:job', jobData)
end

function updateHud(avatar)
    if not hudVisible then return end

    setPlayerHudComponentVisible('all', false)
    setPlayerHudComponentVisible('crosshair', true)

    local level = getElementData(localPlayer, 'player:level') or 1
    local nextLevelExp = nextLevelExpCache[level]
    if not nextLevelExp then
        nextLevelExp = exports['m-core']:getNextLevelExp(level)
        nextLevelExpCache[level] = nextLevelExp
    end

    local data = {
        nickname = getPlayerName(localPlayer),
        health = getElementHealth(localPlayer),
        money = getPlayerMoney(localPlayer),
        level = level,
        exp = (getElementData(localPlayer, 'player:exp') or 0) / nextLevelExp * 100,
        wantedStars = getPlayerWantedLevel(localPlayer),
    }

    local anythingChanged = false
    for key, value in pairs(data) do
        if lastSentData[key] ~= value then
            anythingChanged = true
            break
        end
    end

    if not anythingChanged then return end

    lastSentData = data
    exports['m-ui']:setInterfaceData('hud', 'hud:data', data)
end

function updateAvatar(avatar)
    exports['m-ui']:executeJavascript(string.format('hud_setAvatar(%q)', avatar or ''))
end

addEventHandler('avatars:onPlayerAvatarChange', root, function(player, avatar)
    if player ~= localPlayer or not hudLoaded or not hudVisible then return end
    updateAvatar(avatar)
end)

addEventHandler('interface:load', root, function(name)
    if name == 'hud' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('hud', 997)
        lastSentData = {}
        addEventHandler('onClientRender', root, updateHud)
        jobTimer = setTimer(updateJobData, 1000, 0)
        updateHud()
        hudLoaded = true

        local avatar = exports['m-avatars']:getPlayerAvatar(localPlayer)
        updateAvatar(avatar)
    end
end)

function showHudInterface()
    exports['m-ui']:loadInterfaceElementFromFile('hud', 'm-hud/data/interface/hud.html')
    setBlurLevel(0)
end

function setHudVisible(visible)
    hudVisible = visible

    if not hudLoaded and visible then
        showHudInterface()
    else
        if not visible then
            exports['m-ui']:destroyInterfaceElement('hud')
            removeEventHandler('onClientRender', root, updateHud)
            if isTimer(jobTimer) then
                killTimer(jobTimer)
            end
            hudLoaded = false
        else
            exports['m-ui']:setInterfaceVisible('hud', true)
        end
    end
end

addEventHandler('onClientElementDataChange', root, function(key)
    if key == 'player:hiddenHUD' then
        setHudVisible(not getElementData(localPlayer, 'player:hiddenHUD'))
    end 
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
    if getElementData(localPlayer, 'player:spawn') then
        setHudVisible(true)
    end

    addEventHandler('interfaceLoaded', root, function()
        hudLoaded = false
        lastSentData = {}
        setHudVisible(hudVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('hud')
end)