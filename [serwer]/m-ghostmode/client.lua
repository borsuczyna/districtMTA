local elementTypes = {'player', 'vehicle', 'ped'}
local ghostColShapes = {
    -- vehicle shops exit
    createColSphere(1139.445, -2036.923, 68.738, 10),
    createColSphere(1895.972, -1878.888, 13.152, 10),
    createColSphere(1280.164, -1438.338, 12.938, 5),

    -- tuner
    createColSphere(983.190, -1265.528, 15.180, 25)
}

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return false
end

function getElementsByTypesNew(types_)
    local elements = {}
    for _, type in ipairs(types_) do
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
    local elementType = getElementType(element)
    if not table.find(elementTypes, elementType) then return end
    if isElementLocal(element) then return end
    
    local ghostMode1 = getElementData(element, 'element:ghostmode') or isInsideGhostColShape(element)

    for _, element2 in ipairs(elements) do
        local ghostMode2 = getElementData(element2, 'element:ghostmode') or isInsideGhostColShape(element2)

        if getElementData(element2, 'player:inv') or getElementData(element, 'player:inv') then
            break
        end
        
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
    local elements = getElementsByTypesNew(elementTypes)
    toggleCollisionBetweenElements(element, elements)
end

addEventHandler('onClientElementDataChange', root, function(dataName, oldValue, newValue)
    if dataName == 'element:ghostmode' then
        local elementType = getElementType(source)
        if not table.find(elementTypes, elementType) then return end

        updateElementGhostMode(source)
    end
end)

addEventHandler('onClientElementStreamIn', root, function()
    updateElementGhostMode(source)
end)

addEventHandler('onClientResourceStart', resourceRoot, function()
    local elements = getElementsByTypesNew(elementTypes)
    for _, element in ipairs(elements) do
        updateElementGhostMode(element)
    end
end)

addEventHandler('onClientColShapeHit', root, function(element)
    if not isColShapeAGhost(source) then return end
    local elementType = getElementType(element)
    if not table.find(elementTypes, elementType) then return end
    
    updateElementGhostMode(element)
end)

addEventHandler('onClientColShapeLeave', root, function(element)
    if not isColShapeAGhost(source) then return end
    local elementType = getElementType(element)
    if not table.find(elementTypes, elementType) then return end

    updateElementGhostMode(element)
end)