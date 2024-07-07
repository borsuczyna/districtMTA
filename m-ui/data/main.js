addEventListener('load', () => {
    mta.triggerEvent('interfaceLoaded');
});

// addEventListener('keydown', (e) => {
//     if ((e.key.toLowerCase() === 'q' || e.key.toLowerCase() === 'e')) {
//         // e.preventDefault();
//         changeRemSize(e.key.toLowerCase() === 'q' ? -1 : 1);
//     }
// });

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