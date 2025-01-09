addEvent('anim:setTimelineTime')
addEvent('anim:setBone')
addEvent('anim:deleteFrame')
addEvent('anim:playPause')
addEvent('anim:copyFrame')
addEvent('anim:cutFrame')
addEvent('anim:pasteFrame')
addEvent('anim:cutAnimation')
addEvent('anim:createSnapshot')
addEvent('anim:setAnimTime')
addEvent('anim:setEasing')
addEvent('anim:setPosition')
addEvent('anim:resetAnimation')
addEvent('anim:saveAnimation')
addEvent('anim:close')

local clicked = false
local animation = {
    timelineTime = 0,
    time = 2000,
    selectedBone = false,
    lastBoneAngle = false,
    boneAngle = false,
    playing = false,
    copied = false,
    bones = {},
}

local function drawBones()
    if animation.holdRotation or animation.playing then return end

    for _, bone in pairs(boneIDs) do
        local x, y, z = getElementBonePosition(localPlayer, bone)
        x, y = getScreenFromWorldPosition(x, y, z)
        
        if x then
            local over = isMouseInPosition(x - 5, y - 5, 10, 10)
            local size = over and 10 or 6
            dxDrawImage(x - size/2, y - size/2, size, size, 'data/bg.png', 0, 0, 0, animation.selectedBone == bone and tocolor(255, 0, 0) or tocolor(255, 255, 255))
        end
    end
end

local function updateEditingBone()
    if not animation.selectedBone then return end

    local boneAngle = animation.boneAngle
    local lastBoneAngle = animation.lastBoneAngle
    local tempAngle = {boneAngle[1], boneAngle[2], boneAngle[3]}
    if animation.currentAxis == 'x' then
        tempAngle[2] = lastBoneAngle[2]
    elseif animation.currentAxis == 'y' then
        tempAngle[3] = lastBoneAngle[3]
    elseif animation.currentAxis == 'z' then
        tempAngle[1] = lastBoneAngle[1]
    end

    setElementBoneRotation(localPlayer, animation.selectedBone, tempAngle[1], tempAngle[2], tempAngle[3])
    updateElementRpHAnim(localPlayer)

    updateAnimationPosition(localPlayer, animation, animation.timelineTime)
    local position = Vector3(getElementBonePosition(localPlayer, animation.selectedBone))
    local matrix = getElementBoneMatrix(localPlayer, animation.selectedBone)

    setElementBoneRotation(localPlayer, animation.selectedBone, boneAngle[1], boneAngle[2], boneAngle[3])
    updateElementRpHAnim(localPlayer)
    updateAnimationPosition(localPlayer, animation, animation.timelineTime)

    local newAxis, newRot = renderRotatePoint(position, {
        size = 0.3,
        up = Vector3(matrix[1][1], matrix[1][2], matrix[1][3]),
        right = Vector3(matrix[2][1], matrix[2][2], matrix[2][3]),
        forward = Vector3(matrix[3][1], matrix[3][2], matrix[3][3]),
        matrix = matrix,
        drawAxis = animation.currentAxis,
        startAngle = animation.holdRotation,
        clicked = clicked
    })

    clicked = false
    if not animation.holdRotation and newAxis then
        animation.holdRotation = newRot
        lastBoneAngle = {boneAngle[1], boneAngle[2], boneAngle[3]}
    elseif not newAxis and animation.holdRotation then
        animation.holdRotation = false
        lastBoneAngle = {boneAngle[1], boneAngle[2], boneAngle[3]}
        updateBoneKeyframe()
    elseif animation.holdRotation then
        if newAxis == 'x' then
            boneAngle[2] = lastBoneAngle[2] - (newRot - animation.holdRotation)
        elseif newAxis == 'y' then
            boneAngle[3] = lastBoneAngle[3] - (newRot - animation.holdRotation)
        elseif newAxis == 'z' then
            boneAngle[1] = lastBoneAngle[1] - (newRot - animation.holdRotation)
        end
    end

    animation.currentAxis = newAxis
end

function updateEditorAnimationBones()
    local tempTime = animation.timelineTime
    if animation.playing then
        local time = (getTickCount() - animation.playing) / animation.time * 100 % 100
        animation.timelineTime = time
    end

    for bone, items in pairs(animation.bones) do
        updateAnimationBone(localPlayer, bone, items, animation.timelineTime)
    end

    updateElementRpHAnim(localPlayer)
    updateAnimationPosition(localPlayer, animation, animation.timelineTime)

    animation.timelineTime = tempTime
