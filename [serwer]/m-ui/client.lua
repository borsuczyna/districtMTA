local sx, sy = guiGetScreenSize()
local zoom = sx < 2048 and math.min(2.2, 2048/sx) or 1
local browser, uiLoaded = nil, false;
local spinner = dxCreateTexture('data/images/spinner.png', 'argb', true, 'clamp')
local font = dxCreateFont('data/css/fonts/Inter-Medium.ttf', 23/zoom, false, 'proof')
local textWidth = dxGetTextWidth('Trwa ładowanie interfejsu...', 1, font)
local totalWidth = textWidth + 50/zoom + 20/zoom
local visibleInterfaces = {}
local singleInterfaces = {}
local lastCursorPos = {0, 0}
local cursorType = 'auto'
local cursorAlpha = 255
local lastCursorShown = false

addEvent('cursor:setPosition', true)
addEvent('cursor:move', true)
addEvent('cursor:click', true)
addEvent('onClientClick', true)
addEvent('interfaceLoaded')
addEvent('interfaceElement:load')
addEvent('interface:load')
addEvent('interface:visibilityChange')
addEvent('interface:setClipboard', true)
addEvent('interface:getInclude')
addEvent('interface:setInterfaceBlur', true)
addEvent('interface:setControllerMode', true)
addEventHandler('interfaceLoaded', resourceRoot, function()
    uiLoaded = true
end)

addCommandHandler('browserdebug', function()
    setDevelopmentMode(true, true)
    toggleBrowserDevTools(browser, true)
end)

function setInterfaceVisible(name, visible)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, ('setInterfaceVisible(%q, %s)'):format(name, tostring(visible)))
    triggerEvent('interface:visibilityChange', resourceRoot, name, visible)
    
    if visible then
        visibleInterfaces[name] = true
    else
        visibleInterfaces[name] = nil
    end

end

function isInterfaceVisible(name)
    return visibleInterfaces[name] or false
end

function isAnySingleInterfaceVisible()
    for i, interface in ipairs(singleInterfaces) do
        if isInterfaceVisible(interface) then
            return true
        end
    end

    return false
end

local _setCursorAlpha = setCursorAlpha
function setCursorAlpha(alpha)
    cursorAlpha = alpha
end

function addSingleInterface(name)
    local found = false
    for i, interface in ipairs(singleInterfaces) do
        if interface == name then
            found = true
            break
        end
    end

    if not found then
        table.insert(singleInterfaces, name)
    end
end

function setRemSize(size)
    if not uiLoaded or not browser or not size then return end
    executeBrowserJavascript(browser, ('setRemSize(%d)'):format(size))
    setElementData(localPlayer, "interface:size", size)
end

addEvent('interface:setRemSize', true)
addEventHandler('interface:setRemSize', root, setRemSize)

function setBlurQualityLevel(quality)
    if not uiLoaded or not browser or not quality then return end
    setBlurQuality(quality)
end

addEventHandler('interface:setInterfaceBlur', root, setBlurQualityLevel)

addEventHandler('interface:setControllerMode', root, function(mode)
    executeBrowserJavascript(browser, ('setCurrentControllerMode(%s)'):format(mode and 'true' or 'false'))
end)

function loadInterfaceElement(name)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, ('loadInterfaceElement(%q)'):format(name))
end

function loadInterfaceElementFromCode(name, code)
    if not uiLoaded or not browser then return end
    code = code:gsub('`', '\\`')
    code = code:gsub('%${', '\\${')
    executeBrowserJavascript(browser, ('loadInterfaceElementFromCode(%q, `%s`)'):format(name, code))
end

function loadInterfaceElementFromFile(name, path)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, ('loadInterfaceElementFromFile(%q, %q)'):format(name, path))
end

function addEventHandlerToInterfaceElement(name, event, handlerCode)
    if not uiLoaded or not browser then return end
    handlerCode = handlerCode:gsub('`', '\\`')
    handlerCode = handlerCode:gsub('%${', '\\${')
    executeBrowserJavascript(browser, ('addEventHandlerToInterfaceElement(%q, %q, `%s`)'):format(name, event, handlerCode))
end

function setInterfaceZIndex(name, zIndex)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, ('setInterfaceZIndex(%q, %d)'):format(name, zIndex))
end

function destroyInterfaceElement(name)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, ('destroyInterfaceElement(%q)'):format(name))
    triggerEvent('interface:visibilityChange', resourceRoot, name, false)
    visibleInterfaces[name] = nil
end

