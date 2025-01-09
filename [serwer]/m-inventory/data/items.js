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

window.inventory_renderItem = (item, itemData) => {
    return `
    <div
        class="item hoverable ${itemData.rarity}"
        ${item.hash ? `data-inventory-item="${item.hash}"` : `data-inventory-item-data="${item.item}"`}
        ${item.crafting ? `data-crafting="${item.crafting}"` : ''}
        onmouseover="inventory_showTooltip(this)"
        onmouseleave="inventory_hideTooltip()"
        onclick="inventory_showOptions(event, this)"
    >
        <img src="${itemData.icon}"/>
        ${(typeof item.amount == 'string' || item.amount > 1) ? `<div class="count">${item.amount}</div>` : ''}
    </div>`;
}

window.inventory_renderItems = (allItems = false, element = null, itemsList = null) => {
    let category = allItems ? 'all' : document.querySelector('#inventory #inventory-wrapper .category.active').getAttribute('key');
    let items = element ?? document.querySelector('#inventory #items-wrapper .items');
    items.innerHTML = '';

    for (let item of (itemsList ?? inventory_items)) {
        let itemData = inventory_itemsData[item.item];

        if (category !== 'all' && itemData.category !== category) continue;

        items.innerHTML += inventory_renderItem(item, itemData);
    }

    fixRows(element ?? items);
}

window.inventory_getItemCount = (item) => {
    let items = inventory_items.filter(i => i.item === item);
    return items.reduce((a, b) => a + b.amount, 0);
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
    inventory_renderCrafting();
    toggleItemsLoading(false);
}