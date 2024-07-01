addEvent('interface:load', true)
addEvent('fingerprint:response', true)

addEventHandler('interface:load', root, function(name)
    if name == 'fingerprint' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('fingerprint', 5000)
    end
end)

function showInterface()
    exports['m-ui']:loadInterfaceElementFromFile('fingerprint', 'm-anticheat/data/fingerprint.html')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('fingerprint')
end)

addEventHandler('fingerprint:response', root, function(response)
    response = teaEncode(response, 'm-anticheat')
    triggerServerEvent('fingerprint:response', resourceRoot, response)
end)