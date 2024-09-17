defineMissionAction({
    name = 'createMarker',
    editorName = 'Stwórz marker',
    specialId = true,
    arguments = {
        Position('Pozycja'),
        Select('Typ markera', {'cylinder', 'checkpoint', 'ring', 'arrow', 'corona'}, 'cylinder'),
        Number('Wielkość', 1),
        Color('Kolor', {255, 255, 255, 255}),
        String('Tytuł', ''),
        String('Opis', ''),
        String('Ikona', '')
    },
    callback = function(position, type, size, color, title, description, icon)
        local marker = createMarker(position.x, position.y, position.z, type, size, unpack(color))

        if title and #title > 0 then
            setElementData(marker, 'marker:title', title)
        end

        if description and #description > 0 then
            setElementData(marker, 'marker:desc', description)
        end

        if icon and #icon > 0 then
            setElementData(marker, 'marker:icon', icon)
        end    

        return marker
    end,
    promise = {
        name = 'Poczekaj aż gracz wejdzie w marker',
        toCode = function(args)
            return ('waitForMarkerEnter(%q)'):format(args['-1'])
        end
    }
})

function waitForMarkerEnter(markerId)
    return Promise:new(function(resolve, _)
        addEventHandler('onMissionMarkerHit', resourceRoot, function(hitMarkerId)
            if hitMarkerId == markerId then
                resolve()
            end
        end)
    end)
end