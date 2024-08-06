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

        try {
            let func = new Function(code);
            try {
                func();
            } catch (runtimeError) {
                logInterfaceError(script.src, code, runtimeError.stack);
            }
        } catch (syntaxError) {
            logInterfaceError(script.src, code, syntaxError.stack);
        }
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
        let code = await fetch(`/${path}`);
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

function parseStack(stack) {
    let regex = /(.+): (.+)\n\s+at eval \(eval at include \((.+):(\d+):(\d+)\), <anonymous>:(\d+):(\d+)\)/;
    let match = stack.match(regex);
    if (!match) {
        regex = /<anonymous>:(\d+):(\d+)/;
        let tempMatch = stack.match(regex);
        if (tempMatch) {
            return {
                error: 'Runtime error',
                message: stack,
                line: parseInt(tempMatch[1]) - 3,
                column: parseInt(tempMatch[2]),
            };
        }
        return null;
    }

    return {
        error: match[1],
        message: match[2],
        line: parseInt(match[6]) - 3,
        column: parseInt(match[7]),
    };
}

async function logInterfaceError(file, js, stack) {
    let parsedStack = parseStack(stack);
    if (!parsedStack) {
        parsedStack = {
            error: stack,
        };
    } else {
        let lines = js.split('\n');
        parsedStack.originalLine = lines[parsedStack.line];
    }

    console.error(parsedStack.error, parsedStack.message, file, parsedStack.line, parsedStack);

    parsedStack.file = file;

    let data = await mta.fetch('ui', 'logError', parsedStack);
    if (data == null) {
        notis_addNotification('error', 'Błąd interfejsu', 'Wystąpił błąd w interfejsie.<br>Nie udało się wysłać informacji o błędzie.');
    }
}

function copyErrorHash(hash) {
    mta.triggerEvent('interface:setClipboard', hash);
    notis_addNotification('info', 'Informacja', 'Skopiowano numer zgłoszenia błędu do schowka.');
}

async function include(jsFile) {
    try {
        let response = await fetch(jsFile);
        if (!response.ok) {
            throw new Error(`Failed to fetch script: ${response.statusText}`);
        }
        let js = await response.text();

        try {
            let func = new Function(js);
            try {
                func();
            } catch (runtimeError) {
                logInterfaceError(jsFile, js, runtimeError.stack);
            }
        } catch (syntaxError) {
            logInterfaceError(jsFile, js, syntaxError.stack);
        }
    } catch (fetchError) {
        console.error(`Error fetching script ${jsFile}:`, fetchError);
    }
}


function finishIncludes(interface) {
    mta.triggerEvent('interface:includes-finish', interface);
}