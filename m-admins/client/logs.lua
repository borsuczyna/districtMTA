addEvent('interface:load', true)
addEvent('logs:addLog', true)

addEventHandler('interface:load', root, function(name)
    if name == 'admin-logs' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('admin-logs', 996)
    end
end)

function showInterface()
    exports['m-ui']:loadInterfaceElementFromFile('admin-logs', 'm-admins/data/logs.html')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('admin-logs')
end)

function addLog()
end

addEventHandler('logs:addLog', resourceRoot, addLog)