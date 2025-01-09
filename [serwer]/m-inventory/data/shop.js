window.inventory_shopData = false;
window.inventory_shoppingData = false;
let shopItems = [];

window.inventory_setShopVisible = async (appear) => {
    let element = document.querySelector('#inventory #inventory-shops');
    await new Promise(resolve => setTimeout(resolve, 100));
    element.style.opacity = appear ? '1' : '0';
    element.style.transform = appear ? 'translate(-50%, -50%)' : 'translate(-50%, -50%) scale(0.8)';
    if (!appear) await new Promise(resolve => setTimeout(resolve, 300));

    if (!document.body.contains(element)) return;
    element.classList.toggle('d-none', !appear);

    if (appear) {
        inventory_showShopsIntro();
    } else {
        intro_hideIntro('inventory-shops');
    }
}

async function setShopData(data) {
    let element = document.querySelector('#inventory #inventory-shops');
    element.classList.toggle('d-none', !data);

    inventory_setShopVisible(data);

    inventory_shopData = data;
    inventory_shoppingData = data ? [] : false;

    if (data) {
        inventory_renderShopItems(element.querySelector('#shop-items'), inventory_shopData.items);
        updateSelectedItems();
        element.querySelector('#shop-title').innerText = data.title;
        element.querySelector('#shop-description').innerText = data.description;
    }
}

function updateSelectedItems() {
    let element = document.querySelector('#inventory #inventory-shops');
    let selectedItems = element.querySelector('#selected-items');

    inventory_renderShopItems(selectedItems, inventory_shoppingData, true);

    let totalPrice = inventory_shoppingData.reduce((acc, item) => {
        switch (item.type) {
            case 'buy':
                return acc + item.total;
            case 'sell':
                return acc - item.total;
        }
    }, 0);

    if (isNaN(totalPrice)) totalPrice = 'Zależy od towaru';
    else totalPrice = `${totalPrice >= 0 ? '$' : '-$'}${addCents(Math.abs(totalPrice))}`;

    element.querySelector('#total-price').innerText = `Cena: ${totalPrice}`;
}

window.inventory_toggleDetails = (element) => {
    let detailsElement = element.querySelector('.details');
    let height = detailsElement.scrollHeight;
    detailsElement.classList.toggle('active');

    if (detailsElement.style.maxHeight) {
        detailsElement.style.maxHeight = null;
    } else {
        detailsElement.style.maxHeight = `${height}px`;
    }
}

window.inventory_renderShopItems = (element, items, myItems = false) => {
    if (inventory_itemsData.length === 0) return;
    if (!inventory_shopData) return;

    let shopItemsHtml = '';

    let categories = {};
    for (let item of items) {
        let category = item.category || 'Inne';

        if (!categories[category]) categories[category] = [];
        categories[category].push(item);
    }

    for (let category in categories) {
        shopItemsHtml += Object.keys(categories).length > 1 ? `
            <div class="details-wrapper d-flex flex-column">
                <summary class="d-flex gap-1 align-items-center" style="font-weight: 600; color: #ffffffcc;" onclick="inventory_toggleDetails(this.parentElement)" >
                    <div class="arrow">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" class="feather feather-chevron-right">
                            <polyline points="9 18 15 12 9 6"></polyline>
                        </svg>
                    </div>
                    ${category}
                </summary>
                <div class="d-flex flex-column gap-2 details">
        ` : `<div class="d-flex flex-column gap-2">`;

        for (let item of categories[category]) {
            let itemData = window.inventory_itemsData[item.item];

            shopItemsHtml += `
                <div class="d-flex justify-between align-items-center row">
                    <div class="d-flex gap-2 align-items-center">
                        ${inventory_renderItem({
                            amount: 1,
                            item: item.item,
                        }, itemData)}
                        <div class="d-flex flex-column">
                            <span class="label" style="font-weight: 600; color: #ffffffdd;">
                                ${
                                    !myItems ?
                                    `${typeof item.price == 'number' ? `$${addCents(item.price)} za sztukę` : 'Zależy od towaru'}` :
                                    (
                                        typeof item.price == 'number' ? `${item.count} x $${addCents(item.price)} = $${addCents(item.total)}` : 'Zależy od towaru'
                                    )
                                }
                            </span>
                            <span class="label">${item.type === 'buy' ? 'Kupno' : 'Sprzedaż'}</span>
                        </div>
                    </div>
                    <div class="flat-button flat-button-small" ${!myItems ? 'onclick="inventory_shop_addOrSell(this, event)"' : 'onclick="inventory_shop_removeFromCart(this)"'} data-item="${item.item}" data-type="${item.type}">
                        ${
                            !myItems ? 
                            `${item.type === 'buy' ? 'Dodaj do koszyka' : 'Sprzedaj'}`
                            : 'Usuń'
                        }
                    </div>
                </div>
            `;
        }
        
        shopItemsHtml += Object.keys(categories).length > 1 ? `</div></div>` : `</div>`;
    }

    if (shopItemsHtml.length === 0) {
        // shopItemsHtml = `<div class="pt-3 pb-3 d-flex justify-center align-items-center label row">Brak przedmiotów</div>`;
    }
    element.classList.toggle('d-none', shopItemsHtml.length === 0);
    element.previousElementSibling.classList.toggle('d-none', shopItemsHtml.length === 0);

    element.innerHTML = shopItemsHtml;
}

