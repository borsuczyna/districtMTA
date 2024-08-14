function setLoadingVisible(player, visible, text, time)
    if not isElement(player) then return end
    triggerClientEvent(player, 'loading:setVisible', resourceRoot, visible, text, time)
end