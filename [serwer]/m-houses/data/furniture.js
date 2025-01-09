window.houses_hideFurniture = function(button) {
    document.querySelector('#edit-tenants').style.display = 'none';
}

window.houses_appearFurnitureMenu = async function(appear) {
    let houseData = houses_getHouseData();
    if (!houseData) return;

    document.querySelector('#furnitures').style.display = 'block';
    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#furnitures').style.opacity = appear ? '1' : '0';
    if (!appear) setTimer('houses', houses_hideFurniture, 200);
}

function getFurnitureData(item) {
    let houseData = houses_getHouseData();
    if (!houseData) return;

    return houseData.furnitureData.find(f => f.item == item);
}

window.houses_furnitureMenu = function() {
    houses_appearFurnitureMenu(true);

    let houseData = houses_getHouseData();
    if (!houseData) return;

    let furniture = houseData.furniture;
    let furnitureList = document.querySelector('#furnitures .list');

    furnitureList.innerHTML = furniture.map((f, i) => {
        let data = getFurnitureData(f.item);
        if (!data) return '';

        return `
            <div class="item">
                ${data.name}
            </div>
        `;
    }).join('');

    if (furniture.length == 0) {
        furnitureList.innerHTML = '<div class="item">Brak mebli</div>';
    }
}

window.houses_editFurnitures = async function(button) {
    if (isButtonSpinner(button)) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'editFurnitures');
    makeButtonSpinner(button, false);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Edycja mebli', data.message);
        
        if (data.status == 'success') {
            houses_appearFurnitureMenu(false);
        }
    }
}