window.inventory_shop_getCategories = () => {
    let categories = [];
    for (let item of inventory_shopData.items) {
        if (!categories.includes(item.category)) {
            categories.push(item.category);
        }
    }

    return categories;
}

addEvent('inventory', 'interface:data:shopData', (data) => {
    data = data[0];

    setShopData(data);
});

window.inventory_shop_addToCart = (item, type, count) => {
    let itemData = window.inventory_itemsData[item];
    let price = inventory_shopData.items.find(i => i.item === item).price;

    let cartItem = inventory_shoppingData.find(i => i.item === item);
    if (cartItem) {
        if (type == 'sell' && typeof price == 'number' && inventory_getItemCount(item) < (cartItem.count + count)) {
            notis_addNotification('error', 'Sklep', 'Nie posiadasz tylu przedmiotów');
            return;
        }

        cartItem.count += count;
        cartItem.total = cartItem.count * price;
        updateSelectedItems();
        return;
    }

    if (type == 'sell' && typeof price == 'number' && inventory_getItemCount(item) < count) {
        notis_addNotification('error', 'Sklep', 'Nie posiadasz tylu przedmiotów');
        return;
    }

    cartItem = {
        item: item,
        type: type,
        count: count,
        price: price,
        total: price * count,
    };

    inventory_shoppingData.push(cartItem);
    updateSelectedItems();
}

window.inventory_shop_removeFromCart = (element) => {
    inventory_shoppingData = inventory_shoppingData.filter(i => i.item !== element.getAttribute('data-item'));
    updateSelectedItems();
}

window.inventory_shop_addOrSell = async (element, event) => {
    let item = element.getAttribute('data-item');
    let type = element.getAttribute('data-type');
    let price = inventory_shopData.items.find(i => i.item === item).price;

    let count = 1;
    if (typeof price == 'number') {
        inventory_renderOptions([]);
        inventory_setOptionsPosition(event);

        count = Math.min(await inventory_askForCount(), 100);
        if (!count || count < 1) return;
    }

    inventory_shop_addToCart(item, type, count);
}

window.inventory_buySelectedItems = async (button) => {
    if (isButtonSpinner(button)) return;
    
    if (inventory_shoppingData.length === 0) {
        notis_addNotification('error', 'Sklep', 'Nie wybrano żadnych przedmiotów');
        return;
    }

    makeButtonSpinner(button);
    let totalPrice = inventory_shoppingData.reduce((acc, item) => {
        switch (item.type) {
            case 'buy':
                return acc + item.total;
            case 'sell':
                return acc - item.total;
        }
    }, 0);

    if (totalPrice == 0) {
        notis_addNotification('error', 'Sklep', 'Nie wybrano żadnych przedmiotów');
        return;
    }

    let buyItems = {
        shopId: inventory_shopData.index,
        items: inventory_shoppingData.map(i => ({ item: i.item, count: i.count, type: i.type })),
    };

    let data = await mta.fetch('inventory', 'buyItems', buyItems);
    makeButtonSpinner(button, false);
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else if (data.status != 'success') {
        notis_addNotification('error', 'Błąd', data.message);
        return;
    }

    inventory_items = data.inventory;
    inventory_renderItems();
    notis_addNotification('success', 'Sklep', data.message);

    // clear cart
    inventory_shoppingData = [];
    updateSelectedItems();
}