addEvent('interface:load', true)
addEvent('intro:setKnownIntros', true)

addEventHandler('interface:load', root, function(name)
    if name == 'intro' then
        triggerServerEvent('intro:fetchKnownIntros', resourceRoot)
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('intro', 999)
    end
end)

function showInterface()
    triggerServerEvent('intro:fetchKnownIntros', resourceRoot)
    exports['m-ui']:loadInterfaceElementFromFile('intro', 'm-intro/data/interface.html')
end

function hideIntro(id)
    exports['m-ui']:triggerInterfaceEvent('intro', 'hide', id)
end

addEventHandler('intro:setKnownIntros', root, function(intros)
    exports['m-ui']:setInterfaceData('intro', 'knownIntros', intros)
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('intro')
end)