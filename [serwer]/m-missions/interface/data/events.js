let actions = {};
let currentEditingEvent = null;

window.editor_getCurrentEventActions = () => {
    if (currentEditingEvent === null)
        return null;

    let eventsData = editor_getEditorData('events');
    return eventsData[currentEditingEvent].actions || [];
}

window.editor_setCurrentEventActions = (actions) => {
    if (currentEditingEvent === null)
        return;

    let eventsData = editor_getEditorData('events');
    eventsData[currentEditingEvent].actions = actions;
    editor_setEditorData('events', eventsData);
}

window.editor_updateEventArgument = function (element, index) {
    let eventsData = editor_getEditorData('events');
    let value = editor_getValue(element);
    let eventIndex = element.closest('.item').getAttribute('data-index');

    eventsData[eventIndex].arguments = eventsData[eventIndex].arguments || {};

    eventsData[eventIndex].arguments[index] = value;
    editor_setEditorData('events', eventsData);
}

function renderEvent(event, index) {
    let eventInfo = actions[event.name];

    return `<div class="item" onclick="editor_openListItem(event, this)" data-index="${index}">
        <div class="d-flex gap-1">
            <div class="arrow">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" class="feather feather-chevron-right">
                    <polyline points="9 18 15 12 9 6"></polyline>
                </svg>
            </div>
            ${eventInfo.editorName}
        </div>
        <div class="details">
            <div class="d-flex flex-column gap-1">
                ${eventInfo.arguments.map((argument, index) => {
                    return editor_renderArgument(argument, event.arguments, index + 1, 'editor_updateEventArgument');
                }).join('')}
            </div>

            <div class="d-flex justify-end gap-1 align-items-center mt-1">
                ${editor_getIcon('edit', true, `editor_editActions(${index})`)}
                ${editor_getIcon('trash', true, `editor_removeEvent(${index})`)}
            </div>
        </div>
    </div>`;
}

window.editor_reloadEvents = () => {
    let eventsWindow = editor_getWindowBody('events');
    let eventsData = editor_getEditorData('events');
    editor_saveScrollPosition(eventsWindow);

    eventsWindow.innerHTML = `<div class="list nice-scroll">
        ${eventsData.map((event, index) => renderEvent(event, index)).join('')}
    </div>
    
    <div class="d-flex justify-end gap-1 align-items-center mt-1">
        ${editor_getIcon('add', true, 'editor_showAddEventWindow()')}
    </div>`;

    editor_loadScrollPosition(eventsWindow);
}

window.editor_showAddEventWindow = () => {
    editor_showWindow('addEvent');

    let body = editor_getWindowBody('addEvent');
    let scrollPosition = body.scrollTop;    

    body.innerHTML = `<div class="list nice-scroll">
        ${Object.keys(actions).map((eventName) => {
            let eventInfo = actions[eventName];
            return `<div class="item" onclick="editor_addEvent('${eventName}')">
                ${eventInfo.editorName}
            </div>`;
        }).join('')}
    </div>

    <div class="d-flex justify-end gap-1 align-items-center mt-1">
        ${editor_getIcon('close', true, 'editor_hideAddEventWindow()')}
    </div>`;

    body.scrollTop = scrollPosition;
}

window.editor_hideAddEventWindow = () => {
    editor_hideWindow('addEvent');
}

window.editor_addEvent = (eventName) => {
    let eventsData = editor_getEditorData('events');
    eventsData.push({
        name: eventName,
        arguments: {}
    });

    editor_setEditorData('events', eventsData);
    editor_reloadEvents();
    editor_hideWindow('addEvent');
}

window.editor_removeEvent = (index) => {
    let eventsData = editor_getEditorData('events');
    eventsData.splice(index, 1);

    editor_setEditorData('events', eventsData);
    editor_reloadEvents();

    if (currentEditingEvent === index) {
        currentEditingEvent = null;
        editor_hideActionsWindow();
    }
}

window.editor_editActions = (index) => {
    currentEditingEvent = index;
    editor_showActionsWindow();
}

addEvent('missionEditor', 'interface:data:events', (data) => {
    actions = data[0];
    editor_reloadEvents();
});