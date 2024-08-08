local lockedElementDatas = {
    'player:uid', 'player:id',
    'player:premium', 'player:avatar', 'player:skin',
    'player:spawn', 'player:logged', 'player:organization',
    'player:level', 'player:exp', 'player:rank',
    'player:mute', 'player:muteAdmin', 'player:muteReason',
    'player:takenLicense', 'player:takenLicenseAdmin', 'player:takenLicenseReason',
    'player:triggerLocked', 'player:dailyRewardDay', 'player:dailyRewardRedeem',
    'player:time', 'player:session', 'player:achievements', 
    'player:attachedVehicle', 'player:attachVehicle', 'player:occupiedVehicle',
    'player:job', 'player:job-hash', 'player:job-players', 'player:job-end', 'player:job-earned', 'player:job-start',
    'player:equippedFishingRod',
    
    'vehicle:uid', 'vehicle:owner', 'vehicle:sharedPlayers', 'vehicle:sharedGroups',
    'vehicle:additionalSeats', 'vehicle:job',

    'element:model', 'element:ghostmode',
    'blip:hoverText', 'redirected',
}

local selfElementDatas = {
    'player:afk', 'player:gameTime', 'player:gameInterval', 'player:blockedDMs', 'player:blockedDMsReason',
    'player:hiddenHUD', 'player:hiddenRadar', 'player:hiddenNametags',
    'player:blockedPremiumChat', 'player:interfaceSize', 'player:typing'
}

local selfVehicleElementDatas = {
    'vehicle:dirtLevel', 'vehicle:dirtProgress', 'vehicle:dirtTime', 'vehicle:onOffroad'
}

function table.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end

    return false
end

addEventHandler('onElementDataChange', root, function(dataName, oldValue)
    if client and getElementData(client, 'player:triggerLocked') then
        setElementData(source, dataName, oldValue)
        return
    end

    if client and getElementType(source) == 'jobMultipliersManager' then
        setElementData(source, dataName, oldValue)
        setPlayerTriggerLocked(client, true, 'Tried to change job multipliers manager element data')
        return
    end

    local playerVehicle = client and getPedOccupiedVehicle(client) or false

    if client and table.find(lockedElementDatas, dataName) then
        local newValue = getElementData(source, dataName)
        local message = ('Tried to change locked element data (`%s`, `%s`, `%s`)'):format(dataName, tostring(oldValue), tostring(newValue))
        
        setPlayerTriggerLocked(client, true, message)
        setElementData(source, dataName, oldValue)
    elseif client and getElementType(source) == 'vehicle' and playerVehicle ~= source and table.find(selfVehicleElementDatas, dataName) then
        if not playerVehicle then
            setElementData(source, dataName, oldValue)
            return
        end
        local newValue = getElementData(source, dataName)
        local message = ('Tried to change not self vehicle element data (`%s`, `%s`, `%s`)'):format(dataName, tostring(oldValue), tostring(newValue))
        
        setPlayerTriggerLocked(client, true, message)
        setElementData(source, dataName, oldValue)
    elseif client and client ~= source and table.find(selfElementDatas, dataName) then
        local newValue = getElementData(source, dataName)
        local message = ('Tried to change not self element data (`%s`, `%s`, `%s`)'):format(dataName, tostring(oldValue), tostring(newValue))
        
        setPlayerTriggerLocked(client, true, message)
        setElementData(source, dataName, oldValue)
    end
end)