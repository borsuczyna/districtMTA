let loadedInterfaces = [];
let visibleInterfaces = [];

function getInterfaceElement(name) {
    let element = document.getElementById(name);
    if (element === null) {
        element = document.createElement('div');
        element.id = name;
        element.className = 'interface';
        element.style.display = 'none';
        document.body.appendChild(element);
    }

    return element;
}

function executeElementScripts(element) {
    let scripts = element.querySelectorAll('script');
    for (let script of scripts) {
        let code = script.innerHTML;
        script.remove();

        let func = new Function(code);
        func();
    }
}

async function loadInterfaceElement(name) {
    try {
        let code = await fetch(`interface/${name}.html`);
        let html = await code.text();
        let element = getInterfaceElement(name);
        element.innerHTML = html;
        executeElementScripts(element);
        
        mta.triggerEvent('interface:load', name);
        loadedInterfaces.push(name);
    }
    catch (e) {
        console.error(e);
    }
}

async function loadInterfaceElementFromFile(name, path) {
    try {
        let code = await fetch(`../../${path}`);
        let html = await code.text();
        let element = getInterfaceElement(name);
        element.innerHTML = html;
        executeElementScripts(element);
        
        mta.triggerEvent('interface:load', name);
        loadedInterfaces.push(name);
    }
    catch (e) {
        console.error(e);
    }
}

function loadInterfaceElementFromCode(name, code) {
    let element = getInterfaceElement(name);
    element.innerHTML = code;
    executeElementScripts(element);

    mta.triggerEvent('interface:load', name);
    loadedInterfaces.push(name);
}

async function setInterfaceVisible(name, visible) {
    let element = document.getElementById(name);
    if (!element) return;
    
    element.style.display = visible ? 'flex' : 'none';

    if (visible) {
        if (!visibleInterfaces.includes(name)) {
            visibleInterfaces.push(name);
        }
    } else {
        visibleInterfaces = visibleInterfaces.filter(i => i !== name);
    }

    triggerAllEvents('interface:visible', name, visible);
}

function destroyInterfaceElement(name) {
    let element = document.getElementById(name);
    if (element) {
        element.remove();
    }
    removeElementEvents(name);
    loadedInterfaces = loadedInterfaces.filter(i => i !== name);
    visibleInterfaces = visibleInterfaces.filter(i => i !== name);
    
    triggerAllEvents('interface:visible', name, false);
}

function setInterfaceData(interfaceName, key, value) {
    triggerEvent(interfaceName, 'interface:data:' + key, value);
}

function setInterfaceZIndex(name, zIndex) {
    let element = document.getElementById(name);
    if (element) {
        element.style.zIndex = zIndex;
    }
}

function isInterfaceVisible(name) {
    return visibleInterfaces.includes(name);
}

function isInterfaceLoaded(name) {
    return loadedInterfaces.includes(name);
}

function applyHexColor(text) {
    let result = '';
    let i = 0;
    while (i < text.length) {
        const hashIndex = text.indexOf('#', i);
        if (hashIndex === -1) {
            result += text.substring(i);
            break;
        }

        result += text.substring(i, hashIndex);

        const color = text.substring(hashIndex, hashIndex + 7);
        result += `<span style="color: ${color}">`;

        i = hashIndex + 7;
        const nextHashIndex = text.indexOf('#', i);
        if (nextHashIndex === -1) {
            result += text.substring(i);
            break;
        }

        result += text.substring(i, nextHashIndex);
        result += '</span>';
        i = nextHashIndex;
    }

    return result;
}

function htmlEscape(text) {
    return text.replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

async function include(jsFile) {
    try {
        let code = await fetch(jsFile);
        let js = await code.text();
        let func = new Function(js);
        func();
    } catch (e) {
        console.error(e);
    }
}

function finishIncludes(interface) {
    mta.triggerEvent('interface:includes-finish', interface);
}