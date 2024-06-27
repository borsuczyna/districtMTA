local hudLoaded = false
local hudVisible = false
local lastSentData = {}

addEvent('interface:load', true)
addEvent('interfaceLoaded', true)
addEvent('avatars:onPlayerAvatarChange', true)

function updateHud(avatar)
    if not hudVisible then return end
    
    setPlayerHudComponentVisible('all', false)

    local data = {
        nickname = getPlayerName(localPlayer),
        health = getElementHealth(localPlayer),
        money = getPlayerMoney(localPlayer),
        level = 0,
        exp = 0,
    }

    local anythingChanged = false
    for key, value in pairs(data) do
        if lastSentData[key] ~= value then
            anythingChanged = true
            break
        end
    end

    if not anythingChanged then return end

    lastSentData = data
    exports['m-ui']:setInterfaceData('hud', 'hud:data', data)
end

function updateAvatar(avatar)
    exports['m-ui']:executeJavascript(string.format('hud_setAvatar(%q)', avatar or ''))
end

addEventHandler('avatars:onPlayerAvatarChange', root, function(player, avatar)
    if player ~= localPlayer then return end
    updateAvatar(avatar)
end)

addEventHandler('interface:load', root, function(name)
    if name == 'hud' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('hud', 1001)
        lastSentData = {}
        updateHud()
        addEventHandler('onClientRender', root, updateHud)
        hudLoaded = true

        local avatar = exports['m-avatars']:getPlayerAvatar(localPlayer)
        updateAvatar(avatar)
    end
end)

function showHudInterface()
    exports['m-ui']:loadInterfaceElementFromFile('hud', 'm-hud/data/interface/hud.html')
    setBlurLevel(0)
end

function setHudVisible(visible)
    hudVisible = visible

    if not hudLoaded and visible then
        showHudInterface()
    else
        if not visible then
            exports['m-ui']:destroyInterfaceElement('hud')
            hudLoaded = false
        else
            exports['m-ui']:setInterfaceVisible('hud', true)
        end
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    if getElementData(localPlayer, 'player:spawn') then
        setHudVisible(true)
    end

    addEventHandler('interfaceLoaded', root, function()
        hudLoaded = false
        lastSentData = {}
        setHudVisible(hudVisible)
    end)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('hud')
end)