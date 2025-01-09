local loadingLoaded = false
local loadingData = {visible = false, time = 0}
local loadingTimer

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)
addEvent('loading:setVisible', true)

function noChat()
    showChat(false)
end

function updateLoadingData()
    exports['m-ui']:setInterfaceData('loading', 'loading-data', loadingData)
end

addEventHandler('interface:load', root, function(name)
    if name == 'loading' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('loading', 2000)
        loadingLoaded = true

        updateLoadingData()
    end
end)

function showLoadingInterface()
    exports['m-ui']:loadInterfaceElementFromFile('loading', 'm-loading/data/interface.html')
end

function setLoadingText(text)
    loadingData.text = text
    updateLoadingData()
end

function setLoadingProgress(progress, time)
    loadingData.progress = progress
    loadingData.time = time or 0
    updateLoadingData()
end

function isLoadingVisible()
    return loadingData.visible
end

function setLoadingVisible(visible, text, time)
    if loadingTimer and isTimer(loadingTimer) then
        killTimer(loadingTimer)
    end

    _G[visible and 'addEventHandler' or 'removeEventHandler']('onClientRender', root, noChat)
    showCursor(visible)
    showChat(not visible)
    loadingData = {visible = visible, text = text or loadingData.text, time = time or 0}

    if not loadingLoaded and visible then
        showLoadingInterface()
    else
        if not visible then
            exports['m-ui']:setInterfaceData('loading', 'loading-hide', true)
            loadingTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('loading')
                loadingLoaded = false
            end, 1000, 1)
        else
            exports['m-ui']:setInterfaceVisible('loading', true)
        end
    end

    if time and time > 0 then
        loadingTimer = setTimer(setLoadingVisible, time, 1, false)
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    setPlayerHudComponentVisible('all', false)
    setPlayerHudComponentVisible('crosshair', true)

    addEventHandler('interfaceLoaded', root, function()
        loadingLoaded = false
        setLoadingVisible(loadingData.visible, loadingData.text, loadingData.time)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('loading')
end)

addEventHandler('loading:setVisible', resourceRoot, function(visible, text, time)
    setLoadingVisible(visible, text, time)
end)