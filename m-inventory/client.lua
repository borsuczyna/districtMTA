local inventoryLoaded, inventoryVisible, inventoryTimer, insideShop = false, false, false, false
local trading = false

addEvent('interface:includes-finish', true)
addEvent('interfaceLoaded', true)
addEvent('trade:show', true)
addEvent('trade:hide', true)
addEvent('trade:hideInventory', true)
addEvent('trade:update', true)
addEvent('inventory:getNearbyPlayers', true)
addEvent('inventory:getCraftingRecipes', true)

function updateInventoryData()
    exports['m-ui']:setInterfaceData('inventory', 'itemsData', itemsData)
    exports['m-ui']:setInterfaceData('inventory', 'shopData', insideShop)
    
    if trading then
        exports['m-ui']:setInterfaceData('inventory', 'trading', {otherName = getPlayerName(trading), myName = getPlayerName(localPlayer)})
    end
end

addEventHandler('interface:includes-finish', root, function(name)
    if name == 'inventory' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('inventory', 995)
        exports['m-ui']:triggerInterfaceEvent('inventory', 'play-animation', true)
        inventoryLoaded = true
        updateInventoryData()
    end
end)

function showInventoryInterface()
    exports['m-ui']:loadInterfaceElementFromFile('inventory', 'm-inventory/data/interface.html')
end

function setInventoryVisible(visible)
    if trading then return end

    if inventoryHideTimer and isTimer(inventoryHideTimer) then
        killTimer(inventoryHideTimer)
    end

    inventoryVisible = visible
    insideShop = false

    if not visible and isTimer(inventoryTimer) then
        killTimer(inventoryTimer)
    end

    showCursor(visible, false)

    if not inventoryLoaded and visible then
        showInventoryInterface()
    else
        if not visible then
            exports['m-ui']:triggerInterfaceEvent('inventory', 'play-animation', false)
            inventoryHideTimer = setTimer(function()
                exports['m-ui']:destroyInterfaceElement('inventory')
                inventoryLoaded = false
            end, 300, 1)
        else
            exports['m-ui']:setInterfaceVisible('inventory', true)
            exports['m-ui']:triggerInterfaceEvent('inventory', 'play-animation', true)
            inventoryVisible = true
        end
    end
end

function toggleShopUI(visible, data)
    if not getElementData(localPlayer, 'player:spawn') then return end

    setInventoryVisible(visible)
    insideShop = data
end

function toggleInventory()
    if not getElementData(localPlayer, 'player:spawn') then return end
    setInventoryVisible(not inventoryVisible)
end

function controllerButtonPressed(button)
    if (button == 13 and not inventoryVisible and not isCursorShowing()) or (button == 2 and inventoryVisible) then
        toggleInventory()
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    bindKey('i', 'down', toggleInventory)
    addEventHandler('controller:buttonPressed', root, controllerButtonPressed)

    addEventHandler('interfaceLoaded', root, function()
        inventoryLoaded = false
        setInventoryVisible(inventoryVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('inventory')
    exports['m-intro']:hideIntro('inventory')
    exports['m-intro']:hideIntro('inventory-shops')
end)

addEventHandler('trade:show', root, function(otherPlayer)
    if not inventoryVisible then
        setInventoryVisible(true)
    else
        exports['m-ui']:setInterfaceData('inventory', 'trading', {otherName = getPlayerName(otherPlayer), myName = getPlayerName(localPlayer)})
    end

    trading = otherPlayer
end)

addEventHandler('trade:hide', root, function()
    trading = false
    exports['m-ui']:setInterfaceData('inventory', 'trading', false)
end)

addEventHandler('trade:hideInventory', root, function()
    trading = false
    setInventoryVisible(false)
end)

addEventHandler('inventory:getNearbyPlayers', root, function()
    local x, y, z = getElementPosition(localPlayer)
    local players = getElementsWithinRange(x, y, z, 10, 'player')
    local nearbyPlayers = {}

    for k,v in pairs(players) do
        local uid = getElementData(v, 'player:uid')
        if v ~= localPlayer and uid then
            table.insert(nearbyPlayers, {uid = uid, name = getPlayerName(v)})
        end
    end

    exports['m-ui']:setInterfaceData('inventory', 'nearbyPlayers', nearbyPlayers)
end)

addEventHandler('inventory:getCraftingRecipes', root, function()
    exports['m-ui']:setInterfaceData('inventory', 'craftingRecipes', craftingRecipes)
end)

addEventHandler('trade:update', root, function(myOffer, theirOffer, accepted, acceptedUsers)
    exports['m-ui']:setInterfaceData('inventory', 'tradeItems', {myOffer = myOffer, theirOffer = theirOffer, accepted = accepted, acceptedUsers = acceptedUsers})
end)