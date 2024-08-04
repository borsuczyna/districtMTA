local bunnyTimer

addEvent('inventory:onUsePotion', true)
addEventHandler('inventory:onUsePotion', resourceRoot, function()
    setWorldSpecialPropertyEnabled('extrajump', true)
    if bunnyTimer and isTimer(bunnyTimer) then
        killTimer(bunnyTimer)
    end

    bunnyTimer = setTimer(setWorldSpecialPropertyEnabled, 60000, 1, 'extrajump', false)
end)