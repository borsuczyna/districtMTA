local loadingLoaded = false
local loadingVisible = false

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)

addEventHandler('interface:load', root, function(name)
    if name == 'loading' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('loading', 2000)
        loadingLoaded = true
    end
end)

function showLoadingInterface()
    exports['m-ui']:loadInterfaceElementFromFile('loading', 'm-loading/data/interface.html')
end

function setLoadingVisible(visible)
    loadingVisible = visible

    if not loadingLoaded and visible then
        showLoadingInterface()
    else
        if not visible then
            exports['m-ui']:destroyInterfaceElement('loading')
            loadingLoaded = false
        else
            exports['m-ui']:setInterfaceVisible('loading', true)
        end
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    setLoadingVisible(true)

    addEventHandler('interfaceLoaded', root, function()
        loadingLoaded = false
        setLoadingVisible(loadingVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('loading')
end)