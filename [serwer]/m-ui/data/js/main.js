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

function addCents(value) {
    let cents = (value % 100).toString().padStart(2, '0');
    return `${Math.floor(value / 100)}.${cents}`;
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
    if (!element) return;
    const cursorStyle = getComputedStyle(element).cursor;
    let anyInputFocused = document.activeElement && ['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName);

    document.title = JSON.stringify({
        c: cursorStyle,
        al: getControllerAxis(0),
        ar: getControllerAxis(1),
        b: new Array(18).fill(0).map((_, i) => getControllerButton(i)),
        i: anyInputFocused,
    });
}

document.addEventListener('mousemove', (event) => {
    lastCursorPos.x = event.clientX;
    lastCursorPos.y = event.clientY;

    updateBrowserTitle();
});

async function waitForAnimationFinish(element, maxTime = 1000) {
    const computedStyle = window.getComputedStyle(element);
    const transitionDuration = parseFloat(computedStyle.transitionDuration) * 1000;
    const animationDuration = parseFloat(computedStyle.animationDuration) * 1000;
    const duration = Math.max(transitionDuration, animationDuration);
    const playing = computedStyle.animationPlayState === 'running';
    if (duration > 0 && playing) {
        return new Promise(resolve => {
            let resolved = false;
            const listener = (e) => {
                if (resolved) return;
                element.removeEventListener('transitionend', listener);
                resolve();
                resolved = true;
            };
            element.addEventListener('transitionend', listener);
            setTimeout(listener, maxTime);
        });
    }
}