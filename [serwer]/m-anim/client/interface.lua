local animUILoaded, animUIVisible, animHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('anim', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'anim' then
        -- exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showAnimInterface()
    exports['m-ui']:loadInterfaceElementFromFile('anim', 'm-anim/data/interface.html')
end

function setAnimUIVisible(visible)
    if animHideTimer and isTimer(animHideTimer) then
        killTimer(animHideTimer)
    end

    animUIVisible = visible

    if not visible and isTimer(animTimer) then
        killTimer(animTimer)
    end

    -- showCursor(visible, false)
    local callback = visible and addEventHandler or removeEventHandler
    local bindCallback = visible and bindKey or unbindKey
    callback('onClientPedsProcessed', root, renderAnimationEditor)
    callback('onClientClick', root, clickAnimationEditor)
    bindCallback('c', 'down', copyAnimationBind)
    bindCallback('v', 'down', pasteAnimationBind)
    bindCallback('x', 'down', cutAnimationBind)
    toggleCamera(visible)

    if not animUILoaded and visible then
        showAnimInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('anim', 'play-animation', false)
            animHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('anim')
                animUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('anim', true)
            setInterfaceData()
            animUIVisible = true
        end
    end
end

function toggleAnimUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setAnimUIVisible(not animUIVisible)

    destroyTempElements()

    if animUIVisible then
        resetAnimationEditor()
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        animUILoaded = false
        setAnimUIVisible(animUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('anim')
end)

addCommandHandler('aeditor', toggleAnimUI)