local animationsData = {}

function angleDifference(a, b)
    local diff = a - b
    while diff < -180 do diff = diff + 360 end
    while diff > 180 do diff = diff - 360 end
    return diff
end

local function getAnimationData(name)
    if not animationsData[name] then
        local file = fileOpen(('animations/%s.json'):format(name))
        if not file then return false end

        local size = fileGetSize(file)
        local data = fileRead(file, size)
        fileClose(file)
    
        animationsData[name] = fromJSON(data)
    end

    return animationsData[name]
end

function updateAnimationBone(ped, bone, items, frame)
    if not items then return end

    local item = table.find(items, function(item) return item.time == frame end)
    local previousItem = false
    local nextItem = false
    local firstItem = false

    for _, i in pairs(items) do
        if not firstItem or i.time < firstItem.time then
            firstItem = i
        end
    end

    if not item then
        for _, i in pairs(items) do
            if i.time < frame and (not previousItem or i.time > previousItem.time) then
                previousItem = i
            elseif i.time > frame and (not nextItem or i.time < nextItem.time) then
                nextItem = i
            end
        end
    else
        previousItem = item
        nextItem = item
    end

    if not previousItem and not nextItem then return end
    if not nextItem then
        nextItem = {
            time = 100,
            rx = firstItem.rx,
            ry = firstItem.ry,
            rz = firstItem.rz
        }
    end
    if not previousItem then previousItem = nextItem end

    local time = frame
    local pTime = previousItem.time
    local nTime = nextItem.time

    local progress = (time - pTime) / (nTime - pTime)
    if progress ~= progress then progress = 0 end
    progress = math.max(0, math.min(1, progress))

    local easing = nextItem.easing or 'Linear'
    -- local rx, ry, rz = interpolateBetween(
    --     previousItem.rx, previousItem.ry, previousItem.rz,
    --     nextItem.rx, nextItem.ry, nextItem.rz,
    --     progress, easing
    -- )
    local xDiff, yDiff, zDiff = angleDifference(nextItem.rx, previousItem.rx), angleDifference(nextItem.ry, previousItem.ry), angleDifference(nextItem.rz, previousItem.rz)
    local progress = getEasingValue(progress, easing)
    local rx, ry, rz = previousItem.rx + xDiff * progress, previousItem.ry + yDiff * progress, previousItem.rz + zDiff * progress

    setElementBoneRotation(ped, bone, rx, ry, rz)
end

function updateAnimationBonesForPed(ped, animation, startTime)
    local frame = (getTickCount() - startTime) / animation.time * 100 % 100

    for bone, items in pairs(animation.bones) do
        updateAnimationBone(ped, bone, items, frame)
    end

    updateElementRpHAnim(ped)
end

function updatePedAnimation(ped)
    local animations = getElementData(ped, 'element:animations')
    if not animations then return end

    for _, animation in pairs(animations) do
        local data = getAnimationData(animation.name)
        if not data then return end

        if not animation.startTime then
            animation.startTime = getTickCount()
        end

        updateAnimationBonesForPed(ped, data, animation.startTime)
    end
end

function updatePedsAnimations()
    for _, ped in pairs(getElementsByType('ped'), root, true) do
        updatePedAnimation(ped)
    end

    for _, ped in pairs(getElementsByType('player'), root, true) do
        updatePedAnimation(ped)
    end
end

function setPedAnimation(ped, animation)
    setElementData(ped, 'element:animations', {{name = animation, startTime = getTickCount()}})
end

function addPedAnimation(ped, animation)
    local animations = getElementData(ped, 'element:animations') or {}
    table.insert(animations, {name = animation, startTime = getTickCount()})
    setElementData(ped, 'element:animations', animations)
end

function removePedAnimation(ped, animationName)
    local animations = getElementData(ped, 'element:animations') or {}
    local newAnimations = {}

    for _, animation in pairs(animations) do
        if animation.name ~= animationName then
            table.insert(newAnimations, animation)
        end
    end

    setElementData(ped, 'element:animations', newAnimations)
end

function clearPedAnimations(ped)
    setElementData(ped, 'element:animations', nil)
end

addEventHandler('onClientPedsProcessed', root, updatePedsAnimations)