end

function updateTimeline()
    exports['m-ui']:setInterfaceData('anim', 'timeline', animation.bones)
    exports['m-ui']:setInterfaceData('anim', 'positions', animation.positions)
end

function deselectBone()
    animation.selectedBone = false
    animation.lastBoneAngle = false
    animation.boneAngle = false
    destroyTempElements()
    exports['m-ui']:setInterfaceData('anim', 'selectedBone', false)
end

addEventHandler('anim:setTimelineTime', root, function(time)
    animation.timelineTime = tonumber(time)
    updateEditorAnimationBones()
    updateBoneKeyframe(true)
end)

addEventHandler('anim:setBone', root, function(bone)
    setEditingBone(tonumber(bone))
end)

addEventHandler('anim:deleteFrame', root, function()
    if not animation.selectedBone then return end
    if not animation.bones[animation.selectedBone] then return end

    local item, index = table.find(animation.bones[animation.selectedBone], function(item) return item.time == animation.timelineTime end)
    if not item then return end

    table.remove(animation.bones[animation.selectedBone], index)
    updateTimeline()
    updateEditorAnimationBones()
    updateBoneKeyframe(true)
    updateEditorAnimationBones()
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Usunięto klatkę animacji')
end)

addEventHandler('anim:playPause', root, function()
    playAnimation()
end)

addEventHandler('anim:copyFrame', root, function()
    if not animation.selectedBone then return end
    if not animation.bones[animation.selectedBone] then return end

    local item = table.find(animation.bones[animation.selectedBone], function(item) return item.time == animation.timelineTime end)
    if not item then
        exports['m-notis']:addNotification('error', 'Edytor animacji', 'Nie znaleziono klatki animacji')
        return
    end

    animation.copied = item
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Skopiowano klatkę animacji')
end)

addEventHandler('anim:cutFrame', root, function()
    if not animation.selectedBone then return end
    if not animation.bones[animation.selectedBone] then return end

    local item, index = table.find(animation.bones[animation.selectedBone], function(item) return item.time == animation.timelineTime end)
    if not item then
        exports['m-notis']:addNotification('error', 'Edytor animacji', 'Nie znaleziono klatki animacji')
        return
    end

    table.remove(animation.bones[animation.selectedBone], index)
    animation.copied = item

    updateTimeline()
    updateEditorAnimationBones()
    updateBoneKeyframe(true)
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Wycięto klatkę animacji')
end)

addEventHandler('anim:pasteFrame', root, function()
    if not animation.selectedBone then
        exports['m-notis']:addNotification('error', 'Edytor animacji', 'Brak zaznaczonej kości')
        return
    end
    if not animation.bones[animation.selectedBone] then
        animation.bones[animation.selectedBone] = {}
    end
    if not animation.copied then
        exports['m-notis']:addNotification('error', 'Edytor animacji', 'Brak skopiowanej klatki animacji')
        return
    end

    local item = table.find(animation.bones[animation.selectedBone], function(item) return item.time == animation.timelineTime end)
    if not item then
        item = {time = animation.timelineTime}
        table.insert(animation.bones[animation.selectedBone], item)
    end

    item.rx = animation.copied.rx
    item.ry = animation.copied.ry
    item.rz = animation.copied.rz
    item.easing = animation.copied.easing

    updateTimeline()
    updateEditorAnimationBones()
    updateBoneKeyframe(true)
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Wklejono klatkę animacji')
end)

addEventHandler('anim:cutAnimation', root, function()
    -- find max time from all bones
    local maxTime = 0
    for _, items in pairs(animation.bones) do
        for _, item in pairs(items) do
            if item.time > maxTime then
                maxTime = item.time
            end
        end
    end

    if maxTime == 0 then
        exports['m-notis']:addNotification('error', 'Edytor animacji', 'Brak klatek animacji')
        return
    end

    for _, items in pairs(animation.bones) do
        for _, item in pairs(items) do
            item.time = math.floor(item.time / maxTime * 100)
        end
    end

    -- update timeline
    updateTimeline()
    updateEditorAnimationBones()
    updateBoneKeyframe(true)
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Animacja została przycięta')
end)

