defineMissionAction({
    name = 'sleep',
    editorName = 'Odczekaj czas',
    arguments = {
        Number('Czas (ms)', 1000),
    },
    callback = function(time)
        await(sleep(time))
    end
})