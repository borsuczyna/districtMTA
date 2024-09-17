let savedScrollPositions = [];
let windows = {
    events: document.querySelector('#missionEditor #events'),
    actions: document.querySelector('#missionEditor #actions'),
    addEvent: document.querySelector('#missionEditor #addEvent'),
    addAction: document.querySelector('#missionEditor #addAction'),
};

function getElementPath(element) {
    let path = [];
    while (element) {
        path.push(element.tagName + (element.id ? '#' + element.id : '') + (element.className ? '.' + element.className : ''));
        element = element.parentElement;
    }
    return path.join(' > ');
}

window.editor_saveScrollPosition = (element) => {
    let saveScroll = (element) => {
        savedScrollPositions.push({
            path: getElementPath(element),
            scroll: element.scrollTop,
        });
    }

    saveScroll(element);
    element.querySelectorAll('.nice-scroll').forEach(saveScroll);
}

window.editor_loadScrollPosition = (element) => {
    let loadScroll = (element) => {
        let saved = savedScrollPositions.find((saved) => getElementPath(element) == saved.path);
        if (saved) {
            element.scrollTop = saved.scroll;
        }
    }

    loadScroll(element);
    element.querySelectorAll('.nice-scroll').forEach(loadScroll);
}

window.editor_getWindow = (name) => {
    return windows[name];
}

window.editor_getWindowBody = (name) => {
    return editor_getWindow(name).querySelector('.body');
}

window.editor_showWindow = (name) => {
    let window = editor_getWindow(name);
    window.classList.remove('d-none');
}

window.editor_hideWindow = (name) => {
    let window = editor_getWindow(name);
    window.classList.add('d-none');
}

addEvent('#missionEditor', 'mousedown', (e) => {
    if (e?.target?.classList.contains('title-bar') && e?.target?.closest('#missionEditor')) {
        let dom = e.target.parentElement.getBoundingClientRect();
        e.target.parentElement.dataset.dragging = true;
        e.target.parentElement.dataset.draggingX = e.clientX - dom.x;
        e.target.parentElement.dataset.draggingY = e.clientY - dom.y;
    }
});

addEvent('#missionEditor', 'mouseup', (e) => {
    if (e?.target?.classList.contains('title-bar') && e?.target?.closest('#missionEditor')) {
        e.target.parentElement.dataset.dragging = false;
    }
});

addEvent('#missionEditor', 'mousemove', (e) => {
    let windows = document.querySelectorAll('#missionEditor .window');

    for (let window of windows) {
        if (window.dataset.dragging === 'true') {
            window.style.left = e.clientX - window.dataset.draggingX + 'px';
            window.style.top = e.clientY - window.dataset.draggingY + 'px';
        }
    }
});