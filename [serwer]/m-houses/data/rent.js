let waiting = false;

window.houses_hideRentHouseInner = function(button) {
    document.querySelector('#houses #rent-house-time').style.display = 'none';
}

window.houses_appearRentHouseTime = async function(appear) {
    document.querySelector('#houses #rent-house-time').style.display = 'block';
    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#houses #rent-house-time').style.opacity = appear ? '1' : '0';
    if (!appear) setTimer('houses', houses_hideRentHouseInner, 200);
}

window.houses_hideTenantInner = function(button) {
    document.querySelector('#houses #edit-tenants').style.display = 'none';
}

window.houses_appearEditTenants = async function(appear) {
    let houseData = houses_getHouseData();
    if (!houseData) return;

    document.querySelector('#houses #edit-tenants').style.display = 'block';
    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#houses #edit-tenants').style.opacity = appear ? '1' : '0';
    document.querySelector('#houses #edit-tenants .description').innerText = `Dodaj lub usuń lokatorów (max ${houseData.interiorData.maxTenants})`;
    if (!appear) setTimer('houses', houses_hideTenantInner, 200);
}

window.houses_openRentHouse = async function() {
    houses_appearRentHouseTime(true);
    let input = document.querySelector('#houses #rent-house-time-input');
    let button = document.querySelector('#houses #rent-house-time-button');

    document.querySelector('#houses #rent-house-time .description').innerText = 'Na ile dni chcesz wynająć ten dom?';
    input.type = 'number';
    input.placeholder = 'Ilość dni';
    input.value = '1';
    button.innerText = 'Wynajmij';
    button.setAttribute('onclick', 'houses_confirmRentHouse(this)');
}

window.houses_editTenants = async function(button) {
    houses_appearEditTenants(true);

    let houseData = houses_getHouseData();
    if (!houseData) return;

    let tenants = houseData.sharedPlayerNames;
    let tenantsElement = document.querySelector('#edit-tenants .list');

    tenantsElement.innerHTML = tenants.map(tenant => `
        <div class="item">
            ${tenant.name}
            <svg data-tooltip="Usuń lokatora" onclick="houses_removeTenant(this, ${tenant.uid})" viewBox="0 0 320.591 320.591"><g><g id="close_1_"><path d="m30.391 318.583c-7.86.457-15.59-2.156-21.56-7.288-11.774-11.844-11.774-30.973 0-42.817l257.812-257.813c12.246-11.459 31.462-10.822 42.921 1.424 10.362 11.074 10.966 28.095 1.414 39.875l-259.331 259.331c-5.893 5.058-13.499 7.666-21.256 7.288z"/><path d="m287.9 318.583c-7.966-.034-15.601-3.196-21.257-8.806l-257.813-257.814c-10.908-12.738-9.425-31.908 3.313-42.817 11.369-9.736 28.136-9.736 39.504 0l259.331 257.813c12.243 11.462 12.876 30.679 1.414 42.922-.456.487-.927.958-1.414 1.414-6.35 5.522-14.707 8.161-23.078 7.288z"/></g></g></svg>
        </div>
    `).join('');

    if (tenants.length === 0) {
        tenantsElement.innerHTML = '<div class="item">Brak lokatorów</div>';
    }
}

window.houses_confirmRentHouse = async function(button) {
    if (isButtonSpinner(button)) return;

    let days = document.querySelector('#houses #rent-house-time-input').value;
    if (days < 1) {
        notis_addNotification('error', 'Wynajem domu', 'Nieprawidłowa ilość dni.');
        return;
    }

    if (days > 65) {
        notis_addNotification('error', 'Wynajem domu', 'Maksymalna ilość dni wynajmu to 60.');
        return;
    }

    let houseData = houses_getHouseData();
    if (!houseData) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'rentHouse', [houseData.uid, days]);
    makeButtonSpinner(button, false);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Wynajem domu', data.message);

        if (data.status === 'success') {
            mta.triggerEvent('houses:refetchHouseData');
            houses_appearRentHouseTime(false);
        }
    }
}

window.houses_extendRent = async function() {
    houses_appearRentHouseTime(true);
    let input = document.querySelector('#houses #rent-house-time-input');
    let button = document.querySelector('#houses #rent-house-time-button');

    document.querySelector('#houses #rent-house-time .description').innerText = 'O ile dni chcesz przedłużyć wynajem?';
    input.type = 'number';
    input.placeholder = 'Ilość dni';
    input.value = '1';
    button.innerText = 'Przedłuż';
    button.setAttribute('onclick', 'houses_confirmRentHouse(this)');
}

window.houses_removeTenant = async function(button, uid) {
    if (isButtonSpinner(button)) return;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'removeTenant', [houseData.uid, uid]);
    makeButtonSpinner(button, false);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Usuwanie lokatora', data.message);

        if (data.status === 'success') {
            houseData.sharedPlayerNames = houseData.sharedPlayerNames.filter(tenant => tenant.uid !== uid);
            houses_editTenants();
        }
    }
}

window.houses_addTenant = async function(button) {
    if (isButtonSpinner(button)) return;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    let playerName = document.querySelector('#edit-tenants #new-tenant-name').value;
    if (!playerName || playerName.length < 1) {
        notis_addNotification('error', 'Dodawanie lokatora', 'Podaj nazwę gracza.');
        return;
    }

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'addTenant', [houseData.uid, playerName]);
    makeButtonSpinner(button, false);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Dodawanie lokatora', data.message);

        if (data.status === 'success') {
            houseData.sharedPlayerNames.push({ name: data.name, uid: data.uid });
            houses_editTenants();
        }
    }
}

window.houses_cancelRentHouse = async function(button) {
    if (isButtonSpinner(button) || waiting) return;
    waiting = true;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    let input = document.querySelector('#houses #rent-house-time-input');
    if (input.value !== 'potwierdzam') {
        notis_addNotification('error', 'Błąd', 'Nie przepisano poprawnej frazy potwierdzającej');
        waiting = false;
        return;
    }

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'cancelRentHouse', houseData.uid);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Anulowanie wynajmu', data.message);

        if (data.status === 'success') {
            mta.triggerEvent('houses:refetchHouseData');
            houses_appearRentHouseTime(false);
        }
    }
}