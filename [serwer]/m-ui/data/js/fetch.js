let htmlCache = {};
let spinnerSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12,4a8,8,0,0,1,7.89,6.7A1.53,1.53,0,0,0,21.38,12h0a1.5,1.5,0,0,0,1.48-1.75,11,11,0,0,0-21.72,0A1.5,1.5,0,0,0,2.62,12h0a1.53,1.53,0,0,0,1.49-1.3A8,8,0,0,1,12,4Z"><animateTransform attributeName="transform" dur="0.75s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></svg>`;
let awaiting = {};

function makeButtonSpinner(button, spinner = true) {
    if (button == undefined || typeof button === 'undefined' || button == null || typeof button === 'null') return;
    let html = spinner ? spinnerSvg : htmlCache[button];
    if (spinner) {
        htmlCache[button] = button.innerHTML;
    } else {
        delete htmlCache[button];
    }

    if (html) button.innerHTML = html;
    button.classList.toggle('button-spinner', spinner, !spinner);
}

function isButtonSpinner(button) {
    if (button == undefined || typeof button === 'undefined' || button == null || typeof button === 'null') return false;
    return button.classList.contains('button-spinner');
}

function generateHash(length = 32) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}

mta = mta || {};
mta.fetch = async (parentResource, endpoint, arguments, options = {
    timeout: 15000,
}) => {
    if (!Array.isArray(arguments)) {
        arguments = [arguments];
    }

    const hash = generateHash();
    mta.triggerEvent('ui:fetchData', JSON.stringify({
        parentResource,
        endpoint,
        arguments,
        hash,
    }));

    return new Promise((resolve, reject) => {
        const timeoutId = setTimeout(() => {
            resolve(null);
        }, options.timeout);

        awaiting[hash] = {
            resolve,
            reject,
            timeoutId,
        };
    });
}

addEvent('main', 'ui:fetchDataResponse', function handler(responseHash, data) {
    let request = awaiting[responseHash];
    if (!request) return;

    if (Array.isArray(data) && data.length === 1 && typeof data[0] === 'object') {
        data = data[0];
    }

    clearTimeout(request.timeoutId);
    delete awaiting[responseHash];

    if (typeof data === 'undefined') {
        request.resolve(null);
        return;
    }

    request.resolve(data);
});