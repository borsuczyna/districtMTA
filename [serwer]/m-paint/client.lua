addEvent('paint:hideUI', true)

local paintUILoaded, paintUIVisible, paintHideTimer = false, false, false
local lastPacket = 0
local paintMarkers = {
    {113.469, -190.879, 1.500},
    {2028.294, -1787.516, 13.552},
}

local function onHitMarker(hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
        togglePaintUI()
    end
end

local function onLeaveMarker(leaveElement, matchingDimension)
    if leaveElement == localPlayer and matchingDimension then
        setPaintUIVisible(false)
    end
end

local function createPaintMarker(position)
    local marker = createMarker(position[1], position[2], position[3] - 1, 'cylinder', 1, 100, 0, 255, 0)
    setElementData(marker, 'marker:title', 'Lakiernia')
    setElementData(marker, 'marker:desc', 'Kupno sprayu')
    setElementData(marker, 'marker:icon', 'spray')
    addEventHandler('onClientMarkerHit', marker, onHitMarker)
    addEventHandler('onClientMarkerLeave', marker, onLeaveMarker)

    local blip = createBlipAttachedTo(marker, 14, 2, 255, 0, 0, 255, 0, 9999.0)
    setElementData(blip, 'blip:hoverText', 'Lakiernia')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    for i, position in ipairs(paintMarkers) do
        createPaintMarker(position)
    end
end)

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('paint', 'play-animation', true)
end

addEventHandler('interface:load', root, function(name)
    if name == 'paint' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showPaintInterface()
    exports['m-ui']:loadInterfaceElementFromFile('paint', 'm-paint/data/interface.html')
end

function setPaintUIVisible(visible)
    if paintHideTimer and isTimer(paintHideTimer) then
        killTimer(paintHideTimer)
    end

    paintUIVisible = visible

    if not visible and isTimer(paintTimer) then
        killTimer(paintTimer)
    end

    showCursor(visible, false)

    if not paintUILoaded and visible then
        showPaintInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('paint', 'play-animation', false)
            paintHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('paint')
                paintUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('paint', true)
            setInterfaceData()
            paintUIVisible = true
        end
    end
end

function togglePaintUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setPaintUIVisible(not paintUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- togglePaintUI()
    addEventHandler('interfaceLoaded', root, function()
        paintUILoaded = false
        setPaintUIVisible(paintUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('paint')
end)

addEventHandler('paint:hideUI', root, function()
    setPaintUIVisible(false)
end)

addEventHandler('onClientPlayerWeaponFire', localPlayer, function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
    if weapon == 41 then
        if getTickCount() - lastPacket < 250 then
            return
        end

        lastPacket = getTickCount()
        triggerServerEvent('paint:fire', resourceRoot, hitX, hitY, hitZ)
    end
end)