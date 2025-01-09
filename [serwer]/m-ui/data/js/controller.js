let controllerMode = false;
let controllerName = null;
let usingController = false;
let controller = {
    axes : [
        {x: 0, y: 0},
        {x: 0, y: 0}
    ],
    buttons : [],
    lastAxes : [
        {x: 0, y: 0},
        {x: 0, y: 0}
    ],
    axesHoldTime : [
        {x: 0, y: 0},
        {x: 0, y: 0}
    ]
};

let elementSearch = [
    '.nice-button',
    '.flat-button',
    '.dt-paging-button:not(.disabled)',
    '.list .item:not(.ignore)',
    '#list .item:not(.ignore)',
    '.switch',
    'a',
    '.__maps-map',
    '.__maps-map-blip',
    '#f11 .controls svg',
    '.button',
    '.items .item:not(.empty)',
    '#inventory-options .option',
    '.categories .category',
    '.recipe .item',
    '.hoverable',
    '#spawn-categories .item',
    '.category-items.active .spawn',
    '.nice-input input',
    '#icons .icon',
    '.texture-list .item',
    '#shop-items summary',
    '.details-wrapper .item',
];

let clickParents = [
    '.switch',
];

function setCurrentControllerMode(mode) {
    controllerMode = mode;
}

function isCursorOverMap() {
    let overElement = document.elementFromPoint(cursorPosition.x, cursorPosition.y);
    return overElement?.closest('.__maps-map') !== null;
}

function setUsingController(value) {
    usingController = value;
    
    if (usingController) {
        document.body.classList.add('controller');
    } else {
        document.body.classList.remove('controller');
    }
}

function updateControllers() {
    let newGamepads = navigator.getGamepads();
    let lastAxes = [...controller.axes];
    let lastButtons = [...controller.buttons];
    
    for (let i = 0; i < newGamepads.length; i++) {
        let gamepad = newGamepads[i];
        if (gamepad) {
            controller.axes = [
                {x: gamepad.axes[0], y: gamepad.axes[1]},
                {x: gamepad.axes[2], y: gamepad.axes[3]}
            ];
            controller.buttons = gamepad.buttons.map(button => button.value);
        }
    }

    for (let i = 0; i < controller.axes.length; i++) {
        if (controller.axes[i].x !== lastAxes[i].x || controller.axes[i].y !== lastAxes[i].y) {
            triggerAllEvents('onControllerAxisChange', i, controller.axes[i].x, controller.axes[i].y);

            let distance = Math.sqrt(Math.pow(controller.axes[i].x, 2) + Math.pow(controller.axes[i].y, 2));
            if (distance > 0.1) {
                setUsingController(true);
            }
        }
    }

    for (let i = 0; i < controller.buttons.length; i++) {
        if (controller.buttons[i] !== lastButtons[i]) {
            triggerAllEvents('onControllerButtonChange', i, controller.buttons[i]);
            setUsingController(true);

            // on arrow buttons trigger onControllerAxisHoldDrop
            let isArrowButton = i >= 12 && i <= 15;
            let lastButton = lastButtons[i] > 0.5;
            if (!lastButton && controller.buttons[i] > 0.5 && isArrowButton) {
                triggerAllEvents('onControllerAxisHoldDrop', 0, (
                    i === 12 ? '-y' : i === 13 ? 'y' : i === 14 ? '-x' : 'x'
                ), 0, true);
            }
        }
    }

    // if any axis is > 0.5 and hold time is 0, set hold time to tick
    for (let i = 0; i < controller.axes.length; i++) {
        let keys = Object.keys(controller.axes[i]);
        for (let axis of keys) {
            let beingHeld = controller.axes[i][axis] > 0.9 || controller.axes[i][axis] < -0.9;

            if (beingHeld && controller.axesHoldTime[i][axis] === 0) {
                controller.axesHoldTime[i][axis] = new Date().getTime();
            } else if (controller.axesHoldTime[i][axis] !== 0 && !beingHeld) {
                let time = new Date().getTime() - controller.axesHoldTime[i][axis];
                let drawAxis = (lastAxes[i][axis] < 0 ? '-' : '') + axis;
                triggerAllEvents('onControllerAxisHoldDrop', i, drawAxis, time);
                controller.axesHoldTime[i][axis] = 0;
            }
        }
    }

    controller.lastAxes = [...controller.axes];
    updateBrowserTitle();

    if (!controllerMode && !isCursorOverMap()) {
        let axis = controller.axes[0];
        let distance = Math.sqrt(Math.pow(axis.x, 2) + Math.pow(axis.y, 2));
        if (distance > 0.1) {
            mta.triggerEvent('cursor:move', axis.x, axis.y);
        }

        // on second axis scroll element that is hovered
        if (Math.abs(controller.axes[1].y) < 0.1) return;

        let overElement = document.elementFromPoint(cursorPosition.x, cursorPosition.y);
        if (overElement && overElement.closest('.__maps-map')) return;
        let scrollableParent = overElement;
        while (scrollableParent && scrollableParent.scrollHeight <= scrollableParent.clientHeight) {
            scrollableParent = scrollableParent.parentElement;
        }

        let tag = scrollableParent?.tagName.toLowerCase();
        if (tag === 'body' || tag === 'html') return;
        if (scrollableParent && scrollableParent.scrollHeight > scrollableParent.clientHeight) {
            let scrollAmount = controller.axes[1].y * 10;
            scrollableParent.scrollTop += scrollAmount;
        }
    }
}

