window.houses_hideRentHouseInner = function(button) {
    document.querySelector('#rent-house-time').style.display = 'none';
}

window.houses_appearRentHouseTime = async function(appear) {
    document.querySelector('#rent-house-time').style.display = 'block';
    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#rent-house-time').style.opacity = appear ? '1' : '0';
    if (!appear) setTimer('houses', houses_hideRentHouseInner, 200);
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