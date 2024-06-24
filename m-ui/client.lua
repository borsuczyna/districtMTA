local sx, sy = guiGetScreenSize()
local zoom = sx < 2048 and math.min(2.2, 2048/sx) or 1
local browser, uiLoaded = nil, false;
local spinner = dxCreateTexture('data/images/spinner.png', 'argb', true, 'clamp')
local font = dxCreateFont('data/fonts/Inter-Medium.ttf', 23/zoom, false, 'proof')
local textWidth = dxGetTextWidth('Trwa ładowanie interfejsu...', 1, font)
local totalWidth = textWidth + 50/zoom + 20/zoom

addEvent('interfaceLoaded', true)
addEvent('interfaceElement:load', true)
addEvent('interface:load', true)
addEventHandler('interfaceLoaded', resourceRoot, function()
    uiLoaded = true
    
    -- setDevelopmentMode(true, true) toggleBrowserDevTools(browser, true)
    -- loadInterfaceElement('login')
    -- loadInterfaceElement('test')
end)

-- addEventHandler('interface:load', resourceRoot, function(name)
--     setInterfaceVisible(name, true)
-- end)

function setInterfaceVisible(name, visible)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, 'setInterfaceVisible("'..name..'", '..tostring(visible)..')')
end

function loadInterfaceElement(name)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, 'loadInterfaceElement("'..name..'")')
end

function loadInterfaceElementFromCode(name, code)
    if not uiLoaded or not browser then return end
    code = code:gsub('`', '\\`')
    code = code:gsub('%${', '\\${')
    executeBrowserJavascript(browser, 'loadInterfaceElementFromCode("'..name..'", `'..code..'`)')
end

function loadInterfaceElementFromFile(name, path)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, 'loadInterfaceElementFromFile("'..name..'", "'..path..'")')
end

function addEventHandlerToInterfaceElement(name, event, handlerCode)
    if not uiLoaded or not browser then return end
    handlerCode = handlerCode:gsub('`', '\\`')
    handlerCode = handlerCode:gsub('%${', '\\${')
    executeBrowserJavascript(browser, 'addEventHandlerToInterfaceElement("'..name..'", "'..event..'", `'..handlerCode..'`)')
end

function setInterfaceZIndex(name, zIndex)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, 'setInterfaceZIndex("'..name..'", '..tostring(zIndex)..')')
end

function destroyInterfaceElement(name)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, 'destroyInterfaceElement("'..name..'")')
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

    executeBrowserJavascript(browser, 'setInterfaceData("'..interfaceName..'", "'..key..'", '..value..')')
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

    executeBrowserJavascript(browser, 'triggerEvent("'..interfaceName..'", "'..name..'", '..argsString..')')
end

function executeJavascript(code)
    if not uiLoaded or not browser then return end
    executeBrowserJavascript(browser, code)
end

function isLoaded()
    return uiLoaded
end

function renderInterface()
    if uiLoaded then
        dxDrawImage(0, 0, sx, sy, browser, 0, 0, 0, tocolor(255, 255, 255, 255), false)

        local cx, cy = getCursorPosition()
        if not cx or not cy then cx, cy = -5000, -5000 end
        cx, cy = cx*sx, cy*sy
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
    addEventHandler('onClientBrowserCreated', browser, function()
        loadBrowserURL(browser, 'http://mta/local/data/main.html')
    end)
end

addEventHandler('onClientResourceStart', resourceRoot, initializeInterface)