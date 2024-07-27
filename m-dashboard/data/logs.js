let dataCache = {};
let USER_LOG = {
    1: 'Konto',
    2: 'Pojazdy',
    3: 'Admin',
};

window.dashboard_renderLogs = (data) => {
    dataCache.logs = data;

    document.querySelector('#dashboard #tabs [tab="logs"]').innerHTML = `
        <div class="nice-table-wrapper striped">
            <table id="logs-table">
                <thead>
                    <tr>
                        <th>Typ</th>
                        <th>Informacja</th>
                        <th>Data</th>
                        <th>Opcje</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>

        <div class="d-none" id="logs-details"></div>
    `;

    new DataTable(document.querySelector('#dashboard #tabs #logs-table'), {
        ...defaultTableData,
        data: data,
        columns: [
            { data: 'type', render: (data) => data == 1 ? 'Zalogowano' : 'Wylogowano' },
            { data: 'log' },
            { data: 'date', render: (data, type) => {
                if (type == 'display') {
                    return new Date(data).toLocaleString('pl-PL', { month: 'long', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit' });
                }

                return data;
            } },
            { data: 'uid', render: (data) => {
                return `<div class="d-flex gap-1">
                    <div class="flat-button flat-button-small" onclick="dashboard_getLogDetails(${data})">Szczegóły</div>
                </div>`;
            } },
        ],
        order: [[2, 'desc']],
        columnDefs: [
            { targets: [3], orderable: false, className: 'dt-right d-flex justify-end' }
        ]
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
                    <div>${USER_LOG[log.type]}</div>
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