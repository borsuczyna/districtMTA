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
        local blip = createBlip(position.x, position.y, position.z, icon, 2, 255, 255, 255, 255, 0, distance)
        setElementDimension(blip, getElementDimension(localPlayer))
        setElementInterior(blip, getElementInterior(localPlayer))
        return blip
    end
})