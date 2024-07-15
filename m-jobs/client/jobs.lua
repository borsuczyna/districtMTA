addEvent('jobs:updateObject', true)
addEvent('jobs:updateBlip', true)
addEvent('jobs:destroyObjects', true)
addEvent('jobs:destroyBlips', true)

local objects = {}
local blips = {}

function findElementByHash(array, hash)
    for i, object in ipairs(array) do
        if object.hash == hash then
            return object
        end
    end
end

function _createObject(object)
    local element = createObject(object.model, object.position[1], object.position[2], object.position[3], object.rotation[1], object.rotation[2], object.rotation[3])
    object.element = element

    table.insert(objects, object)
    return findElementByHash(objects, object.hash)
end

function updateObject(object)
    local obj = findElementByHash(objects, object.hash)
    if not obj then
        obj = _createObject(object)
    end

    obj.model = object.model
    obj.position = object.position
    obj.rotation = object.rotation

    setElementModel(obj.element, obj.model)
    setElementPosition(obj.element, obj.position[1], obj.position[2], obj.position[3])
    setElementRotation(obj.element, obj.rotation[1], obj.rotation[2], obj.rotation[3])
end

function destroyArray(array)
    for i, object in ipairs(array) do
        if object.element and isElement(object.element) then
            destroyElement(object.element)
        end
    end
end

function destroyObjects()
    destroyArray(objects)
    objects = {}
end

function _createBlip(blip)
    local element = createBlip(blip.position[1], blip.position[2], blip.position[3], blip.icon, 1, 255, 255, 255, 255, 9999)
    blip.element = element

    table.insert(blips, blip)
    return findElementByHash(blips, blip.hash)
end

function updateBlip(blip)
    local obj = findElementByHash(blips, blip.hash)
    if not obj then
        obj = _createBlip(blip)
    end

    obj.position = blip.position
    obj.icon = blip.icon

    setElementPosition(obj.element, obj.position[1], obj.position[2], obj.position[3])
    setBlipVisibleDistance(obj.element, obj.visibleDistance)
    setBlipIcon(obj.element, obj.icon)
end

function destroyBlips()
    destroyArray(blips)
    blips = {}
end

addEventHandler('jobs:updateObject', resourceRoot, updateObject)
addEventHandler('jobs:destroyObjects', resourceRoot, destroyObjects)
addEventHandler('jobs:updateBlip', resourceRoot, updateBlip)
addEventHandler('jobs:destroyBlips', resourceRoot, destroyBlips)