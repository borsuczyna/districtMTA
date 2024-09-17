addEvent('missions:onVoiceLineFinish', true)

calledCustomEvents = {}

defineMissionAction({
    name = 'triggerEvent',
    editorName = 'Wywołaj trigger',
    arguments = {
        String('Nazwa triggera', ''),
    },
    callback = function(triggerName)
        triggerMissionEvent('onCustomTrigger', triggerName)
    end,
})

defineMissionEvent({
    name = 'onCustomTrigger',
    editorName = 'Custom trigger',
    arguments = {
        String('Nazwa triggera'),
        Checkbox('Wywołaj tylko raz'),
    },
    generate = function(name, once)
        return {
            arguments = {'name'},
            header = ('if name == %q %s then %s'):format(
                name,
                once and ('and not calledCustomEvents[%q]'):format(name) or '',
                once and ('calledCustomEvents[%q] = true'):format(name) or ''
            ),
            footer = 'end',
            tabs = 1,
        }
    end,
})