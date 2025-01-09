local dashboardLoaded, dashboardVisible, dashboardTimer = false, false, false

addEvent('interface:includes-finish', true)
addEvent('interfaceLoaded', true)
addEvent('dashboard:setSetting', true)
addEvent('dashboard:fetchData', true)
addEvent('dashboard:fetchDataResult', true)
addEvent('dashboard:vehicleDetails', true)
addEvent('dashboard:vehicleDetailsResult', true)
addEvent('dashboard:fetchDailyRewardResult', true)
addEvent('dashboard:getPlayerLast10DailyRewardsResult', true)
addEvent('dashboard:getPlayerLast10DaysDailyTasksResult', true)
-- addEvent('dashboard:claimDailyTask', true)
-- addEvent('dashboard:redeemTaskResult', true)
addEvent('dashboard:updateAchievements', true)
addEvent('dashboard:fetchDailyReward', true)
addEvent('dashboard:boughtSeasonPass', true)
addEvent('avatars:onPlayerAvatarChange', true)

function updateDashboardData()
    local settings = {
        ['status-rp'] = {
            value = getElementData(localPlayer, 'player:statusRP')
        },
        ['block-dms'] = {
            value = getElementData(localPlayer, 'player:blockedDMs'),
            input = getElementData(localPlayer, 'player:blockedDMsReason') or ''
        },
        ['hide-hud'] = {
            value = getElementData(localPlayer, 'player:hiddenHUD')
        },
        ['hide-nametags'] = {
            value = getElementData(localPlayer, 'player:hiddenNametags')
        },
        ['block-premium-chat'] = {
            value = getElementData(localPlayer, 'player:blockedPremiumChat')
        },
        ['interface-blur'] = {
            value = getElementData(localPlayer, 'player:interfaceBlur')
        },
        ['interface-size'] = {
            value = getElementData(localPlayer, 'player:interfaceSize')
        },
        -- ['controller-mode'] = {
        --     value = getElementData(localPlayer, 'player:controllerMode')
        -- }
    }

    local level = getElementData(localPlayer, 'player:level') or 1
    local exp = getElementData(localPlayer, 'player:exp')
    local expToNext = exports['m-core']:getNextLevelExp(level)
    local x, y, z = getElementPosition(localPlayer)
    local dailyRewardDay = exports['m-core']:getPlayerDailyRewardDay()
    local dailyRewardRedeem, dailyRewardTimeLeft = exports['m-core']:canPlayerRedeemDailyReward()
    local avatar = exports['m-avatars']:getPlayerAvatar(localPlayer)
    updateAvatar(avatar)

    -- triggerServerEvent('dashboard:fetchData', resourceRoot, 'account')
    triggerServerEvent('dashboard:fetchDailyReward', resourceRoot)

    exports['m-ui']:triggerInterfaceEvent('dashboard', 'update-data', {
        settings = settings,
        level = level,
        levelProgress = exp / expToNext * 100,
        playerPosition = {x, y, z},
        dailyRewardDay = dailyRewardDay,
        dailyRewardRedeem = dailyRewardRedeem,
    })
end

function updateAvatar(avatar)
    exports['m-ui']:executeJavascript(string.format('dashboard_setAvatar(%q)', avatar or ''))
end

addEventHandler('avatars:onPlayerAvatarChange', root, function(player, avatar)
    if player ~= localPlayer or not dashboardLoaded or not dashboardVisible then return end
    updateAvatar(avatar)
end)

addEventHandler('interface:includes-finish', root, function(name)
    if name == 'dashboard' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('dashboard', 998)
        exports['m-ui']:triggerInterfaceEvent('dashboard', 'play-animation', true)
        dashboardLoaded = true
        updateDashboardData()
    end
end)

function showDashboardInterface()
    exports['m-ui']:loadInterfaceElementFromFile('dashboard', 'm-dashboard/data/interface.html')
end

