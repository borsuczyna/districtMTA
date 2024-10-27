local lockedElementDatas = {
    'player:uid', 'player:id',
    'player:premium', 'player:avatar', 'player:skin',
    'player:spawn', 'player:logged', 'player:organization',
    'player:level', 'player:exp', 'player:duty', 'player:rank', 'player:paint',
    'player:mute', 'player:muteAdmin', 'player:muteReason',
    'player:takenLicense', 'player:takenLicenseAdmin', 'player:takenLicenseReason',
    'player:triggerLocked', 'player:dailyRewardDay', 'player:dailyRewardRedeem',
    'player:afkTime', 'player:time', 'player:session', 'player:achievements', 
    'player:attachedVehicle', 'player:attachVehicle', 'player:occupiedVehicle',
    'player:job', 'player:job-hash', 'player:job-players', 'player:job-end', 'player:job-earned', 'player:job-start',
    'player:equippedFishingRod', 'player:bankMoney', 'player:licenses',
    'player:jailedPosition', 'player:jail', 'player:jailedBy', 'player:jailReason', 'player:handcuffed', 'player:handcuffing',
    'player:mission', 'player:loadMission', 'player:cosmetics',
    'marker:title', 'marker:desc', 'marker:house', 'marker:longDesc', 'marker:enter', 'marker:target',
    'player:house', 'player:editingFurnitures', 'player:holdingFurniture', 'player:animation', 'player:lastActive',
    'player:holdingPackage', 'player:scooter-trace', 'player:mysticHat', 'player:boughtCars', 'player:catchedFishes', 'player:catchedFishesSession',
    'controller', 'element:animations', 'player:afkNow', 'player:deliveredBurgerOrders', 'player:deliveredCourierPackages', 'player:trashDelivered', 'player:packagesDelivered',
    'mission:element', 'missions:vehicleDamageProof', 'marker:manage-faction', 'marker:duty-faction', 'marker:shelf-items',
    'gate:faction', 'gate:object', 'gate:position', 'gate:openBy', 'gate:state', 'gate:time', 'gate:disableCollision',
    'vehicle:carExchange', 'marker:carExchange:prices', 'colshape:carExchange:prices', 'vehicle:custom-upgrades',
    
    'vehicle:uid', 'vehicle:owner', 'vehicle:sharedPlayers', 'vehicle:sharedGroups',
    'vehicle:additionalSeats', 'vehicle:job', 'vehicle:engineCapacity',
    'vehicle:fuelType', 'vehicle:lpg', 'vehicle:lpgState', 'vehicle:lpgFuel', 'vehicle:mileage', 'vehicle:maxFuel', 'vehicle:fuel',
    'vehicle:lastDriver', 

    'element:model', 'element:ghostmode',
    'blip:hoverText', 'redirected', 'area:hoverText', 'area:className',
    'speedcamera:limit',

    'repair:colShape', 'repair:marker', 'repair:state', 'repair:data', 'repair:render', 
    'repair:vehicle', 'repair:time', 'vehicle:repairing', 'player:knownIntros',

    'data',
}

local selfElementDatas = {
    'player:afk', 'player:gameTime', 'player:gameInterval', 'player:blockedDMs', 'player:blockedDMsReason',
    'player:hiddenHUD', 'player:hiddenRadar', 'player:hiddenNametags',
    'player:blockedPremiumChat', 'player:interfaceSize', 'player:typing', 'player:controllerMode',
    'missions:vehicleExitLocked', 'player:inv'
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