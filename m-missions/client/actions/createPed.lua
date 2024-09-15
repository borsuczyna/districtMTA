defineMissionAction({
    name = 'createPed',
    editorName = 'Stwórz peda',
    specialId = true,
    arguments = {
        Number('Model'),
        Position('Pozycja'),
        Rotation('Rotacja')
    },
    callback = function(model, position, rotation)
        return createPed(model, position, rotation)
    end
})