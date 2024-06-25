local sx, sy = guiGetScreenSize()
local shader, screenSource;

addEvent('interface:load', true)
addEvent('login:login', true)
addEvent('login:register', true)
addEvent('login:login-response', true)
addEvent('login:register-response', true)
addEvent('login:hideLoginPanel', true)

function setUpdates()
    local updates = exports['m-updates']:getUpdates()
    exports['m-ui']:setInterfaceData('login', 'updates', updates)
end

function setRememberedData()
    local xml = xmlLoadFile('@login.xml')
    if not xml then return end

    local login = xmlNodeGetAttribute(xml, 'login')
    local password = tostring(xmlNodeGetAttribute(xml, 'password', 'm-login'))
    xmlUnloadFile(xml)

    exports['m-ui']:setInterfaceData('login', 'login-cached', {login = login, password = password})
end

addEventHandler('interface:load', root, function(name)
    if name == 'login' then
        exports['m-ui']:setInterfaceVisible(name, true)
        setUpdates()
        setRememberedData()
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

addEventHandler('login:hideLoginPanel', root, function(remember, login, password)
    exports['m-ui']:destroyInterfaceElement('login')
    showSpawnSelect()

    if remember then
        local xml = xmlCreateFile('@login.xml', 'login')
        xmlNodeSetAttribute(xml, 'login', login)
        xmlNodeSetAttribute(xml, 'password', password)
        xmlSaveFile(xml)
    end
end)

function render()
    dxUpdateScreenSource(screenSource)
    dxDrawImage(0, 0, sx, sy, shader)
end

function showInterface()
    if getElementData(localPlayer, 'player:logged') then return end

    exports['m-ui']:loadInterfaceElementFromFile('login', 'm-login/data/login.html')
    shader = dxCreateShader('data/shader.fx')
    screenSource = dxCreateScreenSource(sx, sy)
    sound = playSound('data/music.mp3')

    moveCamera(1936, 1628, 80, 1606.15, -1595.12, 103.31, 150)
    addEventHandler('onClientRender', root, render, true, 'high+9999')
    dxSetShaderValue(shader, 'screenSource', screenSource)
    guiSetInputMode('no_binds')
    showCursor(true)
    showChat(false)
    fadeCamera(true)
end

function hideInterface()
    exports['m-ui']:destroyInterfaceElement('login')
    removeEventHandler('onClientRender', root, render)

    if isElement(shader) then
        destroyElement(shader)
    end

    if isElement(object) then
        detachElements(getCamera(), object)
        destroyElement(object)
    end

    if isElement(sound) then
        stopSound(sound)
        destroyElement(sound)
    end

    if isElement(screenSource) then
        destroyElement(screenSource)
    end

    showCursor(false)
    showChat(true)
    guiSetInputMode('allow_binds')
end

function moveCamera(x, y, z, x2, y2, z2, time)
    local camera = getCamera()

    local function startCameraMove(fromX, fromY, fromZ, toX, toY, toZ)
        object = createObject(1337, fromX, fromY, fromZ)
        
        setElementAlpha(object, 0)
        setObjectScale(object, 0.01)
        moveObject(object, time * 1000, toX, toY, toZ, 0, 0, 0, 'InOutQuad')
        
        setElementPosition(camera, 0, 0, 0)
        attachElements(camera, object)
        
        local function onMovementEnd()
            detachElements(camera, object)
            destroyElement(object)

            startCameraMove(toX, toY, toZ, fromX, fromY, fromZ)
        end

        setTimer(onMovementEnd, time * 1000, 1)
    end
    
    startCameraMove(x, y, z, x2, y2, z2)
end 

addEventHandler('onClientResourceStart', resourceRoot, function()
    addEventHandler('interfaceLoaded', root, showInterface)
    if exports['m-ui']:isLoaded() then
        showInterface()
    end
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
    exports['m-ui']:destroyInterfaceElement('login')
    exports['m-ui']:destroyInterfaceElement('login-spawn')
end)