let waiting = false;

window.houses_toggleDoorLock = async function(button) {
    if (isButtonSpinner(button) || waiting) return;
    waiting = true;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'toggleDoorLock', houseData.uid);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Drzwi', data.message);

        if (data.status === 'success') {
            houseData.locked = !houseData.locked;
            houses_renderHouseOptions();
        }
    }
}

window.houses_enterHouse = async function(button) {
    if (isButtonSpinner(button) || waiting) return;
    waiting = true;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'enterHouse', houseData.uid);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else if(data.status != 'success') {
        notis_addNotification(data.status, 'Wejście', data.message);
    } else {
        mta.triggerEvent('houses:hideInterface');
    }
}

window.houses_cancelRentAsk = function() {
    houses_appearRentHouseTime(true);
    let input = document.querySelector('#houses #rent-house-time-input');
    let button = document.querySelector('#houses #rent-house-time-button');

    document.querySelector('#houses #rent-house-time .description').innerText = 'Czy na pewno chcesz anulować wynajem domu?\nJeśli tak, wpisz "potwierdzam" w polu poniżej.';
    input.type = 'text';
    input.placeholder = 'potwierdzam';
    input.value = '';
    button.innerText = 'Anuluj wynajem';
    button.setAttribute('onclick', 'houses_cancelRentHouse(this)');
}

window.houses_ringBell = async function(button) {
    if (isButtonSpinner(button) || waiting) return;
    waiting = true;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'ringBell', houseData.uid);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Dzwonek', data.message);
    }
}

window.houses_kickGuests = async function(button) {
    if (isButtonSpinner(button) || waiting) return;
    waiting = true;

    let houseData = houses_getHouseData();
    if (!houseData) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('houses', 'kickGuests', houseData.uid);
    makeButtonSpinner(button, false);
    waiting = false;

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else {
        notis_addNotification(data.status, 'Wyrzucanie', data.message);
    }
}