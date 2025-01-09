local missileData = false
local missile = getCustomMapObject('missile')
local fire = getCustomMapObject('fire')
local missileSound = false;
applyFireEffect(fire)

function playMissileAnimation(id)
    if not isElement(missile) or not isElement(fire) then
        return
    end

    local x, y, z = getElementPosition(missile)
    local rx, ry, rz = getElementRotation(missile)
    local fx, fy, fz = getElementPosition(fire)
    local frx, fry, frz = getElementRotation(fire)

    missileData = {
        id = id,
        start = {x = x, y = y, z = z, rx = rx, ry = ry, rz = rz},
        fire = {x = fx, y = fy, z = fz, rx = frx, ry = fry, rz = frz},
        time = getTickCount(),
        nextSmoke = getTickCount(),
        smokeId = 0
    }

    if not isEventHandlerAdded('onClientHUDRender', root, renderMissile) then
        addEventHandler('onClientHUDRender', root, renderMissile)
    end

    if id == 1 then
        missileSound = playSound3D('data/sounds/rocket.wav', x, y, z, false)
        attachElements(missileSound, missile)
        setSoundVolume(missileSound, 5)
        setSoundMinDistance(missileSound, 150)
        setSoundMaxDistance(missileSound, 2000)
        setSoundSpeed(missileSound, settings.eventSpeed * 0.8)
    elseif id == 2 then
        settings.eventSpeed = 1

        if isElement(missileSound) then
            destroyElement(missileSound)
        end

        missileSound = playSound3D('data/sounds/launch.wav', x, y, z, false)
        attachElements(missileSound, missile)
        setSoundVolume(missileSound, 5)
        setSoundMinDistance(missileSound, 150)
        setSoundMaxDistance(missileSound, 2500)
        setSoundSpeed(missileSound, settings.eventSpeed)
    end
end

function playMissileAlarm(id, speed)
    local x, y, z = getElementPosition(missile)
    local alarm = playSound3D('data/sounds/alarm' .. id .. '-echo.wav', x, y, z, false)
    setSoundMinDistance(alarm, 250)
    setSoundMaxDistance(alarm, 1500)
    setSoundVolume(alarm, 2)
    setSoundSpeed(alarm, settings.eventSpeed * (speed or 1))
end

function missileStart()
    if not isElement(missile) or not isElement(fire) then
        return
    end

    local timeElapsed = (getTickCount() - missileData.time) * 1
    if timeElapsed > 30000 / settings.eventSpeed then
        playMissileAnimation(2)
        return
    end

    local progress = timeElapsed / (30000 / settings.eventSpeed)

    local x, y, z = interpolateBetween(missileData.start.x, missileData.start.y, missileData.start.z, missileData.start.x, missileData.start.y, 1000, progress, 'InOutQuad')
    local fx, fy, fz = interpolateBetween(missileData.fire.x, missileData.fire.y, missileData.fire.z, missileData.fire.x, missileData.fire.y, 1000 - 295, progress, 'InOutQuad')
    
    local fireLength, smokeLength, totalLength, alpha;
    if progress < 0.7 then
        local progress = progress/0.7
        fireLength, smokeLength, totalLength = interpolateBetween(40, 20, 60, 140*2, 100*2, 580, progress, 'InOutQuad')
        alpha = 1
    else
        local progress = (progress-0.7)/0.3
        fireLength, smokeLength, totalLength = interpolateBetween(140*2, 100*2, 580, 0, 0, 580, progress, 'InOutQuad')
        alpha = 1 - progress / 2
    end

    setElementPosition(missile, x, y, z)
    setElementPosition(fire, fx, fy, fz)
    setFireEffectProperties(fire, fireLength, smokeLength, totalLength, alpha)

    local bloomZ = math.max(z - 200, 50)
    local bloom2Z = math.max(z - 350, 50)
    local bloomAlpha = math.max(math.min((timeElapsed - 6000) / 3000, 1), 0)

    drawRealistic3DBloom({
        startPos = {x, y, z},
        endPos = {x, y, bloomZ},
        startColor = {255, 255, 55},
        endColor = {255, 255, 0},
        startAlpha = 30 * bloomAlpha * alpha,
        endAlpha = 10 * bloomAlpha * alpha,
        startThickness = 2,
        endThickness = 6,
        steps = 5
    })

    if missileData.nextSmoke and getTickCount() > missileData.nextSmoke then
        missileData.nextSmoke = getTickCount() + (2000 / settings.eventSpeed)
        missileData.smokeId = missileData.smokeId + 1

        if missileData.smokeId == 1 then
            createSmokeExplosion({
                position = {x, y, z - 10},
                count = 50,
                minSize = 4.5,
                maxSize = 15.5,
                size = 2,
                drawSize = 7,
                fallSpeed = 0.3,
                fallSpeedHorizontal = 0.1,
                liveTime = 8000
            })
        elseif missileData.smokeId == 2 then
            createSmokeExplosion({
                position = {x, y, z - 10},
                count = 15,
                minSize = 2.5,
                maxSize = 15.5,
                size = 4,
                drawSize = 7,
                fallSpeed = 0.7,
                fallSpeedHorizontal = 0.2,
                liveTime = 6000
            })
        elseif missileData.smokeId < 45 then
            local isOdd = missileData.smokeId % 2 == 1
            createSmokeExplosion({
                position = {x, y, z - 25},
                count = 5,
                minSize = isOdd and 0.5 or 7.5,
                maxSize = isOdd and 10.5 or 15,
                size = 2,
                drawSize = 7,
                fallSpeed = isOdd and 1 or 0.3,
                fallSpeedHorizontal = 0.7,
                liveTime = 7000,
                startVelocity = {0, 0, isOdd and -0.4 or -0.1},
                appearTime = 400
            })
            missileData.nextSmoke = getTickCount() + (200 / settings.eventSpeed)
        end
    end
