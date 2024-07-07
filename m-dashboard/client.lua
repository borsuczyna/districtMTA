local dashboardLoaded, dashboardVisible, dashboardTimer = false, false, false

addEvent('interface:includes-finish', true)
addEvent('interfaceLoaded', true)
addEvent('dashboard:setSetting', true)
addEvent('dashboard:fetchData', true)
addEvent('dashboard:fetchDataResult', true)
addEvent('dashboard:vehicleDetails', true)
addEvent('dashboard:vehicleDetailsResult', true)

function updateDashboardData()
    local settings = {
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
        ['interface-size'] = {
            value = getElementData(localPlayer, 'player:interfaceSize')
        }
    }

    local level = getElementData(localPlayer, 'player:level') or 1
    local exp = getElementData(localPlayer, 'player:exp')
    local expToNext = exports['m-core']:getNextLevelExp(level)
    local x, y, z = getElementPosition(localPlayer)

    exports['m-ui']:triggerInterfaceEvent('dashboard', 'update-data', {
        settings = settings,
        level = level,
        levelProgress = exp / expToNext * 100,
        playerPosition = {x, y, z}
    })
end

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

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('f5', 'down', toggleDashboard)

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
    
    if setting == 'block-dms' then
        setElementData(localPlayer, 'player:blockedDMs', boolValue)
        setElementData(localPlayer, 'player:blockedDMsReason', #input > 0 and input or nil)
    elseif setting == 'hide-hud' then
        setElementData(localPlayer, 'player:hiddenHUD', boolValue)
    elseif setting == 'hide-nametags' then
        setElementData(localPlayer, 'player:hiddenNametags', boolValue)
    elseif setting == 'block-premium-chat' then
        setElementData(localPlayer, 'player:blockedPremiumChat', boolValue)
    elseif setting == 'interface-size' then
        setElementData(localPlayer, 'player:interfaceSize', value)
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