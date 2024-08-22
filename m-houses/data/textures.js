let editingTexture = null;

window.houses_renderTexturesList = (list, currentList, textureList) => {
    let listElement = document.querySelector('#houses #textures .list');
    
    listElement.innerHTML = list.map((texture, index) => {
        let currentTexture = currentList.find((currentTexture) => currentTexture.textureId == index);
        if (currentTexture) {
            currentTexture = textureList[currentTexture.texture];
        }
        
        return `
            <div class="item" data-index="${index}" onclick="houses_editTexture(${index})" data-type="${texture.type}">
                ${texture.name}
                ${currentTexture ? `
                    <div class="d-flex gap-2 align-items-center">
                        ${currentTexture.name}
                        <img class="texture-small" src="/m-houses/data/textures/interior/${currentTexture.texture}.png"/>
                    </div>
                ` : ''}
            </div>
        `;
    }).join('');

    let textureListElement = document.querySelector('#houses #textures .texture-list');
    houses_setTexturePickerVisible(false);

    textureListElement.innerHTML = textureList.map((texture, index) => {
        return `
            <div class="item texture" data-type="${texture.type}" data-index="${index}" onclick="houses_setTexture(this, ${index})">
                <img src="/m-houses/data/textures/interior/${texture.texture}.png"/>
                ${texture.name}
            </div>
        `;
    }).join('');

    // add none
    textureListElement.innerHTML += `
        <div class="item texture" data-type="none" data-index="-1" onclick="houses_setTexture(this, -1)">
            <img src="/m-houses/data/textures/close.png"/>
            Resetuj
        </div>
    `;
}

window.houses_setTexturePickerVisible = (visible, type) => {
    let texturePickerElement = document.querySelector('#houses #textures .texture-list');
    texturePickerElement.parentElement.classList.toggle('d-none', !visible);

    if (visible) {
        texturePickerElement.querySelectorAll('.item').forEach((element) => {
            element.classList.toggle('d-none', element.getAttribute('data-type') != type && element.getAttribute('data-type') != 'none');
        });
    }
}

window.houses_editTexture = (index) => {
    let houseData = houses_getHouseData();
    let texture = houseData.interiorData.textureNames[index];
    let type = texture.type;

    houses_setTexturePickerVisible(true, type);
    editingTexture = index;
}

window.houses_setTexture = (button, index) => {
    let houseData = houses_getHouseData();
    let texture = houseData.textures.find((texture) => texture.textureId == editingTexture);
    if (!texture) {
        texture = {
            textureId: editingTexture,
            texture: index
        };
        houseData.textures.push(texture);
    } else {
        texture.texture = index;
    }

    houses_updateTexture(button, editingTexture, index);
    houses_renderTexturesList(houseData.interiorData.textureNames, houseData.textures, houseData.possibleTextures);
}

window.houses_updateTexture = async (button, index, texture) => {
    if (isButtonSpinner(button)) return;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'setTexture', [houseData.uid, index, texture]);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Wystrój wnętrza', data.message);
    }
}

window.houses_resetTextures = async (button) => {
    if (isButtonSpinner(button)) return;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'resetTextures', [houseData.uid]);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Wystrój wnętrza', data.message);

        if (data.status == 'success') {
            houseData.textures = [];
            houses_renderTexturesList(houseData.interiorData.textureNames, houseData.textures, houseData.possibleTextures);
        }
    }
}

window.houses_hideTexturesInner = function(button) {
    document.querySelector('#houses #textures').style.display = 'none';
}

window.houses_appearTexturesMenu = async function(appear) {
    document.querySelector('#houses #textures').style.display = 'block';
    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#houses #textures').style.opacity = appear ? '1' : '0';
    if (!appear) setTimer('houses', houses_hideTexturesInner, 200);
}