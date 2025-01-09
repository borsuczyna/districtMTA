let categories = [];

tuning_renderCategories = () => {
    let html = '';
    categories.forEach(option => {
        html += `
            <div class="option" data-key="${option.key}" data-tooltip="${option.name}" onclick="tuning_selectCategory('${option.key}')">
                ${tuning_icons[option.icon]}
            </div>
        `;
    });
    document.querySelector('#tuning #options').innerHTML = html;
}

tuning_installItem = async (button, index) => {
    let category = document.querySelector('#tuning .option.active').dataset.key;
    let item = categories.find(c => c.key === category).items[index];
    if (!item) return;

    let result = await tuning_showConfirmation(`Czy na pewno chcesz zamontować ${item.name} za ${item.price}$?`);
    if (!result) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('tuning', 'installItem', [category, index]);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, data.status === 'success' ? 'Sukces' : 'Błąd', data.message);

        if (data.status === 'success') {
            // now change .installed to false and to true the one we installed
            let categoryData = categories.find(c => c.key === category);
            categoryData.items.forEach(i => i.installed = false);
            categoryData.items[index].installed = true;

            // update the items
            tuning_selectCategory(category);
        }
    }
}

tuning_uninstallItem = async (button, index) => {
    let category = document.querySelector('#tuning .option.active').dataset.key;
    let item = categories.find(c => c.key === category).items[index];
    if (!item) return;

    let result = await tuning_showConfirmation(`Czy na pewno chcesz odmontować ${item.name}?`);
    if (!result) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('tuning', 'uninstallItem', [category, index]);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, data.status === 'success' ? 'Sukces' : 'Błąd', data.message);

        if (data.status === 'success') {
            // now change .installed to false and to true the one we installed
            let categoryData = categories.find(c => c.key === category);
            categoryData.items[index].installed = false;

            // update the items
            tuning_selectCategory(category);
        }
    }
}

tuning_selectCategory = (key) => {
    let oldCategory = document.querySelector('#tuning .option.active')?.dataset.key;
    let category = categories.find(c => c.key === key);
    document.querySelectorAll('#tuning .option').forEach(option => {
        option.classList.toggle('active', option.dataset.key === key);
    });

    if (category) {
        tuning_setItems(category.key, category.name, category.items.map(item => {
            return {
                name: item.name,
                price: item.price,
                installed: item.installed,
                callback: item.installed ? 'tuning_uninstallItem' : 'tuning_installItem',
            }
        }));

        if (oldCategory && oldCategory !== key)
            mta.triggerEvent('tuning:removePreview', oldCategory);
    }
}

addEvent('tuning', 'interface:data:tuning', (data) => {
    categories = data[0];
    tuning_renderCategories();
});