defineMissionAction({
    name = 'setElementFrozen',
    editorName = 'Zamroź element',
    arguments = {
        String('Element'),
        Checkbox('Zamrożony'),
    },
    callback = function(element, frozen)
        local element = getMissionElement(element)
        setElementFrozen(element, frozen)
    end,
})