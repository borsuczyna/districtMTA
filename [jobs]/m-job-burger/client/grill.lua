addEvent('jobs:burger:grill', true)
addEvent('jobs:burger:grillBurn', true)
addEvent('jobs:burger:grilled', true)

local grills = {}
local grillsData = {}
local effects = {}
-- local renderTarget = false

-- function createGrillRenderTarget()
--     if renderTarget then return end

--     renderTarget = dxCreateRenderTarget(512, 512, true)
-- end

-- function destroyGrillRenderTarget()
--     if not renderTarget then return end

--     destroyElement(renderTarget)
--     renderTarget = false
-- end

-- function updateGrillRenderTarget(progress)
--     dxSetRenderTarget(renderTarget, true)
    
-- end

addEventHandler('jobs:burger:grill', resourceRoot, function(grillId, objectHash, data)
    if grills[grillId] then
        destroyElement(grills[grillId])
    end
    
    if effects[grillId] then
        destroyElement(effects[grillId])
    end

    grillsData[grillId] = nil
    effects[grillId] = nil
    grills[grillId] = nil

    if objectHash then
        local grillObject = exports['m-jobs']:getObjectByHash(objectHash)
        if not grillObject then return end

        local layData = settings.layPositions['burger/grill-meat']
        local ax, ay, az = unpack(layData.position)

        local x, y, z = getPositionFromElementOffset(grillObject, ax, ay, az)
        local object = createObject(1337, x, y, z)
        setElementData(object, 'element:model', 'burger/meat')
        setObjectScale(object, 1.9)
        setElementDimension(object, getElementDimension(localPlayer))
        setElementCollisionsEnabled(object, false)

        grills[grillId] = object
        grillsData[grillId] = data
    end
end)

addEventHandler('jobs:burger:grillBurn', resourceRoot, function(grillId, objectHash)
    if grills[grillId] and isElement(grills[grillId]) then
        setElementData(grills[grillId], 'element:model', 'burger/meat-overcooked')

        local x, y, z = getElementPosition(grills[grillId])
        local effect = createEffect('fire', x, y, z)
        setEffectDensity(effect, 0.2)
        setElementDimension(effect, getElementDimension(localPlayer))

        effects[grillId] = effect
    end
end)

addEventHandler('jobs:burger:grilled', resourceRoot, function(grillId)
    if grills[grillId] and isElement(grills[grillId]) then
        setElementData(grills[grillId], 'element:model', 'burger/meat-cooked')
    end
end)

function drawGrillProgress(grill, data, serverTick)
    local start = data.start
    local finish = data.finish
    local burn = data.burn

    local progress = (serverTick - start) / (finish - start)
    local burning = progress >= 1
    if burning then
        progress = (serverTick - finish) / (burn - finish)
    end

    local clampedProgress = math.min(math.max(progress, 0), 1)

    local x, y, z = getElementPosition(grill)
    local sx, sy = getScreenFromWorldPosition(x, y, z + 0.5)
    if not sx or not sy then return end

    local bounceAnimation = 1
    local color = 0xFFFFFFFF

    if burning then
        local burnProgress = math.min(clampedProgress * 5, 1)
        local animProgress = getEasingValue(burnProgress, 'OutBounce')
        bounceAnimation = 1 + animProgress * 0.5

        local r, g, b = interpolateBetween(255, 255, 255, 255, 0, 0, burnProgress, 'Linear')
        color = tocolor(r, g, b, 255)

        local fr, fg, gb = interpolateBetween(255, 100, 100, 255, 0, 0, (progress * 5) % 1, 'CosineCurve')
        local jump = getEasingValue((progress * 5) % 1, 'CosineCurve')
        animProgress = animProgress + jump * 0.2

        dxDrawImage(sx - 18/zoom * animProgress, sy - 18/zoom * animProgress, 36/zoom * animProgress, 36/zoom * animProgress, 'data/flame.png', 0, 0, 0, tocolor(fr, fg, gb, 255))
    end
    
    dxDrawImage(sx - 26/zoom * bounceAnimation, sy - 26/zoom * bounceAnimation, 52/zoom * bounceAnimation, 52/zoom * bounceAnimation, 'data/stoper-bg.png', 0, 0, 0, 0x99FFFFFF)
    drawCircleImage(sx - 26/zoom * bounceAnimation, sy - 26/zoom * bounceAnimation, 52/zoom * bounceAnimation, 52/zoom * bounceAnimation, 'data/stoper.png', 0, 360 * clampedProgress, color)
end

function updateGrillsCook()
    local serverTick = getServerTick()
    
    for i, grill in pairs(grills) do
        if not isElement(grill) then
            grills[i] = nil
            grillsData[i] = nil
            effects[i] = nil
            return
        end

        local data = grillsData[i]
        if not data then return end

        drawGrillProgress(grill, data, serverTick)
    end
end

function clearGrills()
    for i, grill in ipairs(grills) do
        if isElement(grill) then
            destroyElement(grill)
        end
    end

    for i, effect in ipairs(effects) do
        if isElement(effect) then
            destroyElement(effect)
        end
    end
end