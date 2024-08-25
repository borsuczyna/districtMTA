addEvent('fishing:finish', true)
addEvent('fishing:catchFish', true)

addEventHandler('fishing:finish', root, function(success)
    setFishingUIVisible(false)

    triggerServerEvent('fishing:catchFish', resourceRoot, tonumber(success) == 1)
end)

addEventHandler('fishing:catchFish', resourceRoot, function(icon)
    setFishingUIVisible(true, icon)
end)

setPlayerHudComponentVisible('radar', true)
bindKey('mouse1', 'down', function()
    if isCursorShowing() then return end
    
    local itemHash = getElementData(localPlayer, 'player:equippedFishingRod')
    if not itemHash then return end

    local x, y, z = getPositionFromElementOffset(localPlayer, 0, 3.5, 0)
    local px, py, pz = getElementPosition(localPlayer)

    if
        z > 15 or
        not isLineOfSightClear(x, y, z, x, y, 0) or
        not isLineOfSightClear(px, py, pz, x, y, z) or
        isElementInWater(localPlayer)
    then
        exports['m-notis']:addNotification('error', 'Łowienie', 'Nie możesz wędkować w tym miejscu')
        return
    end

    triggerServerEvent('fishing:start', resourceRoot, itemHash)
end)