addEvent('anim:saveAnimation', true)
addEventHandler('anim:saveAnimation', resourceRoot, function(name, data)
    if not name or not data then return end

    local file = fileCreate(('animations/%s.json'):format(name))
    if not file then return end
    
    fileWrite(file, toJSON(data))
    fileClose(file)
end)

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

-- setPedAnimation(getRandomPlayer(), 'test')
clearPedAnimations(getRandomPlayer())