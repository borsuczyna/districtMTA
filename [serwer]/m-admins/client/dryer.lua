local scx, scy = guiGetScreenSize()
local zoomOriginal = scx < 2048 and math.min(2.2, 2048/scx) or 1
local currentAction = 1
local lastElement = false

local fonts = {
    dxCreateFont(':m-ui/data/css/fonts/Inter-Bold.ttf', 14/zoomOriginal, false, 'proof'),
    dxCreateFont(':m-ui/data/css/fonts/Inter-Medium.ttf', 12/zoomOriginal, false, 'proof'),
}

addEventHandler('onClientRender', root, function()
    if not doesPlayerHavePermission(localPlayer, 'dryer') then return end
    
    local interfaceSize = getElementData(localPlayer, "player:interfaceSize")
    local zoom = zoomOriginal * ( 25 / interfaceSize )
    local weapon = getPedWeapon(localPlayer)
    toggleControl('fire', weapon ~= 22 and weapon ~= 0)
    toggleControl('action', weapon ~= 22 and weapon ~= 0)

    if weapon ~= 22 then
        lastElement = false
        return
    end

    if not isPedAiming(localPlayer) then
        lastElement = false
        return
    end

    local sx, sy, sz = getPedTargetStart(localPlayer)
    local ex, ey, ez = getPedTargetEnd(localPlayer)

    local hit, x, y, z, element = processLineOfSight(sx, sy, sz, ex, ey, ez, false, true, true, false, false, true, true, true, localPlayer, true)
    if not element then
        lastElement = false
        return
    end

    if element ~= lastElement then
        currentAction = 1
        lastElement = element
    end

    local elementType = getElementType(element)
    local options = dryerOptions[elementType]
    if not options or #options == 0 then return end

    local text = dryerTexts[elementType]
    if not text then return end

    text = text(element)
    local action = options[currentAction]

    dxDrawText(('< %s >'):format(action.name), scx/2 + 1, scy - 260/zoom + 1, nil, nil, tocolor(0, 0, 0, 200), 1, fonts[1], 'center', 'bottom', false, false, false, true)
    dxDrawText(('< %s >'):format(action.name), scx/2, scy - 260/zoom, nil, nil, tocolor(255, 255, 255, 200), 1, fonts[1], 'center', 'bottom', false, false, false, true)
    
    dxDrawText(text, scx/2 + 1, scy - 50/zoom + 1, nil, nil, tocolor(0, 0, 0, 200), 1, fonts[2], 'center', 'bottom', false, false, false, true)
    dxDrawText(text, scx/2, scy - 50/zoom, nil, nil, tocolor(255, 255, 255, 200), 1, fonts[2], 'center', 'bottom', false, false, false, true)
end, true, 'low-9999')

addEventHandler('onClientKey', root, function(key, state)
    if not doesPlayerHavePermission(localPlayer, 'dryer') then return end
    if key ~= 'mouse_wheel_down' and key ~= 'mouse_wheel_up' and key ~= 'mouse1' then return end
    if not state then return end

    if not lastElement then return end
    local elementType = getElementType(lastElement)
    local options = dryerOptions[elementType]
    if not options or #options == 0 then return end

    if key == 'mouse1' then
        triggerServerEvent('dryer:action', resourceRoot, lastElement, currentAction)
        return
    end

    currentAction = currentAction + (key == 'mouse_wheel_up' and 1 or -1)
    if currentAction > #options then
        currentAction = 1
    elseif currentAction < 1 then
        currentAction = #options
    end
end)

addEventHandler('onClientPlayerWeaponFire', root, function()
    if source ~= localPlayer and not doesPlayerHavePermission(localPlayer, 'dryer') then return end
end)