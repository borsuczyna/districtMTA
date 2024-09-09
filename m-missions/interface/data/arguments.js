window.editor_renderArgument = (argument, valueArray, index, callback) => {
    let value = valueArray?.[index] ?? argument.default ?? '';

    if (argument.type === 'string' || argument.type === 'number') {
        return `<div class="argument" data-type="${argument.type}">
            <div class="name">${argument.name}</div>
            <input type="${argument.type === 'string' ? 'text' : 'number'}" value="${value}" placeholder="${argument.name}" onchange="${callback}(this.parentElement, ${index})">
        </div>`;
    } else if (argument.type === 'position') {
        value = typeof value === 'string' ? { x: 0, y: 0, z: 0 } : value;

        return `<div class="argument" data-type="${argument.type}">
            <div class="name">${argument.name}</div>
            <div class="d-flex gap-1">
                <input type="number" value="${value.x}" placeholder="X" onchange="${callback}(this.parentElement.parentElement, ${index})">
                <input type="number" value="${value.y}" placeholder="Y" onchange="${callback}(this.parentElement.parentElement, ${index})">
                <input type="number" value="${value.z}" placeholder="Z" onchange="${callback}(this.parentElement.parentElement, ${index})">
                <div class="flat-button flat-button-small" onclick="editor_setArgumentCurrentPosition(this, ${index}, ${callback})">Aktualna pozycja</div>
            </div>
        </div>`;
    } else if (argument.type === 'color') {
        value = typeof value === 'string' ? [255, 255, 255, 255] : value;
        let color = `#${value[0].toString(16).padStart(2, '0')}${value[1].toString(16).padStart(2, '0')}${value[2].toString(16).padStart(2, '0')}`;

        return `<div class="argument" data-type="${argument.type}">
            <div class="name">${argument.name}</div>
            <input type="color" value="${color}" onchange="${callback}(this.parentElement, ${index})">
        </div>`;
    } else if (argument.type === 'select') {
        let options = argument.options.map(option => `<option value="${option}" ${option === value ? 'selected' : ''}>${option}</option>`).join('');
        
        return `<div class="argument" data-type="${argument.type}">
            <div class="name">${argument.name}</div>
            <select onchange="${callback}(this.parentElement, ${index})">${options}</select>
        </div>`;
    } else {
        return `<div class="argument">Argument type not supported: ${argument.type}</div>`;
    }
}

window.editor_setArgumentCurrentPosition = async (button, index, callback) => {
    makeButtonSpinner(button);
    let data = await mta.fetch('missions', 'getCurrentPosition');

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
        let { x, y, z } = data.data;
        let inputs = button.parentElement.querySelectorAll('input');
        inputs[0].value = x;
        inputs[1].value = y;
        inputs[2].value = z;

        callback(button.parentElement.parentElement, index);
    }
    
    makeButtonSpinner(button, false);
}

window.editor_getValue = (element) => {
    if (element.dataset.type === 'string' || element.dataset.type === 'number') {
        return element.querySelector('input').value;
    } else if (element.dataset.type === 'position') {
        let inputs = element.querySelectorAll('input');
        return { x: inputs[0].value, y: inputs[1].value, z: inputs[2].value };
    } else if (element.dataset.type === 'color') {
        let color = element.querySelector('input').value;
        let r = parseInt(color.substring(1, 3), 16);
        let g = parseInt(color.substring(3, 5), 16);
        let b = parseInt(color.substring(5, 7), 16);
        let a = 255;
        return [r, g, b, a];
    } else {
        return null;
    }
}