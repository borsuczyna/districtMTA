defineMissionEvent({
    name = 'onMarkerHit',
    editorName = 'Gdy gracz wejdzie w marker',
    arguments = {
        String('ID markera'),
    }
})

addEventHandler('onClientMarkerHit', root, function(hitElement, matchingDimension)
    if hitElement ~= localPlayer or not matchingDimension then return end

    local specialId = getElementData(source, 'mission:element')
    if not specialId then return end

    triggerMissionEvent('onMarkerHit', specialId)
end)