addEvent('house-create:setPosition')
addEvent('house-create:close')
addEvent('house-create:create')

local houseCreateUILoaded, houseCreateUIVisible, houseCreateHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('house-create', 'play-animation', true)
    exports['m-ui']:setInterfaceData('house-create', 'interiors', exports['m-houses']:getInteriors())
end

addEventHandler('interface:load', root, function(name)
    if name == 'house-create' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showHouseCreateInterface()
    exports['m-ui']:loadInterfaceElementFromFile('house-create', 'm-house-create/data/interface.html')
end

function setHouseCreateUIVisible(visible)
    if houseCreateHideTimer and isTimer(houseCreateHideTimer) then
        killTimer(houseCreateHideTimer)
    end

    houseCreateUIVisible = visible

    if not visible and isTimer(houseCreateTimer) then
        killTimer(houseCreateTimer)
    end

    showCursor(visible, false)

    if not houseCreateUILoaded and visible then
        showHouseCreateInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('house-create', 'play-animation', false)
            houseCreateHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('house-create')
                houseCreateUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('house-create', true)
            setInterfaceData()
            houseCreateUIVisible = true
        end
    end
end

function toggleHouseCreateUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setHouseCreateUIVisible(not houseCreateUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- toggleHouseCreateUI()
    addEventHandler('interfaceLoaded', root, function()
        houseCreateUILoaded = false
        setHouseCreateUIVisible(houseCreateUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('house-create')
end)

addCommandHandler('createhouse', function()
    toggleHouseCreateUI()
end)

addEventHandler('house-create:setPosition', root, function(type)
    local x, y, z = getElementPosition(localPlayer)
    local rx, ry, rz = getElementRotation(localPlayer)
    -- get closest rz - 0, 45, 90, 135, 180, 225, 270, 315
    local closestRz = math.floor((rz + 22.5) / 45) * 45
    if closestRz == 360 then
        closestRz = 0
    end
    rz = closestRz

    exports['m-ui']:setInterfaceData('house-create', 'position', {type = type, x = x, y = y, z = z, rx = rx, ry = ry, rz = rz})
end)

addEventHandler('house-create:close', root, function()
    setHouseCreateUIVisible(false)
end)

addEventHandler('house-create:create', root, function(data)
    if not data then return end
    setClipboard(data)
    triggerServerEvent('house:create', resourceRoot, data)
    exports['m-notis']:addNotification('success', 'Domek', 'Stworzono domek')
end)