addEvent('onPlaybackFinished')

defineMissionEvent({
    name = 'onPlaybackFinished',
    editorName = 'Gdy nagranie się zakończy',
    arguments = {
        String('Nazwa nagrania'),
    },
    generate = function(name)
        return {
            arguments = {'name'},
            header = ('if name == %q then'):format(name),
            footer = 'end',
            tabs = 1,
        }
    end,
})

addEventHandler('onPlaybackFinished', root, function(name)
    triggerMissionEvent('onPlaybackFinished', name)
end)