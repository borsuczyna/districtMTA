function createObjects(pos, tutorial)
    for _, v in ipairs(models) do
        if v.pos then
            removeWorldModel(v.lod, 0.1, v.pos.x, v.pos.y, v.pos.z)
        end
    end

    setTimer(function()
        for _, v in ipairs(models) do
            if v.pos then
                local model = createObject(v.model, v.pos.x, v.pos.y, v.pos.z)
                if v.rot then setElementRotation(model, v.rot.x, v.rot.y, v.rot.z) end
                assignLOD(model)
            end
        end
    end, 1000, 1)
end

function assignLOD(element)
    local lod = createObject(getElementModel(element), 0, 0, 0, 0, 0, 0, true)
    setElementRotation(lod, getElementRotation(element))
    attachElements(lod, element)
    setObjectScale(lod, 1.0000)
    setElementCollisionsEnabled(lod, false)
    setLowLODElement(element, lod)
    return lod
end

createObjects()