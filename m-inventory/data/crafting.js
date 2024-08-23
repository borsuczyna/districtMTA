window.inventory_craftingRecipes = [];

window.inventory_toggleCrafting = async (appear) => {
    if (appear != false && appear != true) {
        appear = !(document.querySelector('#inventory #inventory-crafting').style.opacity === '1');
    }

    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#inventory #inventory-crafting').style.opacity = appear ? '1' : '0';
    document.querySelector('#inventory #inventory-crafting').style.transform = appear ? 'translate(-50%, -50%)' : 'translate(-50%, -50%) scale(0.8)';

    if (appear) {
        let categoriesEl = document.querySelector('#inventory #inventory-crafting .categories');
        inventory_renderCategories(categoriesEl);
        inventory_renderCrafting();

        if (inventory_craftingRecipes.length === 0) {
            mta.triggerEvent('inventory:getCraftingRecipes');
        }
    }
}

function renderCraftingRecipe(recipe, recipeId) {
    let html = `
    <div class="recipe">
        <div class="recipe-name mb-1">${recipe.name}</div>
        <div class="d-flex gap-2 align-items-center">`;

    for (let id in recipe.ingredients) {
        let item = recipe.ingredients[id];
        let itemData = window.inventory_itemsData[item.item];
        let isLast = parseInt(id) === recipe.ingredients.length - 1;
        let count = Math.min(inventory_getItemCount(item.item), item.amount);

        html += inventory_renderItem({
            item: item.item,
            amount: `${count}/${item.amount}`,
        }, itemData);

        html += `<span class="symbol">${(isLast ? `= ` : `+ `)}</span>`;
    }

    let resultItemData = window.inventory_itemsData[recipe.result];
    html += inventory_renderItem({
        item: recipe.result,
        amount: recipe.resultAmount,
        crafting: recipeId,
    }, resultItemData);

    html += `
        </div>
    </div>`;

    return html;
}

window.inventory_isCraftingOpen = () => {
    let opacity = document.querySelector('#inventory #inventory-crafting').style.opacity;
    if (!opacity) return false;
    return opacity === '1';
}

window.inventory_renderCrafting = () => {
    if (inventory_craftingRecipes.length === 0) return;
    if (inventory_itemsData.length === 0) return;

    let recipesElement = document.querySelector('#inventory #inventory-crafting #recipes');
    let category = document.querySelector('#inventory #inventory-crafting .categories .category.active').getAttribute('key');
    let filteredRecipes = inventory_craftingRecipes.filter(recipe => category === 'all' || recipe.category === category);

    document.querySelector('#inventory #inventory-crafting #crafting-loading').classList.add('d-none');
    recipesElement.classList.remove('d-none');

    let html = '';

    for (let recipeId in filteredRecipes) {
        let recipe = filteredRecipes[recipeId];
        html += renderCraftingRecipe(recipe, recipeId);
    }

    recipesElement.innerHTML = html;
}

window.inventory_craftItem = async (recipeId) => {
    recipeId = parseInt(recipeId) + 1;
    let data = await mta.fetch('inventory', 'craftItem', recipeId);
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else if (data.status === 'error') {
        notis_addNotification('error', 'Błąd', data.message);
        return;
    }

    notis_addNotification('success', 'Sukces', data.message);
    inventory_items = data.inventory;
    inventory_renderItems();
}

addEvent('inventory', 'interface:data:craftingRecipes', (data) => {
    data = data[0];

    window.inventory_craftingRecipes = data;
    inventory_renderCrafting();
});