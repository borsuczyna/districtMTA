local r1bags = {}
local r1bagsColShapes = {}
local r1bagPosition = {24, 0.6, 0.1, -0.1, -90, 0, 90}
local r1bagTimeouts = {}

function onR1BagColShapeHit(hitElement, matchingDimension)
    if r1bagTimeouts[source] and r1bagTimeouts[source] > getTickCount() then return end
    if getElementType(hitElement) ~= 'player' then return end

    local owner = getElementData(source, 'r1bag:owner')
    if owner ~= hitElement then return end

    local r1bagObject = r1bags[hitElement]
    local r1bagPlayer = getElementData(r1bagObject, 'r1bag:player')
    destroyElement(source)
    destroyElement(r1bagObject)
    r1bags[hitElement] = nil

    if r1bagPlayer and isElement(r1bagPlayer) then
        removeElementData(r1bagPlayer, 'player:r1bag')
        putOnStretcher(hitElement, r1bagPlayer)
    else
        useR1Bag(hitElement)
    end
end

function leaveR1Bag(player)
    if not isElement(player) then return end
    if not isElement(r1bags[player]) then return end

    local r1bag = r1bags[player]
    exports['m-pattach']:detach(r1bag)
    unbindKey(player, 'h', 'down', leaveR1Bag)
    local x, y, z = getPositionFromElementOffset(player, 0, 1, -1.1)
    local rx, ry, rz = getElementRotation(player)
    setElementPosition(r1bag, x, y, z)
    setElementRotation(r1bag, rx, ry, rz)

    local colShape = createColSphere(0, 0, 0, 0.5)
    attachElements(colShape, r1bag, 0, 0, 1)
    setElementData(colShape, 'r1bag:owner', player)
    setElementData(colShape, 'r1bag:object', r1bag)
    r1bagTimeouts[colShape] = getTickCount() + 1000

    addEventHandler('onColShapeHit', colShape, onR1BagColShapeHit)
    r1bagsColShapes[player] = colShape
    toggleStretcherControls(player, true)
    exports['m-notis']:addNotification(player, 'info', 'Nosze', 'Torba R1 została odłożona, aby je podnieść wejdź w nie')
end

function stopUsingR1Bag(player)
    if not isElement(player) then return end
    if not isElement(r1bags[player]) then return end
    destroyElement(r1bags[player])
    r1bags[player] = nil

    if isElement(r1bagsColShapes[player]) then
        destroyElement(r1bagsColShapes[player])
        r1bagsColShapes[player] = nil
    end

    toggleStretcherControls(player, true)
end

function useR1Bag(player)
    if r1bags[player] then
        stopUsingR1Bag(player)
        return
    end

    local r1bag = createObject(1337, 0, 0, 0)
    setElementCollisionsEnabled(r1bag, false)
    setElementData(r1bag, 'element:model', 'torbar1')
    exports['m-pattach']:attach(r1bag, player, unpack(r1bagPosition))
    r1bags[player] = r1bag
    bindKey(player, 'h', 'down', leaveR1Bag)
    exports['m-notis']:addNotification(player, 'info', 'Torba R1', 'Naciśnij <kbd class="keycap">H</kbd> aby zostawić torbe')
    toggleStretcherControls(player, false)
end

-- on player quit
addEventHandler('onPlayerQuit', root, function()
    stopUsingR1Bag(source)
end)

-- debug
-- addCommandHandler('r1bag', function(player)
--     useR1Bag(player)
-- end)