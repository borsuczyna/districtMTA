tuning_setItems = (key, title, items) => {
    let itemsEl = document.querySelector('#tuning #items');
    let itemsList = itemsEl.querySelector('#tuning .items-list');
    let itemsTitle = itemsEl.querySelector('#tuning .title');
    itemsTitle.innerHTML = title;
    itemsTitle.dataset.key = key;

    itemsList.innerHTML = items.map((option, index) => `<div class="item" onclick="tuning_selectItem(this)">
        <div class="name">${option.name}</div>
        <div class="d-flex align-items-center gap-2">
            ${option.installed ? `<div class="checkmark">${tuning_icons.checkmark}</div>` : ''}
            <div class="price">$${option.price}</div>
            <div class="buy" onclick="${option.callback}(this, ${index})">${tuning_icons[option.installed ? 'close' : 'cart']}</div>
        </div>
    </div>`).join('');
}

tuning_selectItem = (el) => {
    let items = document.querySelectorAll('#items .item');
    items.forEach(item => item.classList.remove('active'));
    el.classList.add('active');

    let key = document.querySelector('#tuning .title').dataset.key;
    let index = Array.from(el.parentNode.children).indexOf(el);
    mta.triggerEvent('tuning:preview', key, index);
}