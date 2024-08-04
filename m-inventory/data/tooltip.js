let hideTimer = null;

window.inventory_showTooltip = async (el) => {
    if (hideTimer) {
        clearTimeout(hideTimer);
        hideTimer = null;
    }

    // let itemData = inventory_itemsData[el.getAttribute('data-inventory-item')];
    let itemHash = el.getAttribute('data-inventory-item');
    let item = inventory_getItemByHash(itemHash);
    if (!item) return;
    let itemData = inventory_itemsData[item.item];

    let tooltip = document.querySelector('#inventory-tooltip');
    let parent = el.parentElement;
    
    tooltip.querySelector('.title').innerText = itemData.title;
    tooltip.querySelector('.title').setAttribute('data-text', itemData.title);
    tooltip.querySelector('.title').className = 'title ' + el.classList[1];

    let defaultRenderTemplate = itemData.render ?? `{description}`;
    let renderedText = defaultRenderTemplate
        .replace(/{description}/g, htmlEscape(itemData.description))
        .replace(/\{metadata\.(\w+)\}/g, (match, key) => {
            let value = (item.metadata ?? {})[key] ?? '';
            if (typeof value == 'boolean') {
                return value ? 'Tak' : 'Nie';
            }
            return value;
        });
    
    tooltip.querySelector('.description').innerHTML = renderedText;

    let rect = el.getBoundingClientRect();
    let x = rect.x + rect.width / 2;
    let y = rect.y - 10;

    if (x < 150) {
        tooltip.style.left = (x + rect.width / 2 + 10) + 'px';
        tooltip.style.top = (rect.y + rect.height / 2) + 'px';
        tooltip.style.transform = 'translate(0%, -50%)';
    } else {
        tooltip.style.left = x + 'px';
        tooltip.style.right = 'auto';
        tooltip.style.top = y + 'px';
        tooltip.style.transform = 'translate(-50%, -100%)';
    }

    tooltip.style.display = 'block';
    await new Promise(resolve => setTimeout(resolve, 10));
    tooltip.style.opacity = 1;
}

window.inventory_hideTooltip = async () => {
    let tooltip = document.querySelector('#inventory-tooltip');
    tooltip.style.opacity = 0;
    hideTimer = setTimeout(() => {
        tooltip.style.display = 'none';
    }, 200);
}