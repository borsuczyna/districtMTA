let editor = {
    "events": [
        {
            "name": "onStart",
            "actions": [
                {
                    "name": "createMarker",
                    "arguments": {
                        "1": {
                            "x": 2027.3994,
                            "y": -1898.9922,
                            "z": 13.2812
                        },
                        "3": 1,
                        "4": [
                            215,
                            9,
                            9,
                            255
                        ],
                        "6": "opisek xd",
                        "-1": "zero"
                    }
                }
            ]
        },
        {
            "name": "onMarkerHit",
            "actions": [
                {
                    "name": "outputChat",
                    "arguments": {
                        "1": "wszedles w marker",
                        "2": [
                            255,
                            77,
                            77,
                            255
                        ]
                    }
                }
            ],
            "arguments": {
                "1": "zero"
            }
        }
    ]
};

window.editor_getEditorData = (name) => {
    return editor[name];
}

window.editor_setEditorData = (name, data) => {
    editor[name] = data;
}

function saveEditorState() {
    return editor;
}

window.editor_loadEditorState = (data) => {
    editor = data;
    
    editor_reloadEvents();
    editor_hideActionsWindow();
}

function doesStartEventExist() {
    return editor.events.some(event => event.name === 'onStart');
}

window.editor_saveMission = () => {
    let name = document.getElementById('missionName').value;
    if (name === '') {
        notis_addNotification('error', 'Edytor misji', 'Nazwa misji nie może być pusta!');
    }
    
    if (!doesStartEventExist()) {
        notis_addNotification('error', 'Edytor misji', 'Musisz dodać event "Gdy misja się rozpocznie"!');
        return;
    }

    mta.triggerEvent('missions:saveMission', JSON.stringify({name: name, data: saveEditorState()}));
}

window.editor_loadMission = () => {
    let name = document.getElementById('missionName').value;
    if (name === '') {
        notis_addNotification('error', 'Edytor misji', 'Nazwa misji nie może być pusta!');
    }
    
    mta.triggerEvent('missions:loadMission', name);
}

window.editor_testMission = () => {
    if (!doesStartEventExist()) {
        notis_addNotification('error', 'Edytor misji', 'Musisz dodać event "Gdy misja się rozpocznie"!');
        return;
    }
    
    mta.triggerEvent('missions:testMission', JSON.stringify(saveEditorState()));
}

addEvent('missionEditor', 'loadMission', (data) => {
    editor_loadEditorState(data[0]);
});