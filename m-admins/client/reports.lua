local adminReportsLoaded = false

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)
addEvent('reports:addReport', true)
addEvent('reports:addReports', true)
addEvent('reports:rejectReport', true)
addEvent('reports:acceptReport', true)
addEvent('reports:iconClick', true)
addEvent('admin:toggleReports', true)

addEventHandler('interface:load', root, function(name)
    if name == 'admin-reports' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('admin-reports', 2000)
        adminReportsLoaded = true
        triggerServerEvent('reports:requestReportsList', resourceRoot)
    end
end)

function showAdminReportsInterface()
    exports['m-ui']:loadInterfaceElementFromFile('admin-reports', 'm-admins/data/reports.html')
    adminReportsLoaded = true
end

function isAdminReportsVisible()
    return adminReportsLoaded
end

function setAdminReportsVisible(visible)
    if not adminReportsLoaded and visible then
        showAdminReportsInterface()
    else
        if not visible then
            exports['m-ui']:destroyInterfaceElement('admin-reports')
            adminReportsLoaded = false
        else
            exports['m-ui']:setInterfaceVisible('admin-reports', true)
        end
        
        -- exports['m-ui']:setInterfaceVisible('admin-reports', visible)
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    if doesPlayerHavePermission(localPlayer, 'reports') then
        showAdminReportsInterface()
    end

    addEventHandler('interfaceLoaded', root, function()
        adminReportsLoaded = false
        setAdminReportsVisible(adminReportsLoaded)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('admin-reports')
end)

function addReport(data)
    exports['m-ui']:setInterfaceData('admin-reports', 'addReport', {
        hash = data.hash,
        reporterName = getPlayerName(data.reporter),
        reporterId = getElementData(data.reporter, 'player:id'),
        reporterUid = getElementData(data.reporter, 'player:uid'),
        targetName = getPlayerName(data.target),
        targetId = getElementData(data.target, 'player:id'),
        targetUid = getElementData(data.target, 'player:uid'),
        reason = data.reason,
    })
end

addEventHandler('admin:toggleReports', resourceRoot, function()
    local rank = getElementData(localPlayer, 'player:rank')
    setAdminReportsVisible(rank and rank > 0)
end)

addEventHandler('reports:addReport', resourceRoot, addReport)
addEventHandler('reports:iconClick', root, function(action, hash)
    if action == 'acceptReport' then
        triggerServerEvent('reports:doReportAction', resourceRoot, hash, 'accept')
    elseif action == 'rejectReport' then
        triggerServerEvent('reports:doReportAction', resourceRoot, hash, 'reject')
        exports['m-ui']:setInterfaceData('admin-reports', 'rejectReport', { hash = hash })
    elseif action == 'teleportTo' then
        if not doesPlayerHavePermission(localPlayer, 'command:teleport') then
            exports['m-notis']:addNotification('error', 'Błąd', 'Nie posiadasz uprawnień')
            return
        end
    
        local foundPlayer = exports['m-core']:getPlayerByUid(hash)
        if not foundPlayer then
            exports['m-notis']:addNotification('error', 'Błąd', 'Nie znaleziono gracza')
            return
        end
    
        local x, y, z = getElementPosition(foundPlayer)
        setElementPosition(localPlayer, x, y + 0.5, z)
        exports['m-notis']:addNotification('success', 'Teleportacja', ('Teleportowano do gracza %s'):format(htmlEscape(getPlayerName(foundPlayer))))
    end
end)

addEventHandler('reports:rejectReport', resourceRoot, function(hash)
    exports['m-ui']:setInterfaceData('admin-reports', 'rejectReport', { hash = hash })
end)

addEventHandler('reports:acceptReport', resourceRoot, function(hash)
    exports['m-ui']:setInterfaceData('admin-reports', 'acceptReport', { hash = hash })
end)

addEventHandler('reports:addReports', resourceRoot, function(reports)
    for i, report in ipairs(reports) do
        addReport(report)
    end
end)

addCommandHandler('reports', function()
    if not getElementData(localPlayer, 'player:rank') then return end
    setAdminReportsVisible(not isAdminReportsVisible())
end)