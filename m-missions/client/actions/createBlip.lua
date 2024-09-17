defineMissionAction({
    name = 'createBlip',
    editorName = 'Stwórz blip',
    specialId = true,
    arguments = {
        Position('Pozycja'),
        Number('Ikona', 0),
        Number('Dystans rysowania', 9999),
    },
    callback = function(position, icon, distance)
        return createBlip(position.x, position.y, position.z, icon, 2, 255, 255, 255, 255, 0, distance)
    end
})