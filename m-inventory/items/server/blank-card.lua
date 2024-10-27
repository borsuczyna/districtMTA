function onBlankCardUse(player, itemHash)
    triggerEvent('carding:sendData', player, itemHash)
    return -1
end