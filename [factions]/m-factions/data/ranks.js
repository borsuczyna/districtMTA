let editingRank = null;

factionPanel_renderRanks = () => {
    let ranksList = document.querySelector('#faction-panel #ranks-list');

    new DataTable(ranksList, {
        ...defaultTableData,
        destroy: true,
        data: factionData.ranks,
        columns: [
            { data: 'name' },
            { data: 'uid', render: (data) => {
                let buttons = `<div class="d-flex justify-end gap-1">`;

                if (factionPanel_doesHaveAnyPermission(['editRank', 'manageFaction']))
                    buttons += `<div class="flat-button flat-button-small" onclick="factionPanel_openEditRank(this, ${data})">Edytuj</div>`;

                if (factionPanel_doesHaveAnyPermission(['removeRank', 'manageFaction']))
                    buttons += `<div class="flat-button flat-button-small" onclick="factionPanel_removeRank(this, ${data})">Usuń</div>`;

                buttons += `</div>`;
                return buttons;
            } }
        ],
        order: [[0, 'asc']],
        columnDefs: [
            { targets: [0], className: 'text-start' },
            { targets: [1], orderable: false, className: 'dt-right' }
        ],
        pageLength: 5
    });
}

factionPanel_openAddRank = () => {
    document.querySelector('#faction-panel #addRank').classList.add('active');
    document.querySelector('#faction-panel #addRankInput').value = '';
}

factionPanel_closeAddRank = () => {
    document.querySelector('#faction-panel #addRank').classList.remove('active');
}

factionPanel_addRank = async (button) => {
    if (isButtonSpinner(button)) return;

    let rankName = document.querySelector('#faction-panel #addRankInput').value;

    if (rankName.length < 1) {
        notis_addNotification('error', 'Błąd', 'Nazwa rangi jest za krótka');
        return;
    }

    makeButtonSpinner(button);
    let data = await mta.fetch('factions', 'addRank', [factionData.faction, rankName]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            factionData.ranks = data.ranks;
            factionPanel_renderRanks();
            factionPanel_closeAddRank();
        }
    }
    
    makeButtonSpinner(button, false);
}

factionPanel_removeRank = async (button, rank) => {
    if (isButtonSpinner(button)) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('factions', 'removeRank', [factionData.faction, rank]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            factionData.ranks = data.ranks;
            factionPanel_renderRanks();
        }
    }
    
    makeButtonSpinner(button, false);
}

factionPanel_renderPermissions = (currentPermissions) => {
    let permissions = factionData.allPermissions;
    let permissionsHTML = '';

    // <div data-setting="${setting.name}">
    //     <div class="switch-box" id="${setting.name}" onclick="dashboard_switchSetting(this)" tabindex="0" onkeydown="if (event.key === 'Enter' || event.key === ' ') dashboard_switchSetting(this)">
    //         <div class="switch">
    //             <div class="inner"></div>
    //         </div>
    //         <div class="label">
    //             ${setting.text}
    //         </div>
    //     </div>
    //     ${setting.input ? `<input type="${setting.input.type}" class="input mt-2 mb-2 d-none" id="reason" placeholder="${setting.input.placeholder}" maxlength="${setting.input.maxlength}" onchange="dashboard_sendSetting('${setting.name}')"/>` : ''}
    // </div>
    for (let permission of permissions) {
        permissionsHTML += `<div class="switch-box" data-permission="${permission.name}" onclick="factionPanel_switchPermission(this)" tabindex="0">
            <div class="switch">
                <div class="inner"></div>
            </div>
            <div class="label">
                ${permission.label}
            </div>
        </div>`;
    }

    document.querySelector('#permissions').innerHTML = permissionsHTML;

    // Set current permissions
    for (let permission of currentPermissions.split(',')) {
        factionPanel_setPermission(permission, true);
    }
}

factionPanel_switchPermission = (element) => {
    let permission = element.dataset.permission;
    let isActive = element.classList.contains('switched');
    element.classList.toggle('switched', !isActive);
}

factionPanel_setPermission = (permission, active) => {
    let element = document.querySelector(`#permissions .switch-box[data-permission="${permission}"]`);
    if (element == null) return;

    element.classList.toggle('switched', active);
}

factionPanel_openEditRank = (button, rank) => {
    let rankData = factionData.ranks.find(r => r.uid == rank);
    if (rankData == null) return;

    document.querySelector('#faction-panel #editRank').classList.add('active');
    document.querySelector('#faction-panel #editRankInput').value = rankData.name;
    factionPanel_renderPermissions(rankData.permissions);

    editingRank = rank;
}

factionPanel_closeEditRank = () => {
    document.querySelector('#faction-panel #editRank').classList.remove('active');
}

factionPanel_editRank = async (button) => {
    if (isButtonSpinner(button)) return;

    let rankName = document.querySelector('#faction-panel #editRankInput').value;
    let permissions = [];
    for (let permission of document.querySelectorAll('#permissions .switch-box')) {
        if (permission.classList.contains('switched'))
            permissions.push(permission.dataset.permission);
    }

    makeButtonSpinner(button);
    let data = await mta.fetch('factions', 'editRank', [factionData.faction, editingRank, rankName, permissions.join(',')]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            factionData.ranks = data.ranks;
            factionData.permissions = data.permissions;
            factionPanel_renderRanks();
            factionPanel_closeEditRank();

            for (let member of factionData.members) {
                if (member.rank == editingRank) {
                    member.rankName = rankName;
                }
            }

            factionPanel_renderMembers();
        }
    }
    
    makeButtonSpinner(button, false);
}