let actions = {};

addEvent('missionEditor', 'interface:data:actions', (data) => {
    actions = data[0];
});

window.editor_hideActionsWindow = () => {
    window.editor_hideWindow('actions');
}

window.editor_showActionsWindow = () => {
    window.editor_showWindow('actions');

    editor_reloadActions();
}

function renderAction(action, index) {
    let actionInfo = actions[action.name];
    if (!actionInfo)
        return '';

    actionInfo = actionInfo.data;

    return `<div class="item" onclick="editor_openListItem(event, this)" data-index="${index}">
        <div class="d-flex gap-1">
            <div class="arrow">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" class="feather feather-chevron-right">
                    <polyline points="9 18 15 12 9 6"></polyline>
                </svg>
            </div>
            ${actionInfo.editorName}
        </div>
        <div class="details">
            <div class="d-flex flex-column gap-1">
                ${actionInfo.specialId ? editor_renderArgument({
                    type: 'string',
                    name: 'ID elementu',
                }, action.arguments, -1, 'editor_updateActionArgument') : ''}
            
                ${actionInfo.arguments.map((argument, index) => {
                    return editor_renderArgument(argument, action.arguments, index + 1, 'editor_updateActionArgument');
                }).join('')}
            </div>

            ${actionInfo.promise ? `<div>
                <input type="checkbox" id="promise-${index}" ${action.promise ? 'checked' : ''} onchange="editor_updateActionPromise(this, ${index})">
                <label for="promise-${index}">${actionInfo.promise.name}</label>
            </div>` : ''}
                

            <div class="d-flex justify-end gap-1 align-items-center mt-1">
                ${editor_getIcon('trash', true, `editor_removeAction(${index})`)}
            </div>
        </div>
    </div>`;
}

window.editor_updateActionPromise = (element, index) => {
    let actions = editor_getCurrentEventActions();
    let action = actions[index];

    action.promise = element.checked;
    editor_setCurrentEventActions(actions);
}

window.editor_updateActionArgument = (element, index) => {
    let actions = editor_getCurrentEventActions();
    let actionIndex = element.closest('.item').getAttribute('data-index');
    let action = actions[actionIndex];

    action.arguments = action.arguments || {};

    action.arguments[index] = editor_getValue(element);
    editor_setCurrentEventActions(actions);
}

window.editor_removeAction = (index) => {
    let actions = editor_getCurrentEventActions();
    actions.splice(index, 1);
    editor_setCurrentEventActions(actions);
    editor_reloadActions();
}

window.editor_reloadActions = () => {
    let actions = editor_getCurrentEventActions();
    if (!actions) {
        editor_hideActionsWindow();
        return;
    }

    let body = editor_getWindowBody('actions');
    body.innerHTML = `<div class="list">
        ${actions.map((action, index) => renderAction(action, index)).join('')}
    </div>

    <div class="d-flex justify-end gap-1 align-items-center mt-1">
        ${editor_getIcon('close', true, 'editor_hideActionsWindow()')}
        ${editor_getIcon('add', true, 'editor_showAddActionWindow()')}
    </div>`;
}

window.editor_showAddActionWindow = () => {
    editor_showWindow('addAction');

    let body = editor_getWindowBody('addAction');
    
    body.innerHTML = `<div class="list">
        ${Object.keys(actions).map((actionName) => {
            let actionInfo = actions[actionName].data;
            return `<div class="item" onclick="editor_addAction('${actionName}')">
                ${actionInfo.editorName}
            </div>`;
        }).join('')}
    </div>

    <div class="d-flex justify-end gap-1 align-items-center mt-1">
        ${editor_getIcon('close', true, 'editor_hideAddActionWindow()')}
    </div>`;
}

window.editor_hideAddActionWindow = () => {
    editor_hideWindow('addAction');
}

window.editor_addAction = (eventName) => {
    let actions = editor_getCurrentEventActions();
    if (!actions)
        actions = [];

    actions.push({
        name: eventName,
        arguments: {},
    });

    editor_setCurrentEventActions(actions);
    editor_reloadActions();
    editor_hideWindow('addAction');
}