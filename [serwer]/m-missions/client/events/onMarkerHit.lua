addEvent('onMissionMarkerHit')

defineMissionEvent({
    name = 'onMarkerHit',
    editorName = 'Gdy gracz wejdzie w marker',
    arguments = {
        String('ID markera'),
    },
    generate = function(marker)
        return {
            arguments = {'marker'},
            header = ('if marker == %q then'):format(marker),
            footer = 'end',
            tabs = 1,
        }
    end,
})

addEventHandler('onClientMarkerHit', root, function(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end

    local specialId = getElementData(source, 'mission:element')
    if not specialId then return end

    triggerEvent('onMissionMarkerHit', resourceRoot, specialId)
end)

addEventHandler('onMissionMarkerHit', resourceRoot, function(markerId)
    triggerMissionEvent('onMarkerHit', markerId)
end)