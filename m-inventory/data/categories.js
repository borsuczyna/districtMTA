let categories = {
    'all': {
        name: 'Wszystko',
        icon: inventory_icons.star,
    },
    'food': {
        name: 'Jedzenie',
        icon: inventory_icons.food,
    },
    'fish': {
        name: 'Ryby',
        icon: inventory_icons.fish,
    },
    'weapon': {
        name: 'Broń',
        icon: inventory_icons.weapon,
    },
    'trade': {
        name: 'Wymiana',
        icon: inventory_icons.trade,
    },
    'craft': {
        name: 'Crafting',
        icon: inventory_icons.craft,
    },
};

window.inventory_renderCategories = (element) => {
    let categoriesEl = element ?? document.querySelector('#inventory #inventory-wrapper .categories');
    let categoriesKeys = Object.keys(categories);

    categoriesEl.innerHTML = '';
    for (let i = 0; i < categoriesKeys.length; i++) {
        let category = categoriesKeys[i];
        if ((category == 'trade' || category == 'craft') && element != null) continue;
        categoriesEl.innerHTML += `<div class="category ${i == 0 ? 'active' : ''}" onclick="inventory_setCategory(this)" key="${categoriesKeys[i]}">
            ${categories[categoriesKeys[i]].icon}
        </div>`;
    }
}

window.inventory_setCategory = function (el) {
    let categoriesEl = el.parentElement;
    let categoriesKeys = Object.keys(categories);
    let selectedCategory = el.getAttribute('key');

    if (selectedCategory == 'craft') {
        inventory_toggleCrafting();
        return;
    }

    categoriesEl.querySelectorAll('.category').forEach(category => category.classList.remove('active'));
    el.classList.add('active');

    inventory_toggleNearbyPlayers(selectedCategory == 'trade');

    let insideCrafting = categoriesEl.closest('#inventory-crafting') != null;
    if (!insideCrafting) {
        inventory_renderItems();
    } else {
        inventory_renderCrafting();
    }
}