addEvent('jobs:updateObjects', true)
addEvent('jobs:destroyObject', true)
addEvent('jobs:updateBlips', true)
addEvent('jobs:destroyBlip', true)
addEvent('jobs:destroyObjects', true)
addEvent('jobs:destroyBlips', true)
addEvent('jobs:updateMarkers', true)
addEvent('jobs:destroyMarker', true)
addEvent('jobs:destroyMarkers', true)
addEvent('jobs:updateData', true)
addEvent('jobs:resetData', true)

local objects = {}
local blips = {}
local markers = {}
local data = {}
local lastEventSend = 0

function findElementByHash(array, hash)
    for i, object in ipairs(array) do
        if object.hash == hash then
            return object
        end
    end
end

function updateColshape(object, colshape)
    if object.colshape and isElement(object.colshape) then
        destroyElement(object.colshape)
    end

    if colshape then
        local size = colshape.size or 2
        local shape = createColSphere(object.position[1], object.position[2], object.position[3], size)
        if colshape.attached then
            attachElements(shape, object.element, 0, 0, 0)
        end

        if colshape.event then
            addEventHandler('onClientColShapeHit', shape, function(hitElement, matchingDimension)
                if hitElement ~= localPlayer or not matchingDimension then return end
                if getTickCount() - lastEventSend < 1000 then return end

                print(getTickCount())
                triggerServerEvent('jobs:colshapeHit', resourceRoot, object.hash)
                lastEventSend = getTickCount()
            end)
        end

        object.colshape = shape
    end
end

addCommandHandler('colsshow', function()
    setDevelopmentMode(true, true)
    showCol(true)
end)

function updateObjectBlip(object, blip)
    if object.blip and isElement(object.blip) then
        destroyElement(object.blip)
    end

    if blip then
        local element = createBlip(object.position[1], object.position[2], object.position[3], blip.icon, 1, 255, 255, 255, 255, blip.visibleDistance)
        if blip.attached then
            attachElements(element, object.element, 0, 0, 0)
        end

        object.blip = element
    end
end

function updateElementAttach(element, attach)
    if attach then
        local x, y, z, rx, ry, rz = unpack(attach.position)
        attachElements(element.element, attach.element, x or 0, y or 0, z or 0, rx or 0, ry or 0, rz or 0)
    else
        detachElements(element.element)
    end
end

function updateObjectBoneAttach(object, attach)
    if attach then
        local player, bone, x, y, z, rx, ry, rz = unpack(attach)
        exports['m-pattach']:attach(object.element, player, bone, x, y, z, rx, ry, rz)
    else
        exports['m-pattach']:detach(object.element)
    end
end

function updateObjectGhost(object, ghost)
    if ghost then
        if not object.ghost or not isElement(object.ghost) then
            object.ghost = createObject(object.model, object.position[1], object.position[2], object.position[3], object.rotation[1], object.rotation[2], object.rotation[3])
            setElementAlpha(object.ghost, 155)
            setElementCollisionsEnabled(object.ghost, false)
        end

        setElementModel(object.ghost, object.model)
        setElementPosition(object.ghost, object.position[1], object.position[2], object.position[3])
        setElementRotation(object.ghost, object.rotation[1], object.rotation[2], object.rotation[3])
    else
        if object.ghost and isElement(object.ghost) then
            destroyElement(object.ghost)
            object.ghost = nil
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
    obj.customData = object.customData

    updateColshape(obj, object.options.colshape)
    updateObjectBlip(obj, object.options.blip)
    updateObjectBoneAttach(obj, object.options.attachBone)
    updateElementAttach(obj, object.options.attach)
    updateObjectGhost(obj, object.options.ghost)

    setElementModel(obj.element, obj.model)
    setElementPosition(obj.element, obj.position[1], obj.position[2], obj.position[3])
    setElementRotation(obj.element, obj.rotation[1], obj.rotation[2], obj.rotation[3])
    setElementFrozen(obj.element, object.options.frozen or false)
end

function destroyObject(hash)
    local obj = findElementByHash(objects, hash)
    if not obj then return end

    if obj.colshape and isElement(obj.colshape) then
        destroyElement(obj.colshape)
    end

    if obj.blip and isElement(obj.blip) then
        destroyElement(obj.blip)
    end

    if obj.ghost and isElement(obj.ghost) then
        destroyElement(obj.ghost)
    end

    if obj.element and isElement(obj.element) then
        destroyElement(obj.element)
    end

    for i, object in ipairs(objects) do
        if object == obj then
            table.remove(objects, i)
            break
        end
    end
end

function getObjectCustomData(hash, key)
    local obj = findElementByHash(objects, hash)
    if not obj then return end

    return obj.customData[key]
end

