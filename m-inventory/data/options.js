let hideOptionsTimer = null;
let useItem = false;
let waiting = false;
let prevHtml = '';
let possibleOptions = {
    use: {
        name: 'Użyj',
        icon: inventory_icons.target,
        action: async (hash) => {
            let item = inventory_getItemByHash(hash);
            if (!item) return;
            
            let data = await mta.fetch('inventory', 'useItem', hash);
            inventory_hideOptions();
            
            if (data == null) {
                notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
                return;
            } else if (data.status != 'success') {
                notis_addNotification('error', 'Błąd', data.message);
            }

            inventory_items = data.inventory;
            inventory_renderItems();
        }
    },
    close: {
        name: 'Zamknij',
        icon: inventory_icons.close,
        action: async () => {
            inventory_hideOptions();
        }
    },
    remove: {
        name: 'Usuń z oferty',
        icon: inventory_icons.close,
        action: inventory_removeFromOffer
    },
    add_to_offer: {
        name: 'Dodaj do oferty',
        icon: inventory_icons.add,
        action: inventory_addToOffer
    }
};

window.inventory_askForCount = async (max = 9999) => {
    let optionsEl = document.querySelector('#inventory-options');
    prevHtml = optionsEl.innerHTML;

    optionsEl.style.padding = '0.25rem';
    optionsEl.innerHTML = `
        <input type="number" id="count" class="input" placeholder="Ilość" min="1" max="${max}" />
        <div class="flat-button flat-button-small" onclick="inventory_askForCountSubmit(this.previousElementSibling.value)">Zatwierdź</div>
    `;

    return new Promise(resolve => {
        window.inventory_askForCountSubmit = (value) => {
            optionsEl.style.padding = '';
            optionsEl.innerHTML = prevHtml;
            inventory_hideOptions();
            resolve(value ? parseInt(value) : 0);
        }
    });
}

window.inventory_renderOptions = async (options) => {
    if (hideOptionsTimer) {
        clearTimeout(hideOptionsTimer);
        hideOptionsTimer = null;
    }

    let optionsEl = document.querySelector('#inventory-options');
    optionsEl.innerHTML = '';

    let chosenOptions = {};
    for (let option of options) {
        if (possibleOptions[option]) {
            chosenOptions[option] = possibleOptions[option];
        }
    }

    for (let [key, option] of Object.entries(chosenOptions)) {
        optionsEl.innerHTML += `<div class="option" onclick="inventory_optionClick('${key}', this)">
            ${option.icon}
            ${option.name}
        </div>`;
    }

    optionsEl.style.display = 'flex';
    optionsEl.classList.add('show');
    await new Promise(resolve => setTimeout(resolve, 10));
    optionsEl.style.opacity = 1;
}

window.inventory_hideOptions = () => {
    let optionsEl = document.querySelector('#inventory-options');
    optionsEl.style.opacity = 0;
    optionsEl.classList.remove('show');
    hideOptionsTimer = setTimeout(() => {
        optionsEl.style.display = 'none';
    }, 200);
}

window.inventory_optionClick = async (action, button) => {
    if (waiting) return;
    
    let hash = useItem.getAttribute('data-inventory-item');
    let item = inventory_getItemByHash(hash);
    if (!item) return;
    
    if (!possibleOptions[action] || !possibleOptions[action].action) return;
    
    let parent = useItem?.parentElement;
    
    waiting = true;
    makeButtonSpinner(button);
    await possibleOptions[action].action(hash);
    makeButtonSpinner(button, false);
    waiting = false;

    if (!parent || !parent.querySelector(`[data-inventory-item="${hash}"]`)) {
        inventory_hideOptions();
    } else {
        useItem = parent.querySelector(`[data-inventory-item="${hash}"]`);
    }
}

function setOptionsPosition(event) {
    let optionsEl = document.querySelector('#inventory-options');
    let x = event.clientX;
    let y = event.clientY;

    optionsEl.style.left = x + 'px';
    optionsEl.style.top = y + 'px';
}

window.inventory_showOptions = async (event, el) => {
    let itemHash = el.getAttribute('data-inventory-item');
    let item = inventory_getItemByHash(itemHash);
    if (!item) return;
    let itemData = inventory_itemsData[item.item];

    let options = [itemData.onUse != false ? 'use' : null, 'close', ...(itemData.specialOptions ?? [])];

    let insideYourOffer = el.parentElement.parentElement.id == 'your-offer-wrapper';
    let insideTheirOffer = el.parentElement.parentElement.id == 'their-offer-wrapper';
    
    if (insideYourOffer) {
        options = ['remove', 'close'];
    } else if (insideTheirOffer) {
        return;
    } else if (window.inventory_isTrading) {
        options = ['add_to_offer', 'close'];
    }

    inventory_renderOptions(options);
    setOptionsPosition(event);
    useItem = el;
}