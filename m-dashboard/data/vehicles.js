let dataCache = {};

window.dashboard_renderVehicles = (data) => {
    dataCache.vehicles = data;

    document.querySelector('#dashboard #tabs [tab="vehicles"]').innerHTML = `
        <div class="nice-table-wrapper">
            <table id="vehicles-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Pojazd</th>
                        <th>Właścicel</th>
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
            { data: 'model', render: (data) => window.vehicleNames[parseInt(data) - 400] },
            { data: 'ownerName' },
            { data: 'uid', render: (data) => {
                return `<div class="d-flex gap-1">
                    <div class="nice-button button-sm" onclick="mta.triggerEvent('dashboard:vehicleDetails', ${data})">Szczegóły</div>
                </div>`;
            } },
        ],
        order: [[0, 'desc']],
        columnDefs: [
            { targets: [3], orderable: false, className: 'dt-right d-flex justify-end' }
        ]
    });
}

window.dashboard_vehicleDetails = function(id, data) {
    let vehicle = dataCache.vehicles.find(v => v.uid == id);
    let vehicleName = window.vehicleNames[parseInt(vehicle.model) - 400];

    let details = document.querySelector('#dashboard #tabs #vehicle-details');
    let position = data?.position || vehicle.position.split(',').map(v => parseFloat(v));

    details.innerHTML = `
        <div class="d-flex flex-column vehicle-details gap-1 mt-3">
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
                <div>${(data?.fuel || vehicle.fuel).toFixed(2)}%</div>
            </div>
            <div class="d-flex gap-1">
                <div class="label">Przebieg:</div>
                <div>${(data?.mileage || vehicle.mileage).toFixed(2)} km</div>
            </div>

            <div id="vehicle-map"></div>
            <div class="d-flex gap-1 mt-2">
                <div class="d-flex gap-1 align-items-center">
                    <img src="../../m-maps/data/marker.png" class="player-blip icon" />
                    <div class="label">Twoja pozycja</div>
                </div>
                <div class="d-flex gap-1 align-items-center">
                    <img src="../../m-maps/data/marker.png" class="vehicle-blip icon" />
                    <div class="label">Pozycja pojazdu</div>
                </div>
            </div>
        </div>
    `;

    createMap({
        element: document.querySelector('#dashboard #vehicle-details #vehicle-map'),
        minZoom: 0.8,
        zoom: 1.5,
        maxZoom: 6,
        x: position[0],
        y: position[1],
        limitBounds: true,
        bounds: { x: 1400, y: 1400 },
        texture: 'map-transparent.png?v1.01'
    });

    createMapBlip({
        element: document.querySelector('#dashboard #vehicle-details #vehicle-map'),
        icon: '../../m-maps/data/marker.png',
        size: 15,
        x: window.dashboard_playerPosition[0],
        y: window.dashboard_playerPosition[1],
        class: 'player-blip'
    });

    createMapBlip({
        element: document.querySelector('#dashboard #vehicle-details #vehicle-map'),
        icon: '../../m-maps/data/marker.png',
        size: 15,
        x: position[0],
        y: position[1],
        class: 'vehicle-blip'
    });

    details.classList.remove('d-none');
}

window.dashboard_hideVehicleDetails = function() {
    document.querySelector('#dashboard #tabs #vehicle-details')?.classList.add('d-none');
}

addEvent('dashboard', 'vehicle-details-result', (data) => {
    let { id, result } = data[0];

    dashboard_vehicleDetails(id, result);
});