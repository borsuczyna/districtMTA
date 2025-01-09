defineMissionAction({
    name = 'setElementPosition',
    editorName = 'Ustaw pozycję elementu',
    arguments = {
        String('Element', ''),
        Position('Pozycja'),
    },
    callback = function(element, position)
        local element = getMissionElement(element)
        setElementPosition(element, position.x, position.y, position.z)
    end,
})

defineMissionAction({
    name = 'setElementRotation',
    editorName = 'Ustaw rotację elementu',
    arguments = {
        String('Element', ''),
        Rotation3D('Rotacja'),
    },
    callback = function(element, rotation)
        local element = getMissionElement(element)
        setElementRotation(element, rotation.x, rotation.y, rotation.z, 'default', getElementType(element) == 'ped')
    end,
})