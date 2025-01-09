addEvent('factions:openPaymentPanel', true)
addEvent('factions:closePaymentPanel', true)

local paymentUILoaded, paymentUIVisible, paymentHideTimer, paymentData = false, false, false, false

local function setInterfaceData()
    exports['m-ui']:triggerInterfaceEvent('payment', 'play-animation', true)
    exports['m-ui']:setInterfaceData('payment', 'data', paymentData)
end

addEventHandler('interface:load', root, function(name)
    if name == 'payment' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setInterfaceData()
    end
end)

function showPaymentInterface()
    exports['m-ui']:loadInterfaceElementFromFile('payment', 'm-factions/data/payment.html')
end

function setPaymentUIVisible(visible)
    if paymentHideTimer and isTimer(paymentHideTimer) then
        killTimer(paymentHideTimer)
    end

    paymentUIVisible = visible

    if not visible and isTimer(paymentTimer) then
        killTimer(paymentTimer)
    end

    showCursor(visible, false)

    if not paymentUILoaded and visible then
        showPaymentInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('payment', 'play-animation', false)
            paymentHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('payment')
                paymentUILoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('payment', true)
            setInterfaceData()
            paymentUIVisible = true
        end
    end
end

function togglePaymentUI()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setPaymentUIVisible(not paymentUIVisible)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- togglePaymentUI()
    addEventHandler('interfaceLoaded', root, function()
        paymentUILoaded = false
        setPaymentUIVisible(paymentUIVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('payment')
end)

addEventHandler('factions:openPaymentPanel', resourceRoot, function(data)
    paymentData = data
    togglePaymentUI()
end)

addEventHandler('factions:closePaymentPanel', root, function()
    setPaymentUIVisible(false)
end)