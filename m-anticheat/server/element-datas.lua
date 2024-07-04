local lockedElementDatas = {
    'player:fingerprint', 'player:uid', 'player:id',
    'player:premium', 'player:avatar', 'player:skin',
    'player:spawn', 'player:logged', 'player:organization',
    'player:level', 'player:exp', 'player:rank',
    'player:mute', 'player:muteAdmin', 'player:muteReason',
    'player:takenLicense', 'player:takenLicenseAdmin', 'player:takenLicenseReason',
    'player:triggerLocked', 
    
    'vehicle:uid', 'vehicle:owner', 'vehicle:sharedPlayers', 'vehicle:sharedGroups',
}

addEventHandler('onElementDataChange', root, function(dataName, oldValue)
    if client and getElementData(client, 'player:triggerLocked') then
        setElementData(source, dataName, oldValue)
        return
    end

    if client and table.find(lockedElementDatas, dataName) then
        local newValue = getElementData(source, dataName)
        local message = ('Tried to change locked element data (`%s`, `%s`, `%s`)'):format(dataName, tostring(oldValue), tostring(newValue))
        
        setPlayerTriggerLocked(client, true, message)
        setElementData(source, dataName, oldValue)
    end
end)