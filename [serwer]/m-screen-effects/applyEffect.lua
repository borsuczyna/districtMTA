screenEffects = {};
screenEffects.settings = {
    data = {},

    effectFunctions = {}
};

sEffects = screenEffects.settings.effectFunctions;
sShaderData = screenEffects.settings.data;

-- DRUNK ANIMATION --

requestDrunkAnimation = function(animationBlock, animationName, aEndTime)
    if animationBlock and animationName and aEndTime then
        triggerServerEvent('onServerApplyDrunkAnimation', resourceRoot, animationBlock, animationName, aEndTime)
    end
end

deleteDrunkAnimation = function()
    triggerServerEvent('onServerDeleteDrunkAnimation', resourceRoot)
end;

sEffects.enableDrunkEffect = function(isEnabled, effectStrength, effectTime)
    if (type(isEnabled) ~= 'boolean' or type(effectStrength) ~= 'number' or type(effectTime) ~= 'number') then
        return
    end

    if not sShaderData.drunkTimer then
        sShaderData.drunkTimer = nil
    end

    if isEnabled then
        enableEffect(4, true)
        setEffectMaxStrength(4, 0, effectStrength)

        if effectTime > 0 then
            if isTimer(sShaderData.drunkTimer) then
                killTimer(sShaderData.drunkTimer)
            end
            
            sShaderData.drunkTimer = setTimer(function()
                enableEffect(4, false)
                requestDrunkAnimation(nil, nil, 0)
                deleteDrunkAnimation()
                sShaderData.drunkTimer = nil
            end, effectTime * 1000, 1)
        end
    else
        enableEffect(4, false)
        requestDrunkAnimation(nil, nil, 0)
        deleteDrunkAnimation()

        if isTimer(sShaderData.drunkTimer) then
            killTimer(sShaderData.drunkTimer)
            sShaderData.drunkTimer = nil
        end
    end
end

sAnimations = {
    alpha = {
        value = 0, 
        handler = nil
    }
}

aAnims = sAnimations.alpha;
aTime = 300

addDrunkEffect = function(...) return sEffects.enableDrunkEffect(...) end;

-- DRUNK ANIMATION --

-- MARIJUANA ANIMATION --

sEffects.enableMarijuanaEffect = function(isEnabled, effectStrength, effectTime)
    if (type(isEnabled) ~= 'boolean' or type(effectStrength) ~= 'number' or type(effectTime) ~= 'number') then
        return
    end

    if not sShaderData.mariTimer then
        sShaderData.mariTimer = nil
    end

    if isEnabled then
        enableEffect(3, true)
        setEffectMaxStrength(3, 0, effectStrength)

        if effectTime > 0 then
            if isTimer(sShaderData.mariTimer) then
                killTimer(sShaderData.mariTimer)
            end
            
            sShaderData.mariTimer = setTimer(function()
                enableEffect(3, false)
                sShaderData.mariTimer = nil
            end, effectTime * 1000, 1)
        end

    else
        enableEffect(3, false)

        if isTimer(sShaderData.mariTimer) then
            killTimer(sShaderData.mariTimer)
            sShaderData.mariTimer = nil
        end
    end
end

addMariEffect = function(...) return sEffects.enableMarijuanaEffect(...) end;

-- MARIJUANA ANIMATION --

-- HEROIN ANIMATION -- 

sEffects.enableHeroinEffect = function(isEnabled, effectStrength, effectTime)
    if (type(isEnabled) ~= 'boolean' or type(effectStrength) ~= 'number' or type(effectTime) ~= 'number') then
        return
    end

    if not sShaderData.heroinTimer then
        sShaderData.heroinTimer = nil
    end

    if isEnabled then
        enableEffect(1, true)
        setEffectMaxStrength(1, 0, effectStrength)
        sEffects.addFakeObjects(true)

        if effectTime > 0 then
            if isTimer(sShaderData.heroinTimer) then
                killTimer(sShaderData.heroinTimer)
            end
            
            sShaderData.heroinTimer = setTimer(function()
                enableEffect(1, false)
                sEffects.addFakeObjects(false)
                sEffects.resetGameLook();
                sShaderData.heroinTimer = nil
            end, effectTime * 1000, 1)
        end

    else
        enableEffect(1, false)
        sEffects.addFakeObjects(false)
        sEffects.resetGameLook()

        if isTimer(sShaderData.heroinTimer) then
            killTimer(sShaderData.heroinTimer)
            sShaderData.heroinTimer = nil
        end
    end
