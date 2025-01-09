tablet_logsData = [];
tablet_currentUser = null;
tablet_currentVehicle = null;

tablet_searchUser = async (button) => {
    if (isButtonSpinner(button)) return;

    let search = document.querySelector('#tablet #search-user-input').value;

    makeButtonSpinner(button);
    let data = await mta.fetch('sapd', 'searchUser', search);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
        
        if (data.status == 'success') {
            if (data.users.length > 1) {
                tablet_showList('#tablet #users-list', data.users, [
                    { data: 'uid' },
                    { data: 'username' },
                    { data: 'lastActive' },
                    { data: 'uid', render: (data) => `<div class="d-flex justify-end">
                        <div class="flat-button flat-button-small" onclick="tablet_openUserInfo(${data})">Informacje</div>
                    </div>` }
                ]);

                tablet_goToTab('users');
            } else {
                tablet_openUserInfo(data.users[0].uid);
            }
        }
    }
    
    makeButtonSpinner(button, false);
}

tablet_openUserInfo = async (uid) => {
    tablet_goToTab('loading');
    
    await new Promise(r => setTimeout(r, 1000));
    let data = await mta.fetch('sapd', 'getUserInfo', uid);
    
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        if (data.status == 'success') {
            tablet_showUserInfo(data.user);
            tablet_goToTab('user-info');
            tablet_currentUser = data.user;
        } else {
            notis_addNotification('error', 'Błąd', data.message);
        }
    }
}

tablet_showUserInfo = (data) => {
    document.querySelector('#tablet #user-info-nick').innerText = data.username;
    document.querySelector('#tablet #user-info-uid').innerText = data.uid;
    document.querySelector('#tablet #user-info-last-online').innerText = data.online ? 'Teraz' : data.lastActive;
    document.querySelector('#tablet #user-info-licenses').innerText = data.licenses.split(',').join(', ');

    tablet_showList('#tablet #user-info-logs', data.logs, [
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
            <div class="flat-button flat-button-small" onclick="tablet_showLogInfo(${data})">Szczegóły</div>
        </div>` }
    ]);

    tablet_logsData = data.logs;
}

tablet_showLogInfo = (index) => {
    let data = tablet_logsData.find(x => x.uid == index);
    document.querySelector('#tablet #log-info-added').innerText = data.added;
    document.querySelector('#tablet #log-info-added-by').innerText = data.addedByUsername;
    document.querySelector('#tablet #log-info-info').innerText = data.info;

    tablet_goToTab('log-info');
    document.querySelector('#tablet #loginfo-goback').onclick = () => tablet_goToTab('user-info');
}

tablet_addUserLog = async (button) => {
    if (isButtonSpinner(button)) return;

    if (tablet_currentUser == null) {
        notis_addNotification('error', 'Błąd', 'Nie wybrano użytkownika');
        return;
    }

    let uid = tablet_currentUser.uid;
    let info = document.querySelector('#tablet #add-user-log-info').value;

    makeButtonSpinner(button);
    let data = await mta.fetch('sapd', 'addUserLog', [uid, info]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);

        if (data.status == 'success') {
            tablet_openUserInfo(uid);
        }
    }
    
    makeButtonSpinner(button, false);
}