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
}

async function setInterfaceVisible(name, visible) {
    let element = document.getElementById(name);
    if (!element) return;
    
    element.style.display = visible ? 'flex' : 'none';
}

function destroyInterfaceElement(name) {
    let element = document.getElementById(name);
    if (element) {
        element.remove();
    }
    removeElementEvents(name);
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