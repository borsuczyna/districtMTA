addEvent('interface:load', true)
addEvent('interaction:addNotification', true)

addEventHandler('interface:load', root, function(name)
    if name == 'interaction' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('interaction', 1000)
    end
end)

function showInterface()
    exports['m-ui']:loadInterfaceElementFromFile('interaction', 'm-interaction/data/interface.html')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('interaction')
end)

function addNotification(type, title, message, time)
    type = type:gsub('`', '\\`')
    title = title:gsub('`', '\\`')
    message = message:gsub('`', '\\`')  
    exports['m-ui']:executeJavascript('interaction_addNotification(`'..type..'`, `'..title..'`, `'..message..'`, '..tostring(time or 5000)..')')
    playSound('data/'..type..'.mp3')

    -- remove html from message
    message = message:gsub('<[^>]+>', '')
    outputConsole('['..type..'] '..title..': '..message)
end

addEventHandler('interaction:addNotification', resourceRoot, addNotification)
