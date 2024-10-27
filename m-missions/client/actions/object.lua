defineMissionAction({
    name = 'createObject',
    editorName = 'Stwórz obiekt',
    specialId = true,
    arguments = {
        Number('Model'),
        Position('Pozycja'),
        Rotation3D('Rotacja'),
    },
    callback = function(model, position, rotation)
        local object = createObject(model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z)
        if object then
            setElementDimension(object, getElementDimension(localPlayer))
            setElementInterior(object, getElementInterior(localPlayer))
            return object
        end
    end
})