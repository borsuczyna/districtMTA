-- local cardingUILoaded, cardingUIVisible, cardingHideTimer = false, false, false

-- function setInterfaceData()
--     exports['m-ui']:triggerInterfaceEvent('carding', 'play-animation', true)
-- end

-- addEventHandler('interface:load', root, function(name)
--     if name == 'carding' then
--         exports['m-ui']:setInterfaceVisible(name, true)
--         setInterfaceData()
--     end
-- end)

-- function showCardingInterface()
--     exports['m-ui']:loadInterfaceElementFromFile('carding', 'm-carding/data/interface.html')
-- end

-- function setCardingUIVisible(visible)
--     if cardingHideTimer and isTimer(cardingHideTimer) then
--         killTimer(cardingHideTimer)
--     end

--     cardingUIVisible = visible

--     if not visible and isTimer(cardingTimer) then
--         killTimer(cardingTimer)
--     end

--     showCursor(visible, false)

--     if not cardingUILoaded and visible then
--         showCardingInterface()
--     else
--         if not visible then
--             exports['m-ui']:triggerInterfaceEvent('carding', 'play-animation', false)
--             cardingHideTimer = setTimer(function()
--                 exports['m-ui']:destroyInterfaceElement('carding')
--                 cardingUILoaded = false
--             end, 300, 1)
--         else
--             exports['m-ui']:setInterfaceVisible('carding', true)
--             setInterfaceData()
--             cardingUIVisible = true
--         end
--     end
-- end

-- function toggleCardingUI()
--     if not getElementData(localPlayer, 'player:spawn') then return end
--     setCardingUIVisible(not cardingUIVisible)
-- end

-- addEventHandler('onClientResourceStart', resourceRoot, function()
--     toggleCardingUI()
--     addEventHandler('interfaceLoaded', root, function()
--         cardingUILoaded = false
--         setCardingUIVisible(cardingUIVisible)
--     end)
-- end)

-- addEventHandler('onClientResourceStop', resourceRoot, function()
--     exports['m-ui']:destroyInterfaceElement('carding')
-- end)