local adminLogsLoaded = false

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)
addEvent('logs:addLog', true)
addEvent('logs:iconClick', true)
addEvent('admin:toggleLogs', true)

addEventHandler('interface:load', root, function(name)
    if name == 'admin-logs' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('admin-logs', 2000)
        adminLogsLoaded = true
    end
end)

function showAdminlogsInterface()
    exports['m-ui']:loadInterfaceElementFromFile('admin-logs', 'm-admins/data/logs.html')
end

function isAdminlogsVisible()
    return adminLogsData.visible
end

function setAdminlogsVisible(visible)
    if not adminLogsLoaded and visible then
        showAdminlogsInterface()
    else
        -- if not visible then
        --     exports['m-ui']:destroyInterfaceElement('admin-logs')
        --     adminLogsLoaded = false
        -- else
        --     exports['m-ui']:setInterfaceVisible('admin-logs', true)
        -- end
        
        exports['m-ui']:setInterfaceVisible('admin-logs', visible)
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    if doesPlayerHavePermission(localPlayer, 'logs') then
        showAdminlogsInterface()
    end

    addEventHandler('interfaceLoaded', root, function()
        adminLogsLoaded = false
        setAdminlogsVisible(adminLogsData.visible, adminLogsData.text, adminLogsData.time)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('admin-logs')
end)

function addLog(category, message, icons)
    exports['m-ui']:setInterfaceData('admin-logs', 'addLog', {
        category = category,
        message = message,
        icons = icons,
    })
end

addEventHandler('admin:toggleLogs', resourceRoot, function()
    local rank = getElementData(localPlayer, 'player:rank')
    setAdminlogsVisible(rank and rank > 0)
end)

addEventHandler('logs:addLog', resourceRoot, addLog)
addEventHandler('logs:iconClick', root, function(icon, ...)
    if icon == 'teleport-uid' then
        if not doesPlayerHavePermission(localPlayer, 'command:teleport') then
            exports['m-notis']:addNotification('error', 'Błąd', 'Nie posiadasz uprawnień')
            return
        end
    
        local foundPlayer = exports['m-core']:getPlayerByUid(...)
        if not foundPlayer then
            exports['m-notis']:addNotification('error', 'Błąd', 'Nie znaleziono gracza')
            return
        end
    
        local x, y, z = getElementPosition(foundPlayer)
        setElementPosition(localPlayer, x, y + 0.5, z)
        exports['m-notis']:addNotification('success', 'Teleportacja', ('Teleportowano do gracza %s'):format(getPlayerName(foundPlayer)))
    end
end)