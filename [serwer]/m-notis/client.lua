addEvent('interface:load', true)
addEvent('notis:addNotification', true)

addEventHandler('interface:load', root, function(name)
    if name == 'notis' then
        exports['m-ui']:setInterfaceVisible(name, true)
        exports['m-ui']:setInterfaceZIndex('notis', 1000)
    end
end)

function showInterface()
    exports['m-ui']:loadInterfaceElementFromFile('notis', 'm-notis/data/interface.html')
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('notis')
end)

function addNotification(type, title, message, time)
    type = type:gsub('`', '\\`')
    title = title:gsub('`', '\\`')
    message = message:gsub('`', '\\`')  
    exports['m-ui']:executeJavascript('notis_addNotification(`'..type..'`, `'..title..'`, `'..message..'`, '..tostring(time or 5000)..')')
    playSound('data/'..type..'.mp3')

    -- remove html from message
    message = message:gsub('<br>', '\n')
    message = message:gsub('<[^>]+>', '')
    outputConsole('['..type..'] '..title..': '..message)
end

addEventHandler('notis:addNotification', resourceRoot, addNotification)