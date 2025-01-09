bindKey('F3', 'down', function()
    if not getElementData(localPlayer, 'player:spawn') then return end
    showCursor(not isCursorShowing(), false)
end)