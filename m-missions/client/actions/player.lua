defineMissionAction({
    name = 'setElementPosition',
    editorName = 'Uruchom animację peda',
    arguments = {
        String('Element', ''),
        Position('Pozycja'),
    },
    callback = function(ped, animation, loop)
        local ped = getMissionElement(ped)
        exports['m-anim']:setPedAnimation(ped, animation, loop)
    end
})