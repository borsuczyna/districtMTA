function onDebugMessage(message)
    if string.find(message, 'unexcepted change') or string.find(message, 'Error loading COL') then
        setElementData(localPlayer, 'player:gameTime', 98)
    elseif string.find(message, 'Unsafe function was called') then
        setElementData(localPlayer, 'player:gameTime', 99)
    end
end

addEventHandler('onClientDebugMessage', root, onDebugMessage)