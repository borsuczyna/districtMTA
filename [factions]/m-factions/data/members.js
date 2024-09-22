let editMemberId = null;

function timeToString(time) {
    let timeData = [];
    time *= 60;

    let addTime = (time, name) => {
        if (time <= 0) return;
        timeData.push(`${time} ${name}`);
    }

    addTime(Math.floor(time / 86400), 'dni');
    time %= 86400;
    addTime(Math.floor(time / 3600), 'godzin');
    time %= 3600;
    addTime(Math.floor(time % 3600 / 60), 'minut');
    time %= 60;
    addTime(time % 60, 'sekund');

    return timeData.join(', ');
}

factionPanel_renderMembers = () => {
    let membersList = document.querySelector('#faction-panel #members-list');

    new DataTable(membersList, {
        ...defaultTableData,
        destroy: true,
        data: factionData.members,
        columns: [
            { data: 'playerName' },
            { data: 'rankName' },
            { data: 'dutyTime', render: (data, type, row) => {
                if (type == 'display') {
                    return timeToString(data ?? 0);
                }

                return data;
            } },
            { data: 'user', render: (data) => {
                let buttons = `<div class="d-flex justify-end gap-1">`;

                if (factionPanel_doesHaveAnyPermission(['editMember', 'manageFaction']))
                    buttons += `<div class="flat-button flat-button-small" onclick="factionPanel_openEditMember(this, ${data})">Edytuj</div>`;

                if (factionPanel_doesHaveAnyPermission(['removeMember', 'manageFaction']))
                    buttons += `<div class="flat-button flat-button-small" onclick="factionPanel_removeMember(this, ${data})">Usuń</div>`;

                buttons += `</div>`;
                return buttons;
            } }
        ],
        order: [[1, 'asc']],
        columnDefs: [
            { targets: [0, 1], className: 'text-start' },
            { targets: [3], orderable: false, className: 'dt-right' }
        ],
        pageLength: 5
    });
}

factionPanel_removeMember = async (button, userId) => {
    if (isButtonSpinner(button)) return;

    // cannot remove yourself
    if (factionData.uid == userId) {
        notis_addNotification('error', 'Błąd', 'Nie możesz usunąć siebie z frakcji');
        return;
    }
    
    makeButtonSpinner(button);
    let data = await mta.fetch('factions', 'removeMember', [factionData.faction, userId]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            factionData.members = data.members;
            factionPanel_renderMembers();
        }
    }
    
    makeButtonSpinner(button, false);    
}

factionPanel_openAddMember = () => {
    document.querySelector('#faction-panel #addMember').classList.add('active');
    document.querySelector('#faction-panel #addMemberInput').value = '';

    let select = document.querySelector('#faction-panel #addMemberRank');
    while (select.options.length > 0) {
        select.remove(0);
    }

    factionData.ranks.forEach(rank => {
        let option = new Option(rank.name, rank.uid);
        select.add(option);
    });
}

factionPanel_closeAddMember = () => {
    document.querySelector('#faction-panel #addMember').classList.remove('active');
}

factionPanel_addMember = async (button) => {
    if (isButtonSpinner(button)) return;

    let playerName = document.querySelector('#faction-panel #addMemberInput').value;
    let rank = document.querySelector('#faction-panel #addMemberRank').value;

    if (playerName.length < 1) {
        notis_addNotification('error', 'Błąd', 'Nazwa gracza jest za krótka');
        return;
    }

    makeButtonSpinner(button);
    let data = await mta.fetch('factions', 'addMember', [factionData.faction, playerName, rank]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            factionData.members = data.members;
            factionPanel_renderMembers();
            factionPanel_closeAddMember();
        }
    }
    
    makeButtonSpinner(button, false);
}

factionPanel_openEditMember = (button, userId) => {
    let member = factionData.members.find(m => m.user == userId);
    if (member == null) return;

    editMemberId = userId;
    document.querySelector('#faction-panel #editMember').classList.add('active');

    let select = document.querySelector('#faction-panel #editMemberRank');
    while (select.options.length > 0) {
        select.remove(0);
    }

    factionData.ranks.forEach(rank => {
        let option = new Option(rank.name, rank.uid);
        select.add(option);
    });

    select.value = member.rank;
}

factionPanel_closeEditMember = () => {
    document.querySelector('#faction-panel #editMember').classList.remove('active');
}

factionPanel_editMember = async (button) => {
    if (isButtonSpinner(button)) return;

    let rank = document.querySelector('#faction-panel #editMemberRank').value;

    makeButtonSpinner(button);
    let data = await mta.fetch('factions', 'editMember', [factionData.faction, editMemberId, rank]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            factionData.members = data.members;
            factionPanel_renderMembers();
            factionPanel_closeEditMember();
        }
    }
    
    makeButtonSpinner(button, false);
}