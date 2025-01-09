addEvent('jobs:updateObjects', true)
addEvent('jobs:destroyObject', true)
addEvent('jobs:updateBlips', true)
addEvent('jobs:destroyBlip', true)
addEvent('jobs:destroyObjects', true)
addEvent('jobs:destroyBlips', true)
addEvent('jobs:updateMarkers', true)
addEvent('jobs:playSound3D', true)
addEvent('jobs:destroyMarker', true)
addEvent('jobs:destroyMarkers', true)
addEvent('jobs:updatePeds', true)
addEvent('jobs:destroyPed', true)
addEvent('jobs:destroyPeds', true)
addEvent('jobs:updateData', true)
addEvent('jobs:resetData', true)
addEvent('jobs:setObjectCustomData', true)
addEvent('jobs:setObjectPosition', true)
addEvent('jobs:setObjectOption', true)
addEvent('jobs:setPedRotation', true)
addEvent('jobs:setPedControlState', true)
addEvent('jobs:setMarkerCustomData', true)

local objects = {}
local blips = {}
local markers = {}
local peds = {}
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
            local pos = colshape.attachPosition or {0, 0, 0}
            attachElements(shape, object.element, pos[1], pos[2], pos[3])
        end

        if colshape.event then
            addEventHandler('onClientColShapeHit', shape, function(hitElement, matchingDimension)
                if hitElement ~= localPlayer or not matchingDimension then return end
                if getTickCount() - lastEventSend < 1500 then return end

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
        setBlipVisibleDistance(element, blip.visibleDistance)
    end
end

function updateElementAttach(element, attach)
    if attach then
        local x, y, z, rx, ry, rz = unpack(attach.position or {})
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

function updateObjectEffect(object, effect)
    if object.effect and isElement(object.effect) then
        destroyElement(object.effect)
    end

    if effect then
        local element = createEffect(effect.name, object.position[1], object.position[2], object.position[3], 0, 0, 0)
        setEffectDensity(element, effect.density or 1)
        object.effect = element
    end
end

function updateObjectAttachedElements(object, attachedElements)
    if not attachedElements then return end

    for i, attachedElement in ipairs(attachedElements) do
        local element = findElementByHash(objects, attachedElement.hash)
        if not element then return end

        local x, y, z, rx, ry, rz = unpack(attachedElement.position)
        attachElements(element.element, object.element, x, y, z, rx, ry, rz)
    end
end

function updateObjectAttachedToOtherElement(object)
    local attachedElementData = false
    local attachedElementObject = false

    for i, obj in ipairs(objects) do
        for j, attachedElement in ipairs(obj.attachedElements) do
            if attachedElement.hash == object.hash then
                attachedElementData = attachedElement
                attachedElementObject = obj.element
                break
            end
        end
    end

    if not attachedElementData then return end

    local x, y, z, rx, ry, rz = unpack(attachedElementData.position)
    attachElements(object.element, attachedElementObject, x, y, z, rx, ry, rz)
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
    obj.attachedElements = object.attachedElements

    updateColshape(obj, object.options.colshape)
    updateObjectBlip(obj, object.options.blip)
    updateObjectBoneAttach(obj, object.options.attachBone)
    updateElementAttach(obj, object.options.attach)
    updateObjectGhost(obj, object.options.ghost)
    updateObjectEffect(obj, object.options.effect)
    updateObjectAttachedElements(obj, object.attachedElements)
    updateObjectAttachedToOtherElement(obj)

    setElementPosition(obj.element, obj.position[1], obj.position[2], obj.position[3])
    setElementRotation(obj.element, obj.rotation[1], obj.rotation[2], obj.rotation[3])
    setElementFrozen(obj.element, object.options.frozen or false)
    setElementDimension(obj.element, object.options.dimension or 0)

    if object.options.customModel then
        setElementData(obj.element, 'element:model', object.options.customModel)
    else
        setElementModel(obj.element, obj.model)
    end

    setObjectScale(obj.element, object.options.scale or 1)
    if object.options.noCollision then
        setElementCollisionsEnabled(obj.element, false)
    end
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

    if obj.effect and isElement(obj.effect) then
        destroyElement(obj.effect)
    end

    for i, object in ipairs(objects) do
        if object == obj then
            table.remove(objects, i)
            break
        end
    end
end

function updateObjectsEffectsPosition()
    for i, object in ipairs(objects) do
        if object.effect and isElement(object.effect) then
            local x, y, z = getElementPosition(object.element)
            setElementPosition(object.effect, x, y, z)
        end
    end
end

function getObjectByHash(hash)
    local object = findElementByHash(objects, hash)
    if not object then return end
    
    return object.element
end

function getAllLobbyObjectsWithCustomData(key)
    local resObjects = {}
    for i, object in ipairs(objects) do
        if object.customData[key] then
            table.insert(resObjects, {
                hash = object.hash,
                value = object.customData[key],
                element = object.element,
                customData = object.customData
            })
        end
    end

    return resObjects
end

function getLobbyObjectCustomData(hash, key)
    local obj = findElementByHash(objects, hash)
    if not obj then return end

    return obj.customData[key]
end

function getObjectHash(element)
    for i, object in ipairs(objects) do
        if object.element == element then
            return object.hash
        end
    end
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
    destroyArrayKey(objects, 'effect')
    destroyArray(objects)
    objects = {}
end

function _createPed(ped)
    local element = createPed(ped.model, ped.position[1], ped.position[2], ped.position[3], ped.rotation[1], ped.rotation[2], ped.rotation[3])
    ped.element = element

    table.insert(peds, ped)
    return findElementByHash(peds, ped.hash)
end

local controlTable = { "fire", "aim_weapon", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "zoom_in", "zoom_out",
"change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "conversation_yes", "conversation_no",
"group_control_forwards", "group_control_back", "enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
"steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn", "sub_mission",
"handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
"special_control_down", "special_control_up" }

function updatePedControlStates(ped, states)
    for i, control in ipairs(controlTable) do
        setPedControlState(ped, control, states[control] or false)
    end
end

function updateElementDatas(ped, datas)
    for key, value in pairs(datas) do
        setElementData(ped, key, value)
    end
end

function updatePed(ped)
    local obj = findElementByHash(peds, ped.hash)
    if not obj then
        obj = _createPed(ped)
    end

    obj.model = ped.model
    obj.position = ped.position
    obj.rotation = ped.rotation
    obj.invincible = ped.options.invincible

    updateColshape(obj, ped.options.colshape)
    updateObjectBlip(obj, ped.options.blip)
    updatePedControlStates(obj.element, ped.options.controlStates or {})
    updateElementDatas(obj.element, ped.options.datas or {})

    setElementModel(obj.element, obj.model)
    setElementPosition(obj.element, obj.position[1], obj.position[2], obj.position[3])
    setElementRotation(obj.element, obj.rotation[1], obj.rotation[2], obj.rotation[3], 'default', true)
    setElementFrozen(obj.element, ped.options.frozen or false)
    setElementDimension(obj.element, ped.options.dimension or 0)
    setElementData(obj.element, 'element:model', ped.options.customModel)
    setObjectScale(obj.element, ped.options.scale or 1)
    if ped.options.noCollision then
        setElementCollisionsEnabled(obj.element, false)
    end
end

function destroyPed(hash)
    local obj = findElementByHash(peds, hash)
    if not obj then return end

    if obj.colshape and isElement(obj.colshape) then
        destroyElement(obj.colshape)
    end

    if obj.blip and isElement(obj.blip) then
        destroyElement(obj.blip)
    end

    if obj.element and isElement(obj.element) then
        destroyElement(obj.element)
    end

    for i, ped in ipairs(peds) do
        if ped == obj then
            table.remove(peds, i)
            break
        end
    end
end

function getPedByHash(hash)
    local ped = findElementByHash(peds, hash)
    if not ped then return end
    
    return ped.element
end

function getPedHash(element)
    for i, ped in ipairs(peds) do
        if ped.element == element then
            return ped.hash
        end
    end
end

function destroyPeds()
    destroyArrayKey(peds, 'colshape')
    destroyArrayKey(peds, 'blip')
    destroyArray(peds)
    peds = {}
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
            if getTickCount() - lastEventSend < 1500 then return end

            triggerServerEvent('jobs:markerHit', resourceRoot, marker.hash)
            lastEventSend = getTickCount()
        end

        addEventHandler('onClientMarkerHit', marker.element, marker.eventHandler)
    end
end

function updateSquareMarker(marker, square)
    if square then
        setElementData(marker.element, 'marker:square', square)
    else
        setElementData(marker.element, 'marker:square', nil)
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
    updateSquareMarker(obj, marker.options.square)
    updateObjectBlip(obj, marker.options.blip)

    setElementPosition(obj.element, obj.position[1], obj.position[2], obj.position[3])
    setMarkerSize(obj.element, obj.size)
    setMarkerColor(obj.element, obj.color[1], obj.color[2], obj.color[3], obj.color[4])
    setMarkerType(obj.element, obj.type)
    setElementData(obj.element, 'marker:icon', marker.options.icon or 'work')
    setElementData(obj.element, 'marker:title', marker.options.title or 'Marker')
    setElementData(obj.element, 'marker:desc', marker.options.desc or 'Marker')
    setElementDimension(obj.element, marker.options.dimension or 0)
    setElementInterior(obj.element, marker.options.interior or 0)
end

function destroyMarker(hash)
    local obj = findElementByHash(markers, hash)
    if not obj then return end

    if obj.blip and isElement(obj.blip) then
        destroyElement(obj.blip)
    end

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
    destroyArrayKey(markers, 'blip')
    destroyArray(markers)
    markers = {}
end

local _playSound3D = playSound3D
function playSound3D(sound, x, y, z, minDistance, maxDistance, volume)
    local sound = _playSound3D(sound, x, y, z)
    setSoundMaxDistance(sound, maxDistance)
    setSoundMinDistance(sound, minDistance)
    setSoundVolume(sound, volume)
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

addEventHandler('onClientPedDamage', root, function(attacker)
    for i, ped in ipairs(peds) do
        if ped.element == source and ped.invincible then
            cancelEvent()
        end
    end
end)

addEventHandler('jobs:updateObjects', resourceRoot, function(_objects)
    for i, object in ipairs(_objects) do
        updateObject(object)
    end
end)

addEventHandler('jobs:setObjectCustomData', resourceRoot, function(hash, key, value)
    local obj = findElementByHash(objects, hash)
    if not obj then return end

    obj.customData[key] = value
    updateObject(obj)
end)

addEventHandler('jobs:setObjectOption', resourceRoot, function(hash, key, value)
    local obj = findElementByHash(objects, hash)
    if not obj then return end

    obj.options[key] = value
    updateObject(obj)
end)

addEventHandler('jobs:setObjectPosition', resourceRoot, function(hash, x, y, z, rx, ry, rz)
    local obj = findElementByHash(objects, hash)
    if not obj then return end

    obj.position = {x, y, z}
    setElementPosition(obj.element, x, y, z)

    if rx and ry and rz then
        obj.rotation = {rx, ry, rz}
        setElementRotation(obj.element, rx, ry, rz)
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

addEventHandler('jobs:destroyPed', resourceRoot, destroyPed)
addEventHandler('jobs:destroyPeds', resourceRoot, destroyPeds)
addEventHandler('jobs:updatePeds', resourceRoot, function(_peds)
    for i, ped in ipairs(_peds) do
        updatePed(ped)
    end
end)

addEventHandler('jobs:setPedRotation', resourceRoot, function(hash, rot)
    local ped = findElementByHash(peds, hash)
    if not ped then return end

    ped.rotation[3] = rot
    setElementRotation(ped.element, 0, 0, rot, 'default', true)
end)

addEventHandler('jobs:setPedControlState', resourceRoot, function(hash, control, state)
    local ped = findElementByHash(peds, hash)
    if not ped then return end

    ped.options.controlStates = ped.options.controlStates or {}
    ped.options.controlStates[control] = state
    setPedControlState(ped.element, control, state)
end)

addEventHandler('jobs:setMarkerCustomData', resourceRoot, function(hash, key, value)
    local marker = findElementByHash(markers, hash)
    if not marker then return end

    marker.customData[key] = value
    updateMarker(marker)
end)

addEventHandler('jobs:destroyMarker', resourceRoot, destroyMarker)
addEventHandler('jobs:destroyMarkers', resourceRoot, destroyMarkers)
addEventHandler('jobs:playSound3D', resourceRoot, playSound3D)
addEventHandler('jobs:updateData', resourceRoot, updateData)
addEventHandler('jobs:resetData', resourceRoot, resetData)
addEventHandler('onClientPreRender', root, updateObjectsEffectsPosition)