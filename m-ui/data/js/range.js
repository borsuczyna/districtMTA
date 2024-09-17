let rangeInputs = [];

function createRangeInput(element) {
    updateRanges();
    element.classList.add('range-input');

    let thumb = document.createElement('div');
    thumb.classList.add('thumb');
    element.appendChild(thumb);

    // add progress bar
    let progressBar = document.createElement('div');
    progressBar.classList.add('range-bar');
    element.appendChild(progressBar);

    // apply progress
    let min = parseFloat(element.getAttribute('min'));
    let max = parseFloat(element.getAttribute('max'));
    let value = parseFloat(element.getAttribute('data-value'));
    let progress = (value - min) / (max - min) * 100 + '%';
    element.style.setProperty('--progress', progress);

    rangeInputs.push({
        element: element,
        min: min,
        max: max,
        step: element.getAttribute('step'),
        value: value,
    });
}

function setRangeInput(element, value) {
    let rangeInput = rangeInputs.find(r => r.element === element);
    rangeInput.value = value;

    let progress = (value - rangeInput.min) / (rangeInput.max - rangeInput.min) * 100 + '%';
    element.style.setProperty('--progress', progress);
    element.setAttribute('data-value', value);
    element.dispatchEvent(new Event('change'));
}

function setRangeInputMaxValue(element, value) {
    let rangeInput = rangeInputs.find(r => r.element === element);
    rangeInput.max = value;
    rangeInput.value = Math.min(rangeInput.value, value);
    setRangeInput(element, rangeInput.value);
}

function updateRanges() {
    rangeInputs = rangeInputs.filter(r => document.body.contains(r.element));
}

function stopHoldingRangeInput() {
    let rangeInput = rangeInputs.find(r => r.active);

    if (rangeInput) {
        rangeInput.active = false;
    }
}

addEvent('ranges', 'mousedown', (event) => {
    updateRanges();
    let rangeInput = rangeInputs.find(r => r.element === event.target || r.element.contains(event.target));

    if (rangeInput) {
        rangeInput.active = true;
    }
});

addEvent('ranges', 'mousemove', (event) => {
    updateRanges();
    let rangeInput = rangeInputs.find(r => r.active);

    if (rangeInput) {
        let rect = rangeInput.element.getBoundingClientRect();
        let value = Math.min(Math.max((event.clientX - rect.left) / rect.width, 0), 1);
        let newValue = rangeInput.min + value * (rangeInput.max - rangeInput.min);
        // add step and round it
        newValue = Math.round(newValue / rangeInput.step) * rangeInput.step;
        
        let progress = (newValue - rangeInput.min) / (rangeInput.max - rangeInput.min) * 100 + '%';

        rangeInput.element.style.setProperty('--progress', progress);
        rangeInput.element.setAttribute('data-value', newValue);
        rangeInput.value = newValue;

        rangeInput.element.dispatchEvent(new Event('change'));
    }
});

addEvent('ranges', 'mouseup', () => {
    updateRanges();
    let rangeInput = rangeInputs.find(r => r.active);

    if (rangeInput) {
        rangeInput.active = false;
    }
});