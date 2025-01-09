addEvent('interface:load', true)

addEventHandler('interface:load', root, function(name)
    if name == 'maps' then
        exports['m-ui']:setInterfaceVisible(name, true)
    end
end)

function showInterface()
    exports['m-ui']:loadInterfaceElementFromFile('maps', 'm-maps/data/interface.html')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('maps')
end)