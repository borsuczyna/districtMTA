let controllerElement = document.querySelector('#dashboard #controller-preview');
let controllerElements = {
    controllers: {
        0: controllerElement.querySelector('#Axis1'),
        1: controllerElement.querySelector('#Axis2'),
    },
    buttons: {
        0: controllerElement.querySelector('#B0'),
        1: controllerElement.querySelector('#B1'),
        2: controllerElement.querySelector('#B2'),
        3: controllerElement.querySelector('#B3'),
        4: controllerElement.querySelector('#B4'),
        5: controllerElement.querySelector('#B5'),
        6: controllerElement.querySelector('#B6'),
        7: controllerElement.querySelector('#B7'),
        8: controllerElement.querySelector('#B8'),
        9: controllerElement.querySelector('#B9'),
        12: controllerElement.querySelector('#B12'),
        13: controllerElement.querySelector('#B13'),
        14: controllerElement.querySelector('#B14'),
        15: controllerElement.querySelector('#B15'),
        16: controllerElement.querySelector('#B16'),
        17: controllerElement.querySelector('#B17'),
    }
};

function dist(x, y) {
    return Math.sqrt(x * x + y * y);
}

addEvent('dashboard', 'onControllerAxisChange', (axis, x, y) => {
    let axisElement = controllerElements.controllers[axis];
    if (!axisElement) return;

    axisElement.style.transform = `translate(${x * 1}rem , ${y * 1}rem)`;
    axisElement.style.fill = `rgba(255, 255, 255, ${dist(x, y)})`;
});

addEvent('dashboard', 'onControllerButtonChange', (button, value) => {
    let buttonElement = controllerElements.buttons[button];
    if (!buttonElement) return;

    buttonElement.style.fill = `rgba(255, 255, 255, ${value})`;
    buttonElement.dataset.value = value;
});

addEvent('dashboard', 'onControllerConnected', (name) => {
    document.querySelector('#dashboard #controller-name').innerHTML = name;
});

document.querySelector('#dashboard #controller-name').innerHTML = controllerName ?? 'Nie wykryto kontrolera';