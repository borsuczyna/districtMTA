function assignLOD(element)
    local lod = createObject(getElementModel(element),0, 0 ,0, 0, 0, 0, true)
    setElementDimension(lod,getElementDimension(element))
    setElementPosition(lod, getElementPosition(element))
    setElementRotation(lod, getElementRotation(element))
    setElementCollisionsEnabled(lod,false)
    setLowLODElement(element,lod)
    setElementData(lod,'element:model',getElementData(element,'element:model'))
    attachElements(lod,element)
    return lod
end

-- foreach all objects and check if they had element data object:lod
function assignLODToAll()
    for i, object in ipairs(getElementsByType('object')) do
        if getElementData(object, 'object:lod') then
            assignLOD(object)
        end
    end
end

addEventHandler('onClientResourceStart', resourceRoot, assignLODToAll)

addEventHandler('onClientElementStreamIn', root, function()
    if getElementType(source) == 'object' and getElementData(source, 'object:lod') then
        assignLOD(source)
    end
end)

addEventHandler('onClientElementStreamOut', root, function()
    if getElementType(source) == 'object' and getElementData(source, 'object:lod') then
        destroyElement(getLowLODElement(source))
    end
end)

local function updateMapObjects(old)
    local plrDim = getElementDimension(localPlayer)

    for i, object in ipairs(getElementsByType('object')) do
        local dim = getElementDimension(object)
        if dim == old then
            setElementDimension(object, plrDim)
        end
    end
end

addEventHandler('onClientElementDimensionChange', root, function(old)
    if source == localPlayer then
        updateMapObjects(old)
    end
end)