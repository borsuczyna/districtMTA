defineMissionAction({
    name = 'createMarker',
    editorName = 'Stwórz marker',
    specialId = true,
    arguments = {
        Position('Pozycja'),
        Select('Typ markera', {'cylinder', 'checkpoint', 'ring', 'arrow', 'corona'}, 'cylinder'),
        Number('Wielkość', 1),
        Color('Kolor', {255, 0, 255, 255}),
        String('Tytuł', 'Title'),
        String('Opis', 'Description')
    },
    callback = function(position, type, size, color, title, description)
        local marker = createMarker(position, type, size, unpack(color))
        if title then
            setElementData(marker, 'marker:title', title)
            setElementData(marker, 'marker:desc', description)
        end
        return marker
    end
})