function onDebugMessage(message)
    if string.find(message, 'unexcepted change') then
        setElementData(localPlayer, 'player:gameTime', 98)
    elseif string.find(message, 'Unsafe function was called') then
        setElementData(localPlayer, 'player:gameTime', 99)
    end
end

addEventHandler('onClientDebugMessage', root, onDebugMessage)