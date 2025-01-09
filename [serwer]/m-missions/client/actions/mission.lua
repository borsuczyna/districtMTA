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
    name = 'finishMission',
    editorName = 'Zakończ misję sukcesem',
    arguments = {},
    callback = function(reason)
        exports['m-notis']:addNotification('success', 'Misja', 'Misja zakończona sukcesem')
        finishMission()
        triggerServerEvent('missions:finishMission', resourceRoot, currentMissionIndex)
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