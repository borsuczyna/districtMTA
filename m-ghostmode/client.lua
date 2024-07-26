local ghostColShapes = {
    -- createColSphere(1443.021, 389.348, 18.742, 5),
}

function getElementsByTypes(types)
    local elements = {}
    for _, type in ipairs(types) do
        for _, element in ipairs(getElementsByType(type)) do
            table.insert(elements, element)
        end
    end
    return elements
end

function isInsideGhostColShape(element)
    for _, colShape in ipairs(ghostColShapes) do
        if isElementWithinColShape(element, colShape) then
            return true
        end
    end
    return false
end

function isColShapeAGhost(colShape)
    for _, ghostColShape in ipairs(ghostColShapes) do
        if colShape == ghostColShape then
            return true
        end
    end
    return false
end

function toggleCollisionBetweenElements(element, elements)
    local ghostMode1 = getElementData(element, 'element:ghostmode') or isInsideGhostColShape(element)

    for _, element2 in ipairs(elements) do
        local ghostMode2 = getElementData(element2, 'element:ghostmode') or isInsideGhostColShape(element2)
        
        if ghostMode1 or ghostMode2 then
            setElementCollidableWith(element, element2, false)
        else
            setElementCollidableWith(element, element2, true)
        end

        setElementAlpha(element, ghostMode1 and 200 or 255)
        setElementAlpha(element2, ghostMode2 and 200 or 255)
    end
end

function updateElementGhostMode(element)
    local elements = getElementsByTypes({'player', 'vehicle', 'ped'})
    toggleCollisionBetweenElements(element, elements)
end

addEventHandler('onClientElementDataChange', root, function(dataName, oldValue, newValue)
    if dataName == 'element:ghostmode' then
        updateElementGhostMode(source)
    end
end)

addEventHandler('onClientElementStreamIn', root, function()
    updateElementGhostMode(source)
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
    local elements = getElementsByTypes({'player', 'vehicle', 'ped'})
    for _, element in ipairs(elements) do
        updateElementGhostMode(element)
    end
end)

addEventHandler('onClientColShapeHit', root, function(element)
    if not isColShapeAGhost(source) then return end
    updateElementGhostMode(element)
end)

addEventHandler('onClientColShapeLeave', root, function(element)
    if not isColShapeAGhost(source) then return end
    updateElementGhostMode(element)
end)