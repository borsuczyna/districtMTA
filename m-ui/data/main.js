let lastCursorStyle = '';
let lastCursorPos = { x: 0, y: 0 };
window.cursorVisible = false;

addEventListener('load', () => {
    mta.triggerEvent('interfaceLoaded');
});

function setRemSize(size) {
    size = Math.max(Math.min(size, 22), 8);
    document.querySelector('html').style.fontSize = `${size}px`;
    let event = new Event('resize');
    window.dispatchEvent(event);
}

function changeRemSize(size) {
    let currentSize = parseFloat(document.querySelector('html').style.fontSize || 16);
    setRemSize(currentSize + size);
}

function generateHash(length = 16) {
    let characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let hash = '';
    for (let i = 0; i < length; i++) {
        hash += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return hash;
}

function setCursorVisible(visible) {
    window.cursorVisible = visible;
}

function updateBrowserTitle() {
    const element = document.elementFromPoint(lastCursorPos.x, lastCursorPos.y);
    const cursorStyle = window.getComputedStyle(element).cursor;

    document.title = JSON.stringify({
        c: cursorStyle,
        al: getControllerAxis(0),
        ar: getControllerAxis(1),
        b: new Array(18).fill(0).map((_, i) => getControllerButton(i)),
    });
}

document.addEventListener('mousemove', (event) => {
    lastCursorPos.x = event.clientX;
    lastCursorPos.y = event.clientY;

    updateBrowserTitle();
});