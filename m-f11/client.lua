addEvent('interface:load', true)

addEventHandler('interface:load', root, function(name)
    if name == 'f11' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('f11', 998)
        showCursor(true)
    end
end)

function showInterface()
    exports['m-ui']:loadInterfaceElementFromFile('f11', 'm-f11/data/interface.html')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('f11')
end)