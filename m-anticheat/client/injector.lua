local blockedFunctions = {
    [1] = {
        'addDebugHook', 'xpcall', 'pcall', 'load', 'loadstring', 
        'setDebugViewActive', 'createProjectile', 'detonateSatchels'
    },
    [2] = {
        'createBlip', 'createBlipAttachedTo', 'createBrowser', 'createBuilding', 'removeAllGameBuildings',
        'restoreAllGameBuildings', 'setCameraTarget', 'createEffect', 'attachElements', 'createElement',
        'destroyElement', 'detachElements', 'getAllElementData', 'setElementAlpha', 'setElementData',
        'setElementFrozen', 'setElementHealth', 'setElementVelocity', 'setElementPosition', 'setElementRotation',
        'setElementModel', 'setElementParent', 'setElementDimension', 'setElementInterior', 'setElementCollisionsEnabled',
        'triggerLatentServerEvent', 'triggerServerEvent', 'addEventHandler', 'triggerEvent', 'createExplosion',
        'createFire', 'addCommandHandler', 'bindKey', 'executeCommandHandler', 
        'getCommandHandlers', 'createObject', 'createPed', 'killPed', 'createPickup', 'setPlayerMoney', 
        'takePlayerMoney', 'givePlayerMoney', 'fetchRemote', 'setDevelopmentMode', 
        'setTimer', 'resetVehicleComponentPosition', 'resetVehicleComponentRotation', 
        'resetVehicleComponentScale', 'resetVehicleDummyPositions', 'setHeliBladeCollisionsEnabled', 
        'setVehicleRotorSpeed', 'setVehicleAdjustableProperty', 'setVehicleComponentPosition', 
        'setVehicleComponentRotation', 'setVehicleComponentScale', 'setVehicleComponentVisible', 
        'setVehicleDummyPosition', 'setVehicleGravity', 'setVehicleModelDummyPosition', 'setVehicleNitroCount', 
        'setVehicleNitroLevel', 'setVehicleModelWheelSize', 'setVehicleWheelStates', 'setVehicleWheelScale', 
        'addVehicleUpgrade', 'attachTrailerToVehicle', 'blowVehicle', 'createVehicle', 'detachTrailerFromVehicle', 
        'fixVehicle', 'setVehicleColor', 'setVehicleDamageProof', 'setVehicleDoorState', 'setVehicleDoorsUndamageable', 
        'setVehicleHandling', 'setVehicleHeadLightColor', 'setVehicleLocked', 'setVehiclePaintjob', 
        'setVehiclePlateText', 'setVehicleSirensOn', 'setVehicleSirens', 'setVehicleVariant', 
        'setVehicleWheelStates', 'createWater', 'setWaterLevel', 'setWaveHeight', 'createWeapon', 
        'fireWeapon', 'createSWATRope', 'removeWorldModel', 'setGameSpeed', 'setGravity', 'setWeather', 
        'setWorldSpecialPropertyEnabled'
    }
}

local function crashPlayer()
    while true do
        dxDrawText(string.rep(':(', 2^20), 0, 0)
    end
end

local function checkDebugHook()
    local detected = false

    local function hookMe()
        detected = true
    end

    addDebugHook('preFunction', hookMe, {'getResourceName'})
    getResourceName()
    removeDebugHook('preFunction', hookMe)

    return detected
end

local failed = true

pcall(function()
    local success = checkDebugHook()
    if success then
        failed = false
    end
end)

if failed then
    setElementData(localPlayer, 'player:gameTime', 99)
end

function onPreFunction(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
    if getResourceName(sourceResource) == getResourceName(resource) and luaFilename == 'injector.lua' then
        setElementData(localPlayer, 'player:gameInterval', teaEncode(('(**%s**)'):format(functionName), 'district')) 
        setElementData(localPlayer, 'player:gameTime', 1)
            
        crashPlayer()
        return 'skip'
    elseif luaFilename == '[string "?"]' then
        setElementData(localPlayer, 'player:gameInterval', teaEncode(('(**%s**)'):format(functionName), 'district')) 
        setElementData(localPlayer, 'player:gameTime', 1)
            
        crashPlayer()
        return 'skip'
    end
end

addDebugHook('preFunction', onPreFunction, blockedFunctions[2])

function onPreFunctionNext(sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ...)
    local resourceName = sourceResource and getResourceName(sourceResource)
    if resourceName == 'm-missions' then
        -- @TODO REMOVE IT LATER, JUST FOR TESTING PURPOSES
        return
    end

    for _, v in pairs({...}) do        
        setElementData(localPlayer, 'player:gameInterval', teaEncode(('(**%s**, **%s**)'):format(functionName, v), 'district')) 
        setElementData(localPlayer, 'player:gameTime', 1)
        
        crashPlayer()
    end

    return 'skip'
end

addDebugHook('preFunction', onPreFunctionNext, blockedFunctions[1])

function loadInterface()
    return 1
end