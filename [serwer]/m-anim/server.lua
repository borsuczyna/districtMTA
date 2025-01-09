addEvent('anim:saveAnimation', true)
addEvent('animations:getServerTick', true)

addEventHandler('anim:saveAnimation', resourceRoot, function(name, data)
    if not name or not data then return end

    local file = fileCreate(('animations/%s.json'):format(name))
    if not file then return end
    
    fileWrite(file, toJSON(data))
    fileClose(file)
end)

function setPedAnimation(ped, animation, looping)
    looping = looping == nil and true or looping

    setElementData(ped, 'element:animations', {{name = animation, startTime = getTickCount(), looping = looping}})
end

function addPedAnimation(ped, animation, looping)
    looping = looping == nil and true or looping

    local animations = getElementData(ped, 'element:animations') or {}
    table.insert(animations, {name = animation, startTime = getTickCount(), looping = looping})
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

addEventHandler('animations:getServerTick', root, function()
    triggerClientEvent(client, 'animations:serverTickResponse', resourceRoot, getTickCount())
end)

clearPedAnimations(getRandomPlayer())
setTimer(function()
    setPedAnimation(getRandomPlayer(), 'inspect', false)
end, 500, 1)