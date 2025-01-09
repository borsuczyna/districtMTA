let events = [];
let timers = [];

function addEvent(interfaceElement, name, callback) {
    let event = { interfaceElement, name, callback };
    events.push(event);
}

function removeEvent(interfaceElement, name) {
    events = events.filter(event => event.interfaceElement !== interfaceElement || event.name !== name);
}

function removeEventHandler(interfaceElement, name, callback) {
    events = events.filter(event => event.interfaceElement !== interfaceElement || event.name !== name || event.callback !== callback);
}

function removeElementEvents(interfaceElement) {
    events = events.filter(event => event.interfaceElement !== interfaceElement);
    timers = timers.filter(timer => timer.interfaceElement !== interfaceElement);
}

function triggerEvent(interfaceName, name, ...args) {
    events.forEach(event => {
        if (event.name === name && event.interfaceElement === interfaceName) {
            event.callback(...args);
        }
    });
}

function triggerAllEvents(name, ...args) {
    events.forEach(event => {
        if (event.name === name) {
            event.callback(...args);
        }
    });
}

function setTimer(interfaceElement, callback, delay, ...args) {
    let timer = { interfaceElement, callback, callTime: Date.now() + delay, args };
    timers.push(timer);
}

function updateTimers() {
    requestAnimationFrame(updateTimers);
    timers.forEach(timer => {
        if (Date.now() >= timer.callTime) {
            timer.callback(...timer.args);
        }
    });

    timers = timers.filter(timer => Date.now() < timer.callTime);
    triggerAllEvents('update');
}

window.addEventListener('mousedown', e => {
    triggerAllEvents('mousedown', e);
});

window.addEventListener('mouseup', e => {
    triggerAllEvents('mouseup', e);
});

window.addEventListener('mousemove', e => {
    triggerAllEvents('mousemove', e);
});

window.addEventListener('keydown', e => {
    triggerAllEvents('keydown', e);
});

window.addEventListener('keyup', e => {
    triggerAllEvents('keyup', e);
});

window.addEventListener('resize', e => {
    triggerAllEvents('resize', e);
});

window.addEventListener('scroll', e => {
    triggerAllEvents('scroll', e);
});

window.addEventListener('wheel', e => {
    triggerAllEvents('wheel', e);
}, { passive: false });

requestAnimationFrame(updateTimers);