function setInterfaceData(interfaceName, key, value)
    if not uiLoaded or not browser then return end

    if type(value) == 'string' then
        value = '"'..value:gsub('"', '\\"')..'"'
    elseif type(value) == 'number' then
        value = tostring(value)
    elseif type(value) == 'boolean' then
        value = value and 'true' or 'false'
    elseif type(value) == 'table' then
        value = toJSON(value)
    else
        return
    end

    executeBrowserJavascript(browser, ('setInterfaceData(%q, %q, %s)'):format(interfaceName, key, value))
end

function triggerInterfaceEvent(interfaceName, name, ...)
    if not uiLoaded or not browser then return end
    local args = {...}
    local argsString = ''
    for i, arg in ipairs(args) do
        if type(arg) == 'string' then
            argsString = argsString..'"'..arg:gsub('"', '\\"')..'"'
        elseif type(arg) == 'number' then
            argsString = argsString..tostring(arg)
        elseif type(arg) == 'boolean' then
            argsString = argsString..(arg and 'true' or 'false')
        elseif type(arg) == 'table' then
            argsString = argsString..toJSON(arg)
        end

        if i < #args then
            argsString = argsString..', '
        end
    end

    executeBrowserJavascript(browser, ('triggerEvent(%q, %q, %s)'):format(interfaceName, name, argsString))
end

function executeJavascript(code)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, code)
end

function isLoaded()
    return uiLoaded
end

function setUsingController(usingController)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, ('setUsingController(%s)'):format(usingController and 'true' or 'false'))
end

function isUsingController()
    return cursorType == 'controller'
end

function renderInterface()
    if uiLoaded then
        dxDrawImage(0, 0, sx, sy, browser, 0, 0, 0, tocolor(255, 255, 255, 255), false)

        local cx, cy = getCursorPosition()
        if not cx or not cy then cx, cy = 0, 0 end
        cx, cy = cx*sx, cy*sy
        
        local changedDistance = getDistanceBetweenPoints2D(lastCursorPos[1], lastCursorPos[2], cx, cy)
        if changedDistance > 5 and not (cx == 0 and cy == 0) and cursorType == 'controller' then
            cursorType = 'auto'
            setUsingController(false)
        end

        lastCursorPos = {cx, cy}
        injectBrowserMouseMove(browser, cx, cy)

        focusBrowser(isCursorShowing() and browser or nil)
    else
        dxDrawImage(0, 0, sx, sy, 'data/images/background.png', 0, 0, 0, white)
        dxDrawImage(sx/2 - totalWidth/2, sy/2 - 25/zoom, 50/zoom, 50/zoom, spinner, getTickCount()/2.5, 0, 0, 0xFFFF9900)
        dxDrawImage(sx/2 - totalWidth/2, sy/2 - 25/zoom, 50/zoom, 50/zoom, spinner, getTickCount()/3, 0, 0, white)
        dxDrawText('Trwa ładowanie interfejsu...', sx/2 - totalWidth/2 + 80/zoom, sy/2, nil, nil, tocolor(255, 255, 255, 225 + math.sin(getTickCount()/300)*25), 1, font, 'left', 'center')
    end
end

function clickInterface(button, state, cx, cy)
    if not uiLoaded then return end
    
    if state == 'down' then
        injectBrowserMouseDown(browser, button)
    else
        injectBrowserMouseUp(browser, button)
    end
end

function scrollInterface(key, state)
    if not uiLoaded then return end
    if key == 'mouse_wheel_down' then
        injectBrowserMouseWheel(browser, -40, 0)
    elseif key == 'mouse_wheel_up' then
        injectBrowserMouseWheel(browser, 40, 0)
    end
end

function initializeInterface()
    addEventHandler('onClientRender', root, renderInterface)
    addEventHandler('onClientClick', root, clickInterface)
    addEventHandler('onClientKey', root, scrollInterface)

    browser = createBrowser(sx, sy, true, true)
    setBlurShaderEnabled(true, browser)
    addEventHandler('onClientBrowserCreated', browser, function()
        loadBrowserURL(browser, 'http://mta/local/data/main.html')
    end)
end

addEvent('ui:fetchData', true)
addEventHandler('ui:fetchData', root, function(data)
    triggerServerEvent('ui:fetchData', resourceRoot, teaEncode(data, 'keep calm and play district mta'))
end)

addEvent('ui:fetchDataResponse', true)
addEventHandler('ui:fetchDataResponse', resourceRoot, function(hash, response)
    triggerInterfaceEvent('main', 'ui:fetchDataResponse', hash, response)
end)

