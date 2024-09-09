defineMissionAction({
    name = 'destroy',
    editorName = 'Zniszcz element',
    arguments = {
        String('ID elementu', 'default value')
    },
    callback = function(specialId)
        destroyMissionElement(specialId)
    end
})