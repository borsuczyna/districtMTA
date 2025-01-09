window.dashboard_renderPunishments = (data) => {
    let punishmentsTypes = {
        'ban': 'Ban',
        'kick': 'Kick',
        'warn': 'Warn',
        'mute': 'Mute',
        'license': 'Prawo jazdy',
    };

    document.querySelector('#dashboard #tabs [tab="punishments"]').innerHTML = `
        <div class="nice-table-wrapper striped">
            <table id="punishments-table">
                <thead>
                    <tr>
                        <th>Administrator</th>
                        <th>Typ</th>
                        <th>Data nadania</th>
                        <th>Data zakończenia</th>
                        <th>Powód</th>
                        <th>Aktywna</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    `;

    new DataTable(document.querySelector('#dashboard #tabs #punishments-table'), {
        ...defaultTableData,
        data: data,
        columns: [
            { data: 'admin' },
            { data: 'type', render: (data) => punishmentsTypes[data] },
            { data: 'start', render: (data, type) => {
                if (type == 'sort') return data;
                return new Date(data).toLocaleString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' });
            } },
            { data: 'end', render: (data, type, row) => {
                if (type == 'sort') return row.permanent ? '9999-12-31 23:59:59' : data;
                return row.permanent == 1 ? 'Nigdy' : new Date(data).toLocaleString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' });
            } },
            { data: 'reason' },
            { data: 'active', render: (data, type, row) => {
                if (data == 0) return 'Nie';
                if (row.permanent == 1) return 'Tak';
                return new Date(row.end) > new Date() ? 'Tak' : 'Nie';
            } },
        ],
        order: [[2, 'desc']]
    });
}