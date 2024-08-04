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
};

window.inventory_renderCategories = () => {
    let categoriesEl = document.querySelector('#inventory .categories');
    let categoriesKeys = Object.keys(categories);

    categoriesEl.innerHTML = '';
    for (let i = 0; i < categoriesKeys.length; i++) {
        categoriesEl.innerHTML += `<div class="category ${i == 0 ? 'active' : ''}" onclick="inventory_setCategory(this)" key="${categoriesKeys[i]}">
            ${categories[categoriesKeys[i]].icon}
        </div>`;
    }
}

window.inventory_setCategory = function (el) {
    let categoriesEl = document.querySelector('#inventory .categories');
    let categoriesKeys = Object.keys(categories);

    categoriesEl.querySelectorAll('.category').forEach(category => category.classList.remove('active'));
    el.classList.add('active');

    let selectedCategory = el.getAttribute('key');
    inventory_toggleNearbyPlayers(selectedCategory == 'trade');

    inventory_renderItems();
}