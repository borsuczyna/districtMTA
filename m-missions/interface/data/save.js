let editor = {
    events: [
        {
            name: 'onStart',
            actions: [
                {
                    name: 'createMarker'
                }
            ]
        },
        {
            name: 'onMarkerHit',
        },
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

function loadEditorState(data) {
    editor = data;
    
    reloadEvents();
}