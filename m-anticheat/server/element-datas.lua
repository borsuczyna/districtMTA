local lockedElementDatas = {
    'player:fingerprint', 'player:uid', 'player:id',
    'player:premium', 'player:avatar', 'player:skin',
    'player:spawn', 'player:logged', 'player:organization',
    'player:level', 'player:exp', 'player:rank',
    'player:mute', 'player:triggerLocked',
}

addEventHandler('onElementDataChange', root, function(dataName, oldValue)
    if client and table.find(lockedElementDatas, dataName) then
        local newValue = getElementData(source, dataName)
        local message = ('Tried to change locked element data (`%s`, `%s`, `%s`)'):format(dataName, tostring(oldValue), tostring(newValue))
        setPlayerTriggerLocked(client, true, message)
    end
end)