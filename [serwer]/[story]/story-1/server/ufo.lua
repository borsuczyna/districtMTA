local hole = {843.20001, 1228.1, 1058.50717, 300}
local ufos, destroyedUfos, mainUfo, mainUfoDestroyed = {}, {}, false, false
local ufoHealth = {}

function randomMoveUfo(object)
    if not isElement(object) then return end
    if table.includes(destroyedUfos, object) then return end
    
    mx, my, mz = math.random(-365.672, 605.213), math.random(1219.688, 1596.620), math.random(150, 450)
    local x, y, z = getElementPosition(object)
    local distance = getDistanceBetweenPoints3D(mx, my, mz, x, y, z)

    local moveTime = distance / settings.eventSpeed * 20
    moveObject(object, moveTime + math.random(1000, 5000), mx, my, mz, 0, 0, 0, 'InOutQuad')
    setTimer(randomMoveUfo, moveTime, 1, object)
end

function areAllUfosDestroyed()
    for _, ufo in pairs(ufos) do
        if not table.includes(destroyedUfos, ufo) then
            return false
        end
    end
    return true
end

function createUfo(main)
    local object = createObject(1339, hole[1], hole[2], hole[3])
    setElementData(object, 'element:model', main and 'ufo2' or 'ufo')
    setObjectScale(object, 2)
    assignLOD(object)

    local mx, my, mz

    if main then
        local mx, my, mz = hole[1] - 800, hole[2] + 100, hole[3] - 500
        moveObject(object, 30000 / settings.eventSpeed, mx, my, mz, 0, 0, 0, 'InOutQuad')
        mainUfo = object
    else
        randomMoveUfo(object)
        table.insert(ufos, object)
    end

    triggerClientEvent('story:setMissionTarget', resourceRoot, 'Zniszcz małe statki ufo')
end

function table.includes(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function destroyUfo(ufo, destroyPos)
    -- local lod = getLowLODElement(ufo)
    -- destroyElement(ufo)
    -- destroyElement(lod)

    table.insert(destroyedUfos, ufo)
    local rot = math.random(-80, 80)
    while rot > -20 and rot < 20 do
        rot = math.random(-80, 80)
    end

    moveObject(ufo, 5650, destroyPos[1], destroyPos[2], destroyPos[3] + 10, 0, rot, math.random(-2000, 2000), 'InQuad')

    local x, y, z = getElementPosition(ufo)
    triggerClientEvent('story:playExplosion', resourceRoot, x, y, z - 20, 0, 0, 0, true)

    setTimer(triggerClientEvent, 5650, 1, 'story:playExplosion', resourceRoot, destroyPos[1], destroyPos[2], destroyPos[3], 0, 0, 2)

    if areAllUfosDestroyed() then
        triggerClientEvent('story:setMissionTarget', resourceRoot, 'Zniszcz statek matkę ufo')
    end
end

function onMainUfoHit(player, ufo, destroyPos)
    if not ufoHealth[ufo] then
        ufoHealth[ufo] = 100
    end

    ufoHealth[ufo] = ufoHealth[ufo] - (1 / #getElementsByType('player'))

    if ufoHealth[ufo] <= 0 then
        destroyUfo(ufo, destroyPos)
        mainUfoDestroyed = true
        triggerClientEvent('story:setMissionTarget', resourceRoot, '')
        setTimer(finishEvent, 30000 / settings.eventSpeed, 1)
    end
end

function onUfoHit(player, ufo, destroyPos)
    if mainUfo == ufo then
        if not areAllUfosDestroyed() then return end
        if mainUfoDestroyed then return end

        onMainUfoHit(player, ufo, destroyPos)
    end

    if not table.includes(ufos, ufo) then return end
    if table.includes(destroyedUfos, ufo) then return end

    if not ufoHealth[ufo] then
        ufoHealth[ufo] = 100
    end

    local players = #getElementsByType('player')
    ufoHealth[ufo] = ufoHealth[ufo] - (1.5 / players)

    if ufoHealth[ufo] <= 0 then
        destroyUfo(ufo, destroyPos)
    end
end

function startUfos()
    createUfo(true)
    -- startAntiAircraft()
    setTimer(startAntiAircraft, 20000, 1)
    setTimer(createUfo, 1000 / settings.eventSpeed, 10, false)
end