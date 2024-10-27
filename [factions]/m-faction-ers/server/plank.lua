local planks = {}
local planksColShapes = {}
local plankPosition = {22, 0.4, 0, 0.17, 0, 0, 0}
local plankTimeouts = {}

function attachToPlank(player, plank)
    if not isElement(player) then return end
    if not isElement(plank) then return end
    
    local plankPlayer = getElementData(plank, 'plank:player')
    if plankPlayer and isElement(plankPlayer) then
        exports['m-notis']:addNotification(player, 'error', 'Deska', 'Deska jest już zajęta')
        return
    end
    
    setElementData(player, 'player:plank', plank)
    setElementData(plank, 'plank:player', player)
end

function onPlankColShapeHit(hitElement, matchingDimension)
    if plankTimeouts[source] and plankTimeouts[source] > getTickCount() then return end
    if getElementType(hitElement) ~= 'player' then return end

    local owner = getElementData(source, 'plank:owner')
    if owner ~= hitElement then
        attachToPlank(hitElement, getElementData(source, 'plank:object'))
        return
    end

    local plankObject = planks[hitElement]
    local plankPlayer = getElementData(plankObject, 'plank:player')
    destroyElement(source)
    destroyElement(plankObject)
    planks[hitElement] = nil

    if plankPlayer and isElement(plankPlayer) then
        removeElementData(plankPlayer, 'player:plank')
        putOnStretcher(hitElement, plankPlayer)
    else
        usePlank(hitElement)
    end
end

function leavePlank(player)
    if not isElement(player) then return end
    if not isElement(planks[player]) then return end

    local plank = planks[player]
    exports['m-pattach']:detach(plank)
    unbindKey(player, 'h', 'down', leavePlank)
    local x, y, z = getPositionFromElementOffset(player, 0, 1, -0.88)
    local rx, ry, rz = getElementRotation(player)
    setElementPosition(plank, x, y, z)
    setElementRotation(plank, rx, ry, rz)

    local colShape = createColSphere(0, 0, 0, 0.5)
    attachElements(colShape, plank, 0, 0.4, 1)
    setElementData(colShape, 'plank:owner', player)
    setElementData(colShape, 'plank:object', plank)
    plankTimeouts[colShape] = getTickCount() + 1000

    addEventHandler('onColShapeHit', colShape, onPlankColShapeHit)
    planksColShapes[player] = colShape
    toggleStretcherControls(player, true)
    exports['m-notis']:addNotification(player, 'info', 'Nosze', 'Deska została odłożona, aby je podnieść wejdź w nie')
end

function stopUsingPlank(player)
    if not isElement(player) then return end
    if not isElement(planks[player]) then return end
    destroyElement(planks[player])
    planks[player] = nil

    if isElement(planksColShapes[player]) then
        destroyElement(planksColShapes[player])
        planksColShapes[player] = nil
    end

    toggleStretcherControls(player, true)
end

function usePlank(player)
    if planks[player] then
        stopUsingPlank(player)
        return
    end

    local plank = createObject(1337, 0, 0, 0)
    setElementCollisionsEnabled(plank, false)
    setElementData(plank, 'element:model', 'deskamd')
    exports['m-pattach']:attach(plank, player, unpack(plankPosition))
    planks[player] = plank
    bindKey(player, 'h', 'down', leavePlank)
    exports['m-notis']:addNotification(player, 'info', 'Deska', 'Naciśnij <kbd class="keycap">H</kbd> aby zostawić deske')
    toggleStretcherControls(player, false)
end

-- on player quit
addEventHandler('onPlayerQuit', root, function()
    stopUsingPlank(source)
end)

-- debug
-- addCommandHandler('plank', function(player)
--     usePlank(player)
-- end)