function destroyArray(array)
    for i, object in ipairs(array) do
        if object.element and isElement(object.element) then
            destroyElement(object.element)
        end
    end
end

function destroyArrayKey(array, key)
    for i, object in ipairs(array) do
        if object[key] and isElement(object[key]) then
            destroyElement(object[key])
        end
    end
end

function destroyObjects()
    destroyArrayKey(objects, 'colshape')
    destroyArrayKey(objects, 'blip')
    destroyArrayKey(objects, 'ghost')
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

    updateElementAttach(obj, blip.options.attach)

    setElementPosition(obj.element, obj.position[1], obj.position[2], obj.position[3])
    setBlipVisibleDistance(obj.element, obj.visibleDistance)
    setBlipIcon(obj.element, obj.icon)
end

function destroyBlip(hash)
    local obj = findElementByHash(blips, hash)
    if not obj then return end

    if obj.element and isElement(obj.element) then
        destroyElement(obj.element)
    end

    for i, object in ipairs(blips) do
        if object == obj then
            table.remove(blips, i)
            break
        end
    end
end

function destroyBlips()
    destroyArray(blips)
    blips = {}
end

function _createMarker(marker)
    local element = createMarker(marker.position[1], marker.position[2], marker.position[3], marker.type, marker.size, marker.color[1], marker.color[2], marker.color[3], marker.color[4])
    marker.element = element

    table.insert(markers, marker)
    return findElementByHash(markers, marker.hash)
end

function updateMarkerEvent(marker, event)
    if marker.event then
        removeEventHandler('onClientMarkerHit', marker.element, marker.eventHandler)
    end

    if event then
        marker.eventHandler = function(hitElement, matchingDimension)
            if hitElement ~= localPlayer or not matchingDimension then return end
            if getTickCount() - lastEventSend < 1000 then return end

            triggerServerEvent('jobs:markerHit', resourceRoot, marker.hash)
            lastEventSend = getTickCount()
        end

        addEventHandler('onClientMarkerHit', marker.element, marker.eventHandler)
    end
end

function updateMarker(marker)
    local obj = findElementByHash(markers, marker.hash)
    if not obj then
        obj = _createMarker(marker)
    end

    obj.position = marker.position
    obj.size = marker.size
    obj.color = marker.color
    obj.type = marker.type

    updateElementAttach(obj, marker.options.attach)
    updateMarkerEvent(obj, marker.options.event)

    setElementPosition(obj.element, obj.position[1], obj.position[2], obj.position[3])
    setMarkerSize(obj.element, obj.size)
    setMarkerColor(obj.element, obj.color[1], obj.color[2], obj.color[3], obj.color[4])
    setMarkerType(obj.element, obj.type)
    setElementData(obj.element, 'marker:icon', marker.options.icon or 'work')
    setElementData(obj.element, 'marker:title', marker.options.title or 'Marker')
    setElementData(obj.element, 'marker:desc', marker.options.desc or 'Marker')
end

function destroyMarker(hash)
    local obj = findElementByHash(markers, hash)
    if not obj then return end

    if obj.element and isElement(obj.element) then
        destroyElement(obj.element)
    end

    for i, object in ipairs(markers) do
        if object == obj then
            table.remove(markers, i)
            break
        end
    end
end

function destroyMarkers()
    destroyArray(markers)
    markers = {}
end

function updateData(key, value)
    data[key] = value
end

function resetData()
    data = {}
end

function getJobData(key)
    return data[key]
end

function getJobDataAsObject(key)
    local hash = getJobData(key)
    if not hash then return end

    return findElementByHash(objects, hash)
end

addEventHandler('jobs:updateObjects', resourceRoot, function(_objects)
    for i, object in ipairs(_objects) do
        updateObject(object)
    end
end)

addEventHandler('jobs:destroyObjects', resourceRoot, destroyObjects)
addEventHandler('jobs:destroyObject', resourceRoot, destroyObject)
addEventHandler('jobs:updateBlips', resourceRoot, function(_blips)
    for i, blip in ipairs(_blips) do
        updateBlip(blip)
    end
end)

addEventHandler('jobs:destroyBlips', resourceRoot, destroyBlips)
addEventHandler('jobs:destroyBlip', resourceRoot, destroyBlip)
addEventHandler('jobs:updateMarkers', resourceRoot, function(_markers)
    for i, marker in ipairs(_markers) do
        updateMarker(marker)
    end
end)

addEventHandler('jobs:destroyMarker', resourceRoot, destroyMarker)
addEventHandler('jobs:destroyMarkers', resourceRoot, destroyMarkers)
addEventHandler('jobs:updateData', resourceRoot, updateData)
addEventHandler('jobs:resetData', resourceRoot, resetData)