-- just same as updating bone
addEventHandler('anim:createSnapshot', root, function()
    updateBoneKeyframe()
    updateEditorAnimationBones()
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Utworzono snapshot animacji')
end)

addEventHandler('anim:setAnimTime', root, function(time)
    animation.time = tonumber(time)
    updateEditorAnimationBones()
end)

addEventHandler('anim:setEasing', root, function(easing)
    if not animation.selectedBone then return end
    if not animation.bones[animation.selectedBone] then return end

    local item = table.find(animation.bones[animation.selectedBone], function(item) return item.time == animation.timelineTime end)
    if not item then return end

    item.easing = easing
    updateTimeline()
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Zmieniono easing klatki animacji')
end)

addEventHandler('anim:setPosition', root, function(x, y, z)
    animation.positions = animation.positions or {}
    animation.positions[animation.timelineTime] = {tonumber(x), tonumber(y), tonumber(z)}

    updateTimeline()
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Zmieniono pozycję klatki animacji')
end)

function resetAnimationEditor()
    animation.bones = {}
    updateTimeline()
    updateEditorAnimationBones()
    updateBoneKeyframe(true)
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Zresetowano animację')
end
addEventHandler('anim:resetAnimation', root, resetAnimationEditor)

addEventHandler('anim:saveAnimation', root, function(name)
    if not name or #name < 3 then
        exports['m-notis']:addNotification('error', 'Edytor animacji', 'Nazwa animacji musi mieć co najmniej 3 znaki')
        return
    end

    if string.find(name, ',') then
        exports['m-notis']:addNotification('error', 'Edytor animacji', 'Nazwa animacji nie może zawierać przecinka')
        return
    end

    if not animation.bones or table.size(animation.bones) == 0 then
        exports['m-notis']:addNotification('error', 'Edytor animacji', 'Brak klatek animacji')
        return
    end

    triggerServerEvent('anim:saveAnimation', resourceRoot, name, {
        time = animation.time,
        bones = animation.bones
    })
    exports['m-notis']:addNotification('info', 'Edytor animacji', 'Zapisano animację')
end)

addEventHandler('anim:close', root, function()
    deselectBone()
    setAnimUIVisible(false)
end)

function updateBoneKeyframe(noAdd)
    if not animation.selectedBone then return end

    local rx, ry, rz = getElementBoneRotation(localPlayer, animation.selectedBone)
    
    if not noAdd then
        if not animation.bones[animation.selectedBone] then
            animation.bones[animation.selectedBone] = {}
        end

        local item = table.find(animation.bones[animation.selectedBone], function(item) return item.time == animation.timelineTime end)
        if not item then
            item = {time = animation.timelineTime}
            table.insert(animation.bones[animation.selectedBone], item)
        end

        item.rx = rx
        item.ry = ry
        item.rz = rz

        updateTimeline()
    end

    animation.lastBoneAngle = {rx, ry, rz}
    animation.boneAngle = {rx, ry, rz}
end

function playAnimation()
    if animation.playing then
        animation.playing = false
        return
    end

    animation.playing = getTickCount()
    deselectBone()
end

function setEditingBone(bone)
    animation.selectedBone = bone
    updateBoneKeyframe(true)
    exports['m-ui']:setInterfaceData('anim', 'selectedBone', bone)
end

function renderAnimationEditor()
    updateAnimationPosition(localPlayer, animation, animation.timelineTime)
    updateEditorAnimationBones()
    updateEditingBone()
    drawBones()
end

function clickAnimationEditor(button, state, x, y)
    if button ~= 'left' or state ~= 'down' then return end

    for _, bone in pairs(boneIDs) do
        local bx, by, bz = getElementBonePosition(localPlayer, bone)
        bx, by = getScreenFromWorldPosition(bx, by, bz)
        
        if bx and isMouseInPosition(bx - 5, by - 5, 10, 10) then
            setEditingBone(bone)
            return
        end
    end

    clicked = true
end

function copyAnimationBind()
    if not getKeyState('lctrl') then return end
    triggerEvent('anim:copyFrame', resourceRoot)
end

function cutAnimationBind()
    if not getKeyState('lctrl') then return end
    triggerEvent('anim:cutFrame', resourceRoot)
end

function pasteAnimationBind()
    if not getKeyState('lctrl') then return end
    triggerEvent('anim:pasteFrame', resourceRoot)
end