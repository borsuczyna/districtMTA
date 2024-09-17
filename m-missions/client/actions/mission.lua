defineMissionAction({
    name = 'failMission',
    editorName = 'Zakończ misję niepowodzeniem',
    arguments = {
        String('Powód', '')
    },
    callback = function(reason)
        exports['m-notis']:addNotification('warning', 'Misja', 'Misja zakończona niepowodzeniem: ' .. reason)
        restartMission()
    end
})

defineMissionAction({
    name = 'toggleAllControls',
    editorName = 'Zablokuj/odblokuj sterowanie',
    arguments = {
        Checkbox('Zablokuj')
    },
    callback = function(block)
        toggleAllControls(not block)
    end
})