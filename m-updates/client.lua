addEvent('changes:close', true)
addEvent('changes:showLastChanges', true)

local changesUILoaded, changesUIVisible, changesHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('changes', 'play-animation', true)
    exports['m-ui']:setInterfaceData('changes', 'changes', getUpdatesSinceLastJoin())
end

addEventHandler('interface:load', root, function(name)
    if name == 'changes' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showChangesInterface()
    exports['m-ui']:loadInterfaceElementFromFile('changes', 'm-updates/data/interface.html')
end

function setChangesUIVisible(visible)
    if changesHideTimer and isTimer(changesHideTimer) then
        killTimer(changesHideTimer)
    end

    changesUIVisible = visible

    if not visible and isTimer(changesTimer) then
        killTimer(changesTimer)
    end

    showCursor(visible, false)

    if not changesUILoaded and visible then
        showChangesInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('changes', 'play-animation', false)
            changesHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('changes')
                changesUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('changes', true)
            setInterfaceData()
            changesUIVisible = true
        end
    end
end

function toggleChangesUI()
    local lastChanges = getUpdatesSinceLastJoin()
    if #lastChanges == 0 then return end

    if not getElementData(localPlayer, 'player:spawn') then return end
    setChangesUIVisible(not changesUIVisible)
end

function showLastChanges()
    local lastChanges = getUpdatesSinceLastJoin()
    if #lastChanges == 0 then return end

    setChangesUIVisible(true)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleChangesUI()
    -- showLastChanges()
    addEventHandler('interfaceLoaded', root, function()
        changesUILoaded = false
        setChangesUIVisible(changesUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('changes')
end)

addEventHandler('changes:close', root, function()
    setChangesUIVisible(false)
end)

addEventHandler('changes:showLastChanges', root, function()
    showLastChanges()
end)