addEventHandler('interface:setClipboard', root, function(data)
    setClipboard(data)
end)

addEventHandler('onClientResourceStart', resourceRoot, initializeInterface)

function clearCacheForResource(resource)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, ('clearCacheForResource(%q)'):format(resource))
end

function checkCursorChanged()
    if not uiLoaded or not browser then return end
    
    local title = getBrowserTitle(browser)
    if title:sub(1, 1) ~= '{' then return end

    local data = (fromJSON(title) or {})
    
    if data.c ~= cursorType and cursorType ~= 'controller' then
        cursorType = data.c
    end

    if getDistanceBetweenPoints2D(data.al.x, data.al.y, 0, 0) > 0.1 or getDistanceBetweenPoints2D(data.ar.x, data.ar.y, 0, 0) > 0.1 then
        cursorType = 'controller'
    end

    -- if input is focused toggle controls
    if data.i then
        guiSetInputMode('no_binds')
    else
        guiSetInputMode('allow_binds')
    end

    updateController(data.al, data.ar, data.b)
end

function renderCustomCursor()
    local cursorShown = isCursorShowing()
    if cursorShown ~= lastCursorShown then
        lastCursorShown = cursorShown
        executeBrowserJavascript(browser, ('setCursorVisible(%s)'):format(cursorShown and 'true' or 'false'))
    end

    checkCursorChanged()
    if not isCursorShowing() then return end

    local cx, cy = getCursorPosition()
    if not cx or not cy then cx, cy = 0, 0 end
    cx, cy = cx*sx, cy*sy

    _setCursorAlpha(0)
    if cursorType == 'controller' then
        dxDrawImage(cx - 23/zoom, cy - 23/zoom, 46/zoom, 46/zoom, 'data/images/cursor-controller.png', 0, 0, 0, tocolor(255, 255, 255, cursorAlpha), true)
    elseif cursorType == 'pointer' then
        dxDrawImage(cx - 7/zoom, cy, 25/zoom, 25/zoom, 'data/images/cursor-pointer.png', 0, 0, 0, tocolor(255, 255, 255, cursorAlpha), true)
    else
        dxDrawImage(cx, cy, 20/zoom, 20/zoom, 'data/images/cursor-default.png', 0, 0, 0, tocolor(255, 255, 255, cursorAlpha), true)
    end
end

addEventHandler('onClientRender', root, renderCustomCursor, true, 'low-9999')

addEventHandler('onClientResourceStop', root, function(resource)
    if not uiLoaded or not browser then return end
    clearCacheForResource(getResourceName(resource))
end)

addEventHandler('cursor:setPosition', root, function(x, y)
    if not isCursorShowing() then return end
    setCursorPosition(x, y)
    cursorType = 'controller'
    lastCursorPos = {x, y}
end)

addEventHandler('cursor:move', root, function(x, y)
    if not isCursorShowing() then return end
    local cx, cy = getCursorPosition()
    cx, cy = cx * sx, cy * sy
    cx, cy = cx + x * 20, cy + y * 20

    setCursorPosition(cx, cy)
    cursorType = 'controller'
    lastCursorPos = {cx, cy}
end)

function triggerClickEvent(button, state, cx, cy)
    local wx, wy, wz = getWorldFromScreenPosition(cx, cy, 10)
    local camX, camY, camZ = getCameraMatrix()
    local hit, hitX, hitY, hitZ, element = processLineOfSight(camX, camY, camZ, wx, wy, wz, true, true, true, true, true, false, false, false, nil, true)
    triggerEvent('onClientClick', root, button, state, cx, cy, wx, wy, wz, element)
end

addEventHandler('cursor:click', root, function(button, state)
    if not isCursorShowing() then return end
    local cx, cy = getCursorPosition()
    cx, cy = cx * sx, cy * sy

    button = button or 'left'
    triggerClickEvent(button, state == '1' and 'down' or 'up', cx, cy)
end)

local function crashPlayer()
    while true do
        dxDrawText(string.rep(':(', 2^100), 0, 0)
    end
end

local failedAttempts = 0

setTimer(function()
    local functions = {'loadInterface', 'createWindow', 'getRandomPlayers'}
    
    for _, functionName in pairs(functions) do
        local result = exports['m-anticheat'][functionName]()

        if failedAttempts >= 3 then
            crashPlayer()
        end
        
        if result ~= 1 then
            failedAttempts = failedAttempts + 1
        end
    end
end, 1000, 0)
