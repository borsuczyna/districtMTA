defineMissionAction({
    name = 'playPedAnimation',
    editorName = 'Uruchom animację peda',
    arguments = {
        String('Ped', ''),
        Animation('Animacja'),
        Checkbox('Powtarzaj'),
    },
    callback = function(ped, animation, loop)
        local ped = getMissionElement(ped)
        exports['m-anim']:setPedAnimation(ped, animation, loop)
    end
})