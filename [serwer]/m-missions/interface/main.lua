addEvent('interface:includes-finish', true)

local missionEditorUILoaded, missionEditorUIVisible, missionEditorHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('missionEditor', 'play-animation', true)
    exports['m-ui']:setInterfaceData('missionEditor', 'events', getEvents())
    exports['m-ui']:setInterfaceData('missionEditor', 'actions', getActions())
end

addEventHandler('interface:includes-finish', root, function(name)
    if name == 'missionEditor' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showMissionEditorInterface()
    exports['m-ui']:loadInterfaceElementFromFile('missionEditor', 'm-missions/interface/data/interface.html')
end

function setMissionEditorUIVisible(visible)
    if missionEditorHideTimer and isTimer(missionEditorHideTimer) then
        killTimer(missionEditorHideTimer)
    end

    missionEditorUIVisible = visible

    if not visible and isTimer(missionEditorTimer) then
        killTimer(missionEditorTimer)
    end

    -- showCursor(visible, false)

    if not missionEditorUILoaded and visible then
        showMissionEditorInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('missionEditor', 'play-animation', false)
            missionEditorHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('missionEditor')
                missionEditorUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('missionEditor', true)
            setInterfaceData()
            missionEditorUIVisible = true
        end
    end
end

function toggleMissionEditorUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setMissionEditorUIVisible(not missionEditorUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleMissionEditorUI()
    addEventHandler('interfaceLoaded', root, function()
        missionEditorUILoaded = false
        setMissionEditorUIVisible(missionEditorUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('missionEditor')
end)