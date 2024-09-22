tablet_vehicleLogsData = [];

tablet_searchVehicle = async (button) => {
    if (isButtonSpinner(button)) return;

    let search = document.querySelector('#tablet #search-vehicle-input').value;

    makeButtonSpinner(button);
    let data = await mta.fetch('sapd', 'searchVehicle', search);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
        
        if (data.status == 'success') {
            if (data.vehicles.length > 1) {
                tablet_showList('#tablet #vehicles-list', data.vehicles, [
                    { data: 'uid' },
                    { data: 'model' },
                    { data: 'plate' },
                    { data: 'uid', render: (data) => `<div class="d-flex justify-end">
                        <div class="flat-button flat-button-small" onclick="tablet_openVehicleInfo(${data})">Informacje</div>
                    </div>` }
                ]);

                tablet_goToTab('vehicles');
            } else {
                tablet_openVehicleInfo(data.vehicles[0].uid);
            }
        }
    }
    
    makeButtonSpinner(button, false);
}

tablet_openVehicleInfo = async (uid) => {
    tablet_goToTab('loading');
    
    await new Promise(r => setTimeout(r, 1000));
    let data = await mta.fetch('sapd', 'getVehicleInfo', uid);
    
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        if (data.status == 'success') {
            tablet_showVehicleInfo(data.vehicle);
            tablet_goToTab('vehicle-info');
            tablet_currentVehicle = data.vehicle;
        } else {
            notis_addNotification('error', 'Błąd', data.message);
        }
    }
}

tablet_showVehicleInfo = (data) => {
    document.querySelector('#tablet #vehicle-info-uid').innerText = data.uid;
    document.querySelector('#tablet #vehicle-info-model').innerText = `(${data.model}) ${data.modelName}`;
    document.querySelector('#tablet #vehicle-info-plate').innerText = data.plate;
    document.querySelector('#tablet #vehicle-info-owner').innerText = `(${data.owner}) ${data.ownerName}`;

    tablet_showList('#tablet #vehicle-info-logs', data.logs, [
        { data: 'added', render: (data, type, row) => {
            if (type == 'display') {
                return data;
            } else {
                return new Date(data).getTime();
            }
        } },
        { data: 'addedByUsername' },
        { data: 'info', render: (data) => `<div class="text-overflow">${data}</div>` },
        { data: 'uid', render: (data) => `<div class="d-flex justify-end">
            <div class="flat-button flat-button-small" onclick="tablet_showVehicleLogInfo(${data})">Szczegóły</div>
        </div>` }
    ]);

    tablet_vehicleLogsData = data.logs;
}

tablet_addVehicleLog = async (button) => {
    if (isButtonSpinner(button)) return;

    if (tablet_currentVehicle == null) {
        notis_addNotification('error', 'Błąd', 'Nie wybrano pojazdu');
        return;
    }

    let uid = tablet_currentVehicle.uid;
    let info = document.querySelector('#tablet #add-vehicle-log-info').value;

    makeButtonSpinner(button);
    let data = await mta.fetch('sapd', 'addVehicleLog', [uid, info]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);

        if (data.status == 'success') {
            tablet_openVehicleInfo(uid);
        }
    }
    
    makeButtonSpinner(button, false);
}

tablet_showVehicleLogInfo = (uid) => {
    let log = tablet_vehicleLogsData.find(l => l.uid == uid);

    document.querySelector('#tablet #log-info-added').innerText = log.added;
    document.querySelector('#tablet #log-info-added-by').innerText = log.addedByUsername;
    document.querySelector('#tablet #log-info-info').innerText = log.info;

    tablet_goToTab('log-info');
    document.querySelector('#tablet #loginfo-goback').onclick = () => tablet_goToTab('vehicle-info');
}