let dataCache = {};
let USER_LOG = {
    1: 'Konto',
    2: 'Pojazdy',
    3: 'Admin',
};

let MONEY_LOG = {
    job: 'Praca',
    shop: 'Sklep',
    'daily reward': 'Nagroda dzienna',
    'daily task': 'Zadanie dziennie',
    'vehicle-buy': 'Zakup pojazdu',
    transfer: 'Przelew',
    license: 'Prawo jazdy',
    house: 'Mieszkanie',
    repair: 'Naprawa pojazdu',
    atm: 'Bankomat',
    paint: 'Malowanie pojazdu',
    achievement: 'Osiągnięcie',
    stations: 'Stacja benzynowa',
    tuning: 'Warsztat tuningowy',
    ticket: 'Mandaty',
    factions: 'Frakcje',
    'vehicle-sell': 'Sprzedaż pojazdu',
}

window.dashboard_renderLogs = (element, data, moneyHistory = false) => {
    dataCache.logs = data;

    element.innerHTML = `
        <div class="nice-table-wrapper striped">
            <table class="logs-table">
                <thead>
                    <tr>
                        <th>Typ</th>
                        <th>Informacja</th>
                        ${moneyHistory ? `<th>Kwota</th>
                        <th>Data</th>` : `<th>Data</th>
                        <th>Opcje</th>`}
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>

        <div class="d-none" id="logs-details"></div>
    `;

    let columns = [
        { data: 'type', render: (data) => USER_LOG[data] ?? MONEY_LOG[data] ?? 'Nieznany' },
        { data: moneyHistory ? 'details' : 'log' },
    ];

    // when moneyHistory swap 3 with 4
    if (moneyHistory) {
        columns.push({ data: moneyHistory ? 'money' : 'uid', render: (data) => {
            if (parseInt(data) > 0) {
                return `<span class="text-success">+$${addCents(data)}</span>`;
            } else {
                return `<span class="text-danger">-$${addCents(Math.abs(data))}</span>`;
            }
        } });
    }

    columns.push({ data: 'date', render: (data, type) => {
        if (type == 'display') {
            return new Date(data).toLocaleString('pl-PL', { month: 'long', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' });
        }

        return data;
    } });

    if (!moneyHistory) {
        columns.push({ data: 'uid', render: (data) => {
            return `<div class="d-flex gap-1">
                <div class="flat-button flat-button-small" onclick="dashboard_getLogDetails(${data})">Szczegóły</div>
            </div>`;
        } });
    }
    
    new DataTable(element.querySelector('.logs-table'), {
        ...defaultTableData,
        data: data,
        columns: columns,
        order: [[moneyHistory ? 3 : 2, 'desc']],
        columnDefs: [
            { targets: [3], orderable: !!moneyHistory, className: 'dt-right d-flex justify-end' }
        ],
        // max 10 per page
        pageLength: moneyHistory ? 18 : 10,
    });
}

window.dashboard_getLogDetails = (id) => {
    let log = dataCache.logs.find(l => l.uid == id);
    let details = log.details.replace(/(?:\r\n|\r|\n)/g, '<br>');
    details = details.replace(/\|\|(.+?)\|\|/g, '<span class="hidden-info">$1</span>');

    document.querySelector('#dashboard #tabs #logs-details').innerHTML = `
        <div class="info-card mt-3" style="animation: fadeIn 0.3s ease-in-out;">
            <div class="info-header">Szczegóły logu</div>
            <div class="info-body d-flex flex-column gap-1">
                <div class="d-flex gap-1">
                    <div class="label">Typ:</div>
                    <div>${USER_LOG[log.type] ?? MONEY_LOG[log.type] ?? 'Nieznany'}</div>
                </div>
                <div class="d-flex gap-1 flex-column">
                    <div class="label">Szczegóły:</div>
                    <div>${details}</div>
                </div>
                <div class="d-flex gap-1">
                    <div class="label">Data:</div>
                    <div>${new Date(log.date).toLocaleString('pl-PL', { month: 'long', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</div>
                </div>
            </div>
        </div>
    `;
      
    document.querySelector('#dashboard #tabs #logs-details').classList.remove('d-none');
}