end

sEffects.fakeObjects = {1609, 1608, 1607, 1606, 1605, 1604, 1603, 1602, 1601, 1600, 1599, 1598}
sEffects.activeFakeObjects = {}

sEffects.fakeObjectsRender = function()
    local pPosition = Vector3(getElementPosition(localPlayer))
    local fakeObject = createObject(sEffects.fakeObjects[math.random(#sEffects.fakeObjects)], math.random(pPosition.x-20, pPosition.x+20), math.random(pPosition.y-20, pPosition.y+20), math.random(pPosition.z-20, pPosition.z+20), math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))

    setObjectScale(fakeObject, math.random(10, 1000)/1000, math.random(0.1, 5), math.random(0.1, 5))
    moveObject(fakeObject, 2000, math.random(pPosition.x-20, pPosition.x+20), math.random(pPosition.y-20, pPosition.y+20), math.random(pPosition.z-20, pPosition.z+20))
    table.insert(sEffects.activeFakeObjects, fakeObject)

    setTimer(function() 
        if isElement(fakeObject) then 
            destroyElement(fakeObject) 

            for i, obj in ipairs(sEffects.activeFakeObjects) do
                if obj == fakeObject then
                    table.remove(sEffects.activeFakeObjects, i)
                    break
                end
            end
        end 
    end, 2000, 1)

    setSkyGradient(math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255))
    setWaterColor(math.random(0,255), math.random(0,255), math.random(0, 255), math.random(0, 255))
    setFogDistance(math.random(0,500))
end

sEffects.addFakeObjects = function(isEnabled)
    if isEnabled then
        if not isEventHandlerAdded('onClientRender', root, sEffects.fakeObjectsRender) then
            addEventHandler('onClientRender', root, sEffects.fakeObjectsRender)
        end;
    else
        if isEventHandlerAdded('onClientRender', root, sEffects.fakeObjectsRender) then
            removeEventHandler('onClientRender', root, sEffects.fakeObjectsRender)
        end;
    end;
end;

addHeroinEffect = function(...) return sEffects.enableHeroinEffect(...) end;

-- HEROIN ANIMATION --

-- CRACK ANIMATION --

sEffects.enableCrackEffect = function(isEnabled, effectStrength, effectTime)
    if (type(isEnabled) ~= 'boolean' or type(effectStrength) ~= 'number' or type(effectTime) ~= 'number') then
        return
    end

    if not sShaderData.crackTimer then
        sShaderData.crackTimer = nil
    end

    if isEnabled then
        enableEffect(2, true)
        setEffectMaxStrength(2, 0, effectStrength)
        sEffects.changeCrackView(true)

        if effectTime > 0 then
            if isTimer(sShaderData.crackTimer) then
                killTimer(sShaderData.crackTimer)
            end
            
            sShaderData.crackTimer = setTimer(function()
                enableEffect(2, false)
                sEffects.resetGameLook();
                sEffects.changeCrackView(false)
                sShaderData.crackTimer = nil
            end, effectTime * 1000, 1)
        end

    else
        enableEffect(2, false)
        sEffects.resetGameLook()
        sEffects.changeCrackView(false)

        if isTimer(sShaderData.crackTimer) then
            killTimer(sShaderData.crackTimer)
            sShaderData.crackTimer = nil
        end
    end
end

sEffects.crackWorldView = function()
    setSkyGradient(math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255))
    setWaterColor(math.random(0,255), math.random(0,255), math.random(0,255), math.random(0, 255))
    setFogDistance(math.random(0,500))
end

sEffects.changeCrackView = function(isEnabled)
    if isEnabled then
        if not isEventHandlerAdded('onClientRender', root, sEffects.crackWorldView) then
            addEventHandler('onClientRender', root, sEffects.crackWorldView)
        end;
    else
        if isEventHandlerAdded('onClientRender', root, sEffects.crackWorldView) then
            removeEventHandler('onClientRender', root, sEffects.crackWorldView)
        end;
    end;
end;

addCrackEffect = function(...) return sEffects.enableCrackEffect(...) end;

-- CRACK ANIMATION --

sEffects.resetGameLook = function()
    resetSkyGradient()
    resetWaterColor()
    resetFogDistance()
    resetWindVelocity()
    resetSunColor()
    resetHeatHaze()
end;