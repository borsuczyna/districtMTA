addEventListener('load', () => {
    mta.triggerEvent('interfaceLoaded');
});

// addEventListener('keydown', (e) => {
//     if ((e.key.toLowerCase() === 'q' || e.key.toLowerCase() === 'e')) {
//         e.preventDefault();
//         changeRemSize(e.key.toLowerCase() === 'q' ? -1 : 1);
//     }
// });

function setRemSize(size) {
    size = Math.max(Math.min(size, 25), 8);
    document.querySelector('html').style.fontSize = `${size}px`;
}

function changeRemSize(size) {
    let currentSize = parseFloat(document.querySelector('html').style.fontSize || 16);
    setRemSize(currentSize + size);
}