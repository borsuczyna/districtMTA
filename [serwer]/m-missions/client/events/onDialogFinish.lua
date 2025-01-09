addEvent('missions:onVoiceLineFinish')

defineMissionEvent({
    name = 'onDialogFinish',
    editorName = 'Gdy dialog zakończy się',
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

addEventHandler('missions:onVoiceLineFinish', root, function(name)
    triggerMissionEvent('onDialogFinish', name)
end)