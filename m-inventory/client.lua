addEvent('interface:load', true)
addEvent('inventory:addNotification', true)

addEventHandler('interface:load', root, function(name)
    if name == 'inventory' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('inventory', 1000)
    end
end)

function showInterface()
    exports['m-ui']:loadInterfaceElementFromFile('inventory', 'm-inventory/data/interface.html')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('inventory')
end)