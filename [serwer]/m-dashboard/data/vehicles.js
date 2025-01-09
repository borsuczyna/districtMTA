let dataCache = {};
let lastRequest = 0;

window.dashboard_renderVehicles = (data) => {
    dataCache.vehicles = data;

    document.querySelector('#dashboard #tabs [tab="vehicles"]').innerHTML = `
        <div class="nice-table-wrapper striped">
            <table id="vehicles-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Pojazd</th>
                        <th>Właścicel</th>
                        <th>Parking</th>
                        <th>Opcje</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>

        <div class="d-none" id="vehicle-details"></div>
    `;

    new DataTable(document.querySelector('#dashboard #tabs #vehicles-table'), {
        ...defaultTableData,
        data: data,
        columns: [
            { data: 'uid' },
            // { data: 'model', render: (data) => window.vehicleNames[parseInt(data) - 400] },
            { data: 'modelName' },
            { data: 'ownerName' },
            { data: 'parking', render: (data) => data ? 'Tak' : 'Nie' },
            { data: 'uid', render: (data) => {
                return `<div class="d-flex gap-1">
                    <div class="flat-button flat-button-small" onclick="dashboard_getVehicleDetails(${data})">Szczegóły</div>
                </div>`;
            } },
        ],
        order: [[0, 'desc']],
        columnDefs: [
            { targets: [4], orderable: false, className: 'dt-right d-flex justify-end' }
        ]
    });
}

window.dashboard_getVehicleDetails = (id) => {
    if (Date.now() - lastRequest < 1000) {
        notis_addNotification('error', 'Błąd', 'Poczekaj chwilę przed kolejnym zapytaniem.');
        return;
    }

    lastRequest = Date.now();
    mta.triggerEvent('dashboard:vehicleDetails', id);
}

window.dashboard_vehicleDetails = function(id, data) {
    let vehicle = dataCache.vehicles.find(v => v.uid == id);
    // let vehicleName = window.vehicleNames[parseInt(vehicle.model) - 400];
    let vehicleName = vehicle.modelName;

    let details = document.querySelector('#dashboard #tabs #vehicle-details');
    let position = data?.position || vehicle.position.split(',').map(v => parseFloat(v));
    let fuel = parseFloat(data?.fuel || vehicle.fuel);
    let maxFuel = parseFloat(data?.maxFuel || vehicle.maxFuel);
    let mileage = parseFloat(data?.mileage || vehicle.mileage);

    details.innerHTML = `
        <div class="info-card mt-3" style="animation: fadeIn 0.3s ease-in-out;">
            <div class="info-header">Szczegóły pojazdu</div>
            <div class="info-body d-flex flex-column gap-1">
                <div class="d-flex gap-1">
                    <div class="label">Model:</div>
                    <div>${vehicleName}</div>
                </div>
                <div class="d-flex gap-1">
                    <div class="label">Właściciel:</div>
                    <div>${htmlEscape(vehicle.ownerName)}</div>
                </div>
                <div class="d-flex gap-1">
                    <div class="label">Ostatni kierowca:</div>
                    <div>${htmlEscape(data?.lastDriver || vehicle.lastDriverName || 'Brak')}</div>
                </div>
                <div class="d-flex gap-1">
                    <div class="label">Paliwo:</div>
                    <div>${fuel.toFixed(2)}/${maxFuel.toFixed(2)} l</div>
                </div>
                <div class="d-flex gap-1">
                    <div class="label">Przebieg:</div>
                    <div>${mileage.toFixed(2)} km</div>
                </div>
                <div class="d-flex gap-1">
                    <div class="label">W przechowalni:</div>
                    <div>${vehicle.parking ? 'Tak' : 'Nie'}</div>
                </div>
        
                ${!vehicle.parking ? `
                    <div id="vehicle-map" class="mt-2"></div>

                    <div class="d-flex gap-1 mt-2">
                        <div class="d-flex gap-1 align-items-center">
                            <img src="/m-maps/data/marker.png" class="player-blip icon" />
                            <div class="label">Twoja pozycja</div>
                        </div>
                        <div class="d-flex gap-1 align-items-center">
                            <img src="/m-maps/data/marker.png" class="vehicle-blip icon" />
                            <div class="label">Pozycja pojazdu</div>
                        </div>
                    </div>
                ` : ''}
            </div>
        </div>
    `;

    if (!vehicle.parking) {
        createMap({
            element: document.querySelector('#dashboard #vehicle-details #vehicle-map'),
            minZoom: 0.8,
            zoom: 1.5,
            maxZoom: 6,
            x: position[0],
            y: position[1],
            limitBounds: true,
            bounds: { x: 1400, y: 1400 },
            background: 'rgba(255, 255, 255, 0.04)',
            texture: 'map-dark.png?v1.01'
        });

        createMapBlip({
            element: document.querySelector('#dashboard #vehicle-details #vehicle-map'),
            icon: '/m-maps/data/marker.png',
            size: 15,
            x: window.dashboard_playerPosition[0],
            y: window.dashboard_playerPosition[1],
            class: 'player-blip'
        });

        createMapBlip({
            element: document.querySelector('#dashboard #vehicle-details #vehicle-map'),
            icon: '/m-maps/data/marker.png',
            size: 15,
            x: position[0],
            y: position[1],
            class: 'vehicle-blip'
        });
    }

    details.classList.remove('d-none');
}

window.dashboard_hideVehicleDetails = function() {
    document.querySelector('#dashboard #tabs #vehicle-details')?.classList.add('d-none');
}

addEvent('dashboard', 'vehicle-details-result', (data) => {
    let { id, result } = data[0];

    dashboard_vehicleDetails(id, result);
});