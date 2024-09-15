defineMissionAction({
    name = 'createVehicle',
    editorName = 'Stwórz pojazd',
    specialId = true,
    arguments = {
        Number('Model'),
        Position('Pozycja'),
        Rotation3D('Rotacja')
    },
    callback = function(model, position, rotation)
        return createVehicle(model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z)
    end
})