local clothingUILoaded, clothingUIVisible, clothingHideTimer = false, false, false

function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('clothing', 'play-animation', true)
    exports['m-ui']:setInterfaceData('clothing', 'clothes', clothes)
end

addEventHandler('interface:load', root, function(name)
    if name == 'clothing' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showClothingInterface()
    exports['m-ui']:loadInterfaceElementFromFile('clothing', 'm-clothing/data/interface.html')
end

function setClothingUIVisible(visible)
    if visible and exports['m-ui']:isAnySingleInterfaceVisible() then return end
    exports['m-ui']:addSingleInterface('clothing')

    if clothingHideTimer and isTimer(clothingHideTimer) then
        killTimer(clothingHideTimer)
    end

    clothingUIVisible = visible

    if not visible and isTimer(clothingTimer) then
        killTimer(clothingTimer)
    end

    showCursor(visible, false)

    if not clothingUILoaded and visible then
        showClothingInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('clothing', 'play-animation', false)
            clothingHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('clothing')
                clothingUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('clothing', true)
            setInterfaceData()
            clothingUIVisible = true
        end
    end
end

function toggleClothingUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setClothingUIVisible(not clothingUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, function()
        clothingUILoaded = false
        setClothingUIVisible(clothingUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('clothing')
end)

function clothingMarkerHit(element, matchingDimension)
    if element ~= localPlayer or not matchingDimension then return end
    if getPedOccupiedVehicle(localPlayer) then return end

    setClothingUIVisible(true)
end

function clothingMarkerLeave(element, matchingDimension)
    if element ~= localPlayer or not matchingDimension then return end
    if getPedOccupiedVehicle(localPlayer) then return end

    setClothingUIVisible(false)
end