addEvent('dryer:action', true)
addEventHandler('dryer:action', resourceRoot, function(element, actionIndex)
    if not doesPlayerHavePermission(client, 'dryer') then
        exports['m-notis']:addNotification(client, 'error', 'Suszarka', 'Nie posiadasz uprawnień do korzystania z suszarki.')
        return
    end

    if not isElement(element) then
        exports['m-notis']:addNotification(player, 'info', 'Suszarka', 'Element nie istnieje.')
        return
    end

    local elementType = getElementType(element)
    local options = dryerOptions[elementType]
    if not options or #options == 0 then return end
    
    local action = options[actionIndex]
    if not action then return end
    
    action.action(client, element)
end)