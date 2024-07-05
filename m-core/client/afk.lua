addEventHandler('onClientMinimize', root, function()
    setElementData(localPlayer, 'player:afk', true)
    createTrayNotification("Zminimalizowano grę, został tobie nadany status AFK.", "warning", false)
end)

addEventHandler('onClientRestore', root, function()
    if getElementData(localPlayer, 'player:afk') then
        setElementData(localPlayer, 'player:afk', false)
    end
end)