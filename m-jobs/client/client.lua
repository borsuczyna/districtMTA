jobGui = false
local jobsLoaded, jobsVisible, jobsTimer = false, false, false
local waitingUids = {}

addEvent('interface:includes-finish', true)
addEvent('interfaceLoaded', true)
addEvent('jobs:getPlayerJobDataResult', true)
addEvent('avatars:onPlayerAvatarChange', true)
addEvent('jobs:buyUpgrade', true)
addEvent('jobs:buyUpgradeResult', true)
addEvent('jobs:getPlayerIncomeHistoryResult', true)
addEvent('jobs:jobStarted', true)
addEvent('jobs:startJob', true)
addEvent('jobs:endJobI', true)
addEvent('jobs:endJob', true)

function updateJobsData()
    local data = jobs[jobGui]
    if not data then return end

    triggerServerEvent('jobs:getPlayerJobData', resourceRoot, jobGui)

    exports['m-ui']:setInterfaceData('jobs', 'job-details', data)
    exports['m-ui']:setInterfaceData('jobs', 'in-job', {
        current = getElementData(localPlayer, 'player:job'),
        job = jobGui
    })
end

addEventHandler('interface:includes-finish', root, function(name)
    if name == 'jobs' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('jobs', 995)
        exports['m-ui']:triggerInterfaceEvent('jobs', 'play-animation', true)
        jobsLoaded = true
        updateJobsData()
    end
end)

function showJobsInterface()
    exports['m-ui']:loadInterfaceElementFromFile('jobs', 'm-jobs/data/interface.html')
end

function setJobsVisible(visible)
    if visible and exports['m-ui']:isAnySingleInterfaceVisible() then return end
    exports['m-ui']:addSingleInterface('jobs')

    if jobsHideTimer and isTimer(jobsHideTimer) then
        killTimer(jobsHideTimer)
    end

    jobsVisible = visible

    if not visible and isTimer(jobsTimer) then
        killTimer(jobsTimer)
    end

    showCursor(visible, false)

    if not jobsLoaded and visible then
        showJobsInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('jobs', 'play-animation', false)
            jobsHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('jobs')
                jobsLoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('jobs', true)
            exports['m-ui']:triggerInterfaceEvent('jobs', 'play-animation', true)
            jobsVisible = true
        end
    end
end

function showJobGui(jobName)
    if not jobs[jobName] then return end
    if jobsVisible then return end

    setJobsVisible(true)
    jobGui = jobName
end

function toggleJobs()
    if not getElementData(localPlayer, 'player:spawn') then return end

    if not jobsVisible then
        showJobGui('burger')
    else
        setJobsVisible(false)
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('f2', 'down', toggleJobs)

    addEventHandler('interfaceLoaded', root, function()
        jobsLoaded = false
        setJobsVisible(jobsVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('jobs')
end)

function updateAvatar(uid, avatar)
    if not jobsVisible then return end
    exports['m-ui']:executeJavascript(string.format('jobs_setAvatar(%d, %q)', uid, avatar or ''))
end

function updateAvatars(ids)
    for i, uid in ipairs(ids) do
        local avatar = exports['m-avatars']:getPlayerAvatarByUid(uid)
        updateAvatar(uid, avatar)
    end
end

addEventHandler('avatars:onPlayerAvatarChange', root, function(uid, avatar)
    if not table.find(waitingUids, uid) then return end
    updateAvatar(uid, avatar)
end)

addEventHandler('jobs:getPlayerJobDataResult', resourceRoot, function(data)
    if not data then return end
    if data.job ~= jobGui then return end

    local topPlayers = split(data.topPlayers or '', ';')
    local topPlayersIds = {}
    for i, player in ipairs(topPlayers) do
        local id = tonumber(split(player, ' ')[1])
        table.insert(topPlayersIds, id)
    end

    waitingUids = topPlayersIds
    data.upgrades = jobs[data.job].upgrades

    exports['m-ui']:setInterfaceData('jobs', 'job-player-data', data)
    updateAvatars(topPlayersIds)
end)

addEventHandler('jobs:buyUpgrade', root, function(id)
    if not jobGui then return end

    triggerServerEvent('jobs:buyUpgrade', resourceRoot, jobGui, id)
end)

addEventHandler('jobs:buyUpgradeResult', resourceRoot, function(job, upgrade, cost)
    if job ~= jobGui then return end

    exports['m-ui']:triggerInterfaceEvent('jobs', 'upgrade-bought', {
        upgrade = upgrade,
        cost = cost
    })
end)

addEventHandler('jobs:getPlayerIncomeHistoryResult', resourceRoot, function(data)
    if not data then return end
    if data.job ~= jobGui then return end

    exports['m-ui']:setInterfaceData('jobs', 'job-income-history', data)
end)

addEventHandler('jobs:jobStarted', resourceRoot, function(success, players)
    if not jobGui then return end

    exports['m-ui']:triggerInterfaceEvent('jobs', 'job-started', success)

    if success then
        setJobsVisible(false)
        triggerEvent('jobs:startJob', root, jobGui, players)
    end
end)

addEventHandler('jobs:endJobI', root, function()
    if not jobGui then return end

    triggerServerEvent('jobs:endJobI', resourceRoot)
end)

addEventHandler('jobs:endJob', root, function()
    if not jobGui then return end

    exports['m-ui']:triggerInterfaceEvent('jobs', 'job-ended')
end)