end

function createMissileRift()
    createFlash({
        position = {463.20001, 1528.1, 1268},
        time = 60,
        size = 600,
    })
    
    createFlash({
        position = {463.20001, 1528.1, 1268},
        time = 140,
        size = 1000,
    })
    
    createFlash({
        position = {463.20001, 1528.1, 1268},
        time = 200,
        size = 600,
    })
    
    createFlash({
        position = {463.20001, 1528.1, 1268},
        time = 300,
        size = 600,
    })
    
    setTimer(function()
        createRift({
            position = {443.20001, 1628.1, 1158.50717},
            showTime = 500 / settings.eventSpeed,
            liveTime = 3000 / settings.eventSpeed,
            dissolveTime = 3000 / settings.eventSpeed,
            radius = 920,
            splashSize = 100
        })
    end, 300 / settings.eventSpeed, 1)
    
    -- setTimer(function()
    --     createFlash({
    --         position = {843.20001, 1228.1, 1158.50717},
    --         time = 60,
    --         size = 600,
    --     })
        
    --     createFlash({
    --         position = {843.20001, 1228.1, 1158.50717},
    --         time = 140,
    --         size = 1000,
    --     })
        
    --     createFlash({
    --         position = {843.20001, 1228.1, 1158.50717},
    --         time = 200,
    --         size = 600,
    --     })
        
    --     createFlash({
    --         position = {843.20001, 1228.1, 1158.50717},
    --         time = 300,
    --         size = 600,
    --     })

    --     playMissileAnimation(3)
    -- end, 6300 / settings.eventSpeed, 1)

    -- setTimer(playMissileAnimation, 6300 / settings.eventSpeed, 1, 3)
    setTimer(createHole, 6300 / settings.eventSpeed, 1)
end

function missileStartTwo()
    local timeElapsed = (getTickCount() - missileData.time) * 1
    if timeElapsed > 2000 / settings.eventSpeed then
        destroyElementWithLOD(missile)
        destroyElementWithLOD(fire)
        -- setElementAlphaWithLOD(missile, 0)
        -- setElementAlphaWithLOD(fire, 0)
        createMissileRift()
        missileData = false
        return
    end

    local progress = timeElapsed / (2000 / settings.eventSpeed)

    local x, y, z = interpolateBetween(missileData.start.x, missileData.start.y, missileData.start.z, missileData.start.x, missileData.start.y, 1300, progress, 'InQuad')
    local fx, fy, fz = interpolateBetween(missileData.fire.x, missileData.fire.y, missileData.fire.z, missileData.fire.x, missileData.fire.y, 1300 - 295, progress, 'InQuad')

    setElementPosition(missile, x, y, z)

    local fireLength, smokeLength, totalLength = interpolateBetween(0, 0, 580, 150, 150, 580, progress, 'InQuad')
    local alpha = 0.5 - progress / 2

    setElementPosition(missile, x, y, z)
    setElementPosition(fire, fx, fy, fz)
    setFireEffectProperties(fire, fireLength, smokeLength, totalLength, alpha)

    if missileData.nextSmoke and getTickCount() > missileData.nextSmoke then
        missileData.nextSmoke = getTickCount() + (300 / settings.eventSpeed)
        missileData.smokeId = missileData.smokeId + 1

        if missileData.smokeId == 1 then
            createSmokeExplosion({
                position = {x, y, z - 15},
                count = 100,
                minSize = 4.5,
                maxSize = 15.5,
                size = 7,
                drawSize = 10,
                fallSpeed = 1.5,
                fallSpeedHorizontal = 0.1,
                liveTime = 8000
            })
        elseif missileData.smokeId < 20 then
            createSmokeExplosion({
                position = {x, y, z - 10},
                count = 5,
                minSize = 2.5,
                maxSize = 15.5,
                size = 3,
                drawSize = 10,
                fallSpeed = 1.5,
                fallSpeedHorizontal = 0.2,
                liveTime = 4000
            })

            missileData.nextSmoke = getTickCount() + (200 / settings.eventSpeed)
        end
    end
end

function missileStartThree()
    local timeElapsed = (getTickCount() - missileData.time) * 1
    if timeElapsed > 10000 / settings.eventSpeed then
        removeEventHandler('onClientHUDRender', root, renderMissile)
        return
    end

    local progress = timeElapsed / (10000 / settings.eventSpeed)

    -- local x, y, z = interpolateBetween(missileData.secondFire.x, missileData.secondFire.y, missileData.secondFire.z, missileData.secondFire.x, missileData.secondFire.y, 1300, progress, 'InQuad')
    -- local fx, fy, fz = interpolateBetween(missileData.secondFire.x, missileData.secondFire.y, missileData.secondFire.z, missileData.secondFire.x, missileData.secondFire.y, 1300 - 295, progress, 'InQuad')
end

function renderMissile()
    if not missileData then
        removeEventHandler('onClientHUDRender', root, renderMissile)
        return
    end

    if missileData.id == 1 then
        missileStart()
    elseif missileData.id == 2 then
        missileStartTwo()
    elseif missileData.id == 3 then
        missileStartThree()
    end
end