window.addEventListener('gamepadconnected', function(e) {
    notis_addNotification('info', 'Nowy kontroler', `Kontroler ${e.gamepad.id} został wykryty!`);
    controllerName = e.gamepad.id;
    triggerAllEvents('onControllerConnected', e.gamepad.id);
});

function getControllerAxis(axis) {
    return controller.axes[axis];
}

function getControllerButton(button) {
    return controller.buttons[button] ? controller.buttons[button] : 0;
}

function isControllerButtonDown(button) {
    return controller.buttons[button] > 0.5;
}

setInterval(updateControllers, 1000 / 60);

// SWAPPING
function queryElements(selectors) {
    return selectors.reduce((acc, selector) => {
        return acc.concat(Array.from(document.querySelectorAll(selector)));
    }, []);
}

let cursorPosition = { x: 0, y: 0 };

addEvent('ui', 'mousemove', (event) => {
    cursorPosition = { x: event.clientX, y: event.clientY };
});

addEvent('ui', 'onControllerAxisHoldDrop', (axisId, axis, time, isArrow) => {
    if ((!controllerMode && !isArrow) || time > 300 || axisId !== 0 || !cursorVisible || (isCursorOverMap() && !isArrow)) return;
    
    let possibleElements = queryElements(elementSearch);
    let swapElements = possibleElements.map(element => {
        let rect = element.getBoundingClientRect();
        let valid = (
            axis == 'x' && rect.left > cursorPosition.x ||
            axis == '-x' && rect.right < cursorPosition.x ||
            axis == 'y' && rect.top > cursorPosition.y ||
            axis == '-y' && rect.bottom < cursorPosition.y
        );

        // ignore elements that are not visible or x + w <= 0 or y + h <= 0
        valid = valid && rect.width > 0 && rect.height > 0;
        if (!valid) return { element, valid, distance: 0 };

        // check if ANY parent width or height is 0
        // let parent = element;
        // while (parent) {
        //     let parentRect = parent.getBoundingClientRect();
        //     if (parentRect.width <= 0 || parentRect.height <= 0) {
        //         valid = false;
        //         return { element, valid, distance: 0 };
        //     }
        //     parent = parent.parentElement;
        // }

        let xDistance = Math.min(Math.abs(rect.left - cursorPosition.x), Math.abs(rect.right - cursorPosition.x));
        let yDistance = Math.min(Math.abs(rect.top - cursorPosition.y), Math.abs(rect.bottom - cursorPosition.y));
        if (axis == 'x' || axis == '-x') {
            yDistance *= 0.5;
        } else {
            xDistance *= 0.5;
        }

        let distance = Math.sqrt(Math.pow(xDistance, 2) + Math.pow(yDistance, 2));
        return { element, valid, distance };
    }).filter(({ valid }) => valid);

    if (swapElements.length == 0) return;

    // find the closest element
    swapElements.sort((a, b) => a.distance - b.distance);

    // console log position of the closest element
    let closestElement = swapElements[0];
    if (closestElement) {
        let rect = closestElement.element.getBoundingClientRect();
        let [x, y] = [rect.left + rect.width / 2, rect.top + rect.height / 2];
        if (!x && !y) return;

        // first, lets find the scrollable parent
        let scrollParent = closestElement.element;
        while (scrollParent && scrollParent.scrollHeight <= scrollParent.clientHeight) {
            scrollParent = scrollParent.parentElement;
        }

        if (scrollParent && scrollParent.scrollHeight > scrollParent.clientHeight) {
            let scrollParentRect = scrollParent.getBoundingClientRect();
            let scrollParentCenter = scrollParentRect.top + scrollParentRect.height / 2;
            let elementCenter = rect.top + rect.height / 2;

            let scrollAmount = elementCenter - scrollParentCenter;
            scrollParent.scrollTop += scrollAmount;
        }

        // recalculating the position
        rect = closestElement.element.getBoundingClientRect();
        x = rect.left + rect.width / 2;
        y = rect.top + rect.height / 2;

        mta.triggerEvent('cursor:setPosition', x, y);
        // print what snapped on
        console.log(closestElement.element);
    }
});

function getTopMostElement(elements) {
    if (!elements || elements.length === 0) return null;

    // Sort elements by their stacking context
    elements.sort((a, b) => {
        // Get stacking context
        const compare = compareStackingContext(a, b);
        return compare !== 0 ? compare : 0;
    });

    // The last element in the sorted array should be the topmost
    return elements[elements.length - 1];
}

function compareStackingContext(a, b) {
    // Compare by z-index context and position in DOM hierarchy
    const positionA = window.getComputedStyle(a).position;
    const positionB = window.getComputedStyle(b).position;

    // Handle positioned elements (relative, absolute, fixed)
    if (isPositioned(positionA) && isPositioned(positionB)) {
        return getZIndex(a) - getZIndex(b);
    }

    // Handle one positioned and one non-positioned element
    if (isPositioned(positionA)) return 1;
    if (isPositioned(positionB)) return -1;

    // Both are non-positioned, compare by DOM hierarchy
    if (a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING) return -1;
    if (a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_PRECEDING) return 1;

    return 0;
}

function isPositioned(position) {
    return position === 'relative' || position === 'absolute' || position === 'fixed';
}

function getZIndex(element) {
    const zIndex = window.getComputedStyle(element).zIndex;
    return zIndex === 'auto' ? 0 : parseInt(zIndex, 10);
}

addEvent('ui', 'onControllerButtonChange', (button, value) => {
    if (button != 0 || isCursorOverMap()) return;

    mta.triggerEvent('cursor:click', 'left', value == 1);
});

function distance2d(x1, y1, x2, y2) {
    return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
}