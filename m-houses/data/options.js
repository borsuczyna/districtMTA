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