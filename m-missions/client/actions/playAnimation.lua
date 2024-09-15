defineMissionAction({
    name = 'playPedAnimation',
    editorName = 'Uruchom animację peda',
    arguments = {
        String('Ped', ''),
        Animation('Animacja'),
        Checkbox('Powtarzaj', false),
    },
    callback = function(ped, animation, loop)
        exports['m-anim']:setPedAnimation(ped, animation, loop)
    end
})