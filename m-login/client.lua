local sx, sy = guiGetScreenSize()
local shader, screenSource;

addEvent('interface:load', true)
addEvent('login:login', true)
addEvent('login:register', true)
addEvent('login:login-response', true)
addEvent('login:register-response', true)

function setUpdates()
    local updates = exports['m-updates']:getUpdates()
    exports['m-ui']:setInterfaceData('login', 'updates', updates)
end

addEventHandler('interface:load', root, function(name)
    if name == 'login' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setUpdates()
    end
end)

addEventHandler('login:login', root, function(login, password)
    triggerServerEvent('login:login', resourceRoot, login, password)
end)

addEventHandler('login:register', root, function(email, login, password)
    triggerServerEvent('login:register', resourceRoot, email, login, password)
end)

addEventHandler('login:login-response', root, function(success)
    exports['m-ui']:triggerInterfaceEvent('login', 'login-response', success)
end)

addEventHandler('login:register-response', root, function(success)
    exports['m-ui']:triggerInterfaceEvent('login', 'register-response', success)
end)

function render()
    dxUpdateScreenSource(screenSource)
    dxDrawImage(0, 0, sx, sy, shader)
end

function showInterface()
    loadInterfaceFromFile('login', 'data/interface.html')
    shader = dxCreateShader('data/shader.fx')
    screenSource = dxCreateScreenSource(sx, sy)
    addEventHandler('onClientRender', root, render, true, 'high+9999')
    dxSetShaderValue(shader, 'screenSource', screenSource)
    guiSetInputMode('no_binds')
    showCursor(true)
    showChat(false)
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    if not exports['m-ui']:isLoaded() then
        addEventHandler('interfaceLoaded', root, showInterface)
    else
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('login')
end)