window.inventory_items = [];

function fixRows(element) {
    let emptyRows = element.querySelectorAll('.item.empty');
    emptyRows.forEach(row => row.remove());

    let items = element.querySelectorAll('.item');
    let itemsCount = items.length;

    let rows = Math.max(Math.ceil(itemsCount / 5), 1);
    let emptyItems = rows * 5 - itemsCount;

    for (let i = 0; i < emptyItems; i++) {
        let item = document.createElement('div');
        item.classList.add('item', 'empty');
        element.appendChild(item);
    }
}

window.inventory_getItemByHash = (hash) => {
    let itemData = inventory_items.find(item => item.hash === hash);
    if (!itemData) {
        itemData = inventory_theirOffer.find(item => item.hash === hash);
    }

    return itemData;
}

function renderItem(item, itemData) {
    return `<div class="item ${itemData.rarity}" data-inventory-item="${item.hash}" onmouseover="inventory_showTooltip(this)" onmouseleave="inventory_hideTooltip()" onclick="inventory_showOptions(event, this)">
        <img src="${itemData.icon}"/>
        ${item.amount > 1 ? `<div class="count">${item.amount}</div>` : ''}
    </div>`;
}

window.inventory_renderItems = (allItems = false, element = null, itemsList = null) => {
    let category = allItems ? 'all' : document.querySelector('#inventory .category.active').getAttribute('key');
    let items = element ?? document.querySelector('#inventory #items-wrapper .items');
    items.innerHTML = '';

    for (let item of (itemsList ?? inventory_items)) {
        let itemData = inventory_itemsData[item.item];

        if (category !== 'all' && itemData.category !== category) continue;

        items.innerHTML += renderItem(item, itemData);
    }

    fixRows(element ?? items);
}

function toggleItemsLoading(visible) {
    document.querySelector('#inventory #items-wrapper').classList.toggle('d-none', visible);
    document.querySelector('#inventory #items-loading').classList.toggle('d-none', !visible);
}

window.inventory_loadItems = async () => {
    toggleItemsLoading(true);
    let data = await mta.fetch('inventory', 'getInventory');
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    }

    inventory_items = data.inventory;
    inventory_renderItems();
    toggleItemsLoading(false);
}