function setDashboardVisible(visible)
    if visible and exports['m-ui']:isAnySingleInterfaceVisible() then return end
    exports['m-ui']:addSingleInterface('dashboard')

    if not visible and not dashboardLoaded then return end

    if dashboardHideTimer and isTimer(dashboardHideTimer) then
        killTimer(dashboardHideTimer)
    end

    dashboardVisible = visible

    if not visible and isTimer(dashboardTimer) then
        killTimer(dashboardTimer)
    end

    showCursor(visible)
    showChat(not visible)

    if not dashboardLoaded and visible then
        showDashboardInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('dashboard', 'play-animation', false)
            dashboardHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('dashboard')
                dashboardLoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('dashboard', true)
            exports['m-ui']:triggerInterfaceEvent('dashboard', 'play-animation', true)
            dashboardVisible = true
        end
    end
end

function toggleDashboard()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setDashboardVisible(not dashboardVisible)
end

function controllerButtonPressed(button)
    if (button == 10) or (button == 2 and dashboardVisible) then
        toggleDashboard()
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('f5', 'down', toggleDashboard)
    addEventHandler('controller:buttonPressed', root, controllerButtonPressed)

    addEventHandler('interfaceLoaded', root, function()
        dashboardLoaded = false
        setDashboardVisible(dashboardVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('dashboard')
end)

addEventHandler('dashboard:setSetting', root, function(setting, value, input)
    local boolValue = tonumber(value) == 1
    
    if setting == 'status-rp' then
        setElementData(localPlayer, 'player:statusRP', boolValue)
    elseif setting == 'block-dms' then
        setElementData(localPlayer, 'player:blockedDMs', boolValue)
        setElementData(localPlayer, 'player:blockedDMsReason', #input > 0 and input or nil)
    elseif setting == 'hide-hud' then
        setElementData(localPlayer, 'player:hiddenHUD', boolValue)
    elseif setting == 'hide-nametags' then
        setElementData(localPlayer, 'player:hiddenNametags', boolValue)
    elseif setting == 'block-premium-chat' then
        setElementData(localPlayer, 'player:blockedPremiumChat', boolValue)
    elseif setting == 'interface-blur' then
        setElementData(localPlayer, 'player:interfaceBlur', value)
        exports['m-ui']:setBlurQuality(value)
    elseif setting == 'interface-size' then
        setElementData(localPlayer, 'player:interfaceSize', value)
    elseif setting == 'controller-mode' then
        setElementData(localPlayer, 'player:controllerMode', boolValue)
    end
end)

addEventHandler('dashboard:fetchData', root, function(data)
    triggerServerEvent('dashboard:fetchData', resourceRoot, data)
end)

addEventHandler('dashboard:fetchDataResult', root, function(data, result)
    exports['m-ui']:triggerInterfaceEvent('dashboard', 'fetch-data-result', {
        data = data,
        result = result
    })
end)

addEventHandler('dashboard:vehicleDetails', root, function(id)
    triggerServerEvent('dashboard:vehicleDetails', resourceRoot, id)
end)

addEventHandler('dashboard:vehicleDetailsResult', root, function(id, result)
    exports['m-ui']:triggerInterfaceEvent('dashboard', 'vehicle-details-result', {
        id = id,
        result = result
    })
end)

addEventHandler('dashboard:fetchDailyReward', root, function()
    triggerServerEvent('dashboard:fetchDailyReward', resourceRoot)
end)

addEventHandler('dashboard:fetchDailyRewardResult', root, function(yesterday, today)
    exports['m-ui']:triggerInterfaceEvent('dashboard', 'fetch-daily-reward-result', {
        yesterday = yesterday,
        today = today,
    })
end)

addEventHandler('dashboard:getPlayerLast10DailyRewardsResult', root, function(rewards)
    exports['m-ui']:triggerInterfaceEvent('dashboard', 'get-player-last-10-daily-rewards-result', rewards)
end)

addEventHandler('dashboard:getPlayerLast10DaysDailyTasksResult', root, function(tasks)
    exports['m-ui']:triggerInterfaceEvent('dashboard', 'get-player-last-10-daily-tasks-result', tasks)
end)

addEventHandler('dashboard:updateAchievements', root, function(data)
    exports['m-ui']:triggerInterfaceEvent('dashboard', 'update-achievements', data)
end)

addEventHandler('dashboard:boughtSeasonPass', root, function()
    exports['m-ui']:triggerInterfaceEvent('dashboard', 'bought-season-pass')
end)