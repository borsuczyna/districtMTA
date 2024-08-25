let lobbySize = 0;
let minLobbySize = 0;
let currentLobbyPlayers = [];
let myUid = null;
let waiting = false;
let waitingButton = null;
let preHTML = null;

window.jobs_setLobbySize = (size, minSize) => {
    document.querySelector('#jobs #coop').classList.toggle('d-none', size == 1);
    if (size > 1) document.querySelector('#jobs #coop').innerText = `Współpraca (max ${size} graczy)`;
    lobbySize = size;
    minLobbySize = minSize;
}

window.jobs_getLobbySize = () => {
    return lobbySize;
}

function switchScreens(screenA, screenB) {
    screenB.classList.remove('d-none');

    setTimer('jobs', () => {
        screenA.style.opacity = 0;
        screenA.style.transform = 'translate(-50%, -50%) scale(0.9)';
        screenB.style.opacity = 1;
        screenB.style.transform = 'translate(-50%, -50%) scale(1)';

        setTimer('jobs', () => {
            screenA.classList.add('d-none');
        }, 300);
    }, 0);
}

window.jobs_showLobbyScreen = async () => {
    let jobsWrapper = document.querySelector('#jobs #jobs-wrapper');
    let lobbyWrapper = document.querySelector('#jobs #lobby-wrapper');
    
    switchScreens(jobsWrapper, lobbyWrapper);
    new DataTable(document.querySelector('#jobs #lobbies-table'), {
        ...defaultTableData,
        data: [],
        columns: [
            { data: 'owner' },
            { data: 'players' },
            { data: 'actions' }
        ],
        order: [[2, 'desc']]
    });
    
    jobs_refreshLobbies();
}

window.jobs_refreshLobbies = async (button) => {
    if (isButtonSpinner(button)) return;
    
    makeButtonSpinner(button);
    await jobs_fetchLobbies();
    makeButtonSpinner(button, false);
}

window.jobs_goBackLobbyScreen = () => {
    let jobsWrapper = document.querySelector('#jobs #jobs-wrapper');
    let lobbyWrapper = document.querySelector('#jobs #lobby-wrapper');

    switchScreens(lobbyWrapper, jobsWrapper);
}

window.jobs_goToMyLobbyScreen = (member = false) => {
    let lobbyWrapper = document.querySelector('#jobs #lobby-wrapper');
    let myLobbyWrapper = document.querySelector('#jobs #my-lobby-wrapper');

    switchScreens(lobbyWrapper, myLobbyWrapper);

    new DataTable(document.querySelector('#jobs #my-lobby-table'), {
        ...defaultTableData,
        data: [],
        columns: [
            { data: 'player' },
            { data: 'actions' }
        ],
        order: [[1, 'desc']]
    });

    // if (member) {

    // }
    document.querySelector('#jobs #my-lobby-wrapper #start-job').classList.toggle('d-none', member);
    document.querySelector('#jobs #my-lobby-wrapper #leave-lobby').innerText = member ? 'Opuść lobby' : 'Zamknij lobby';
}

window.jobs_closeLobbyScreen = () => {
    let myLobbyWrapper = document.querySelector('#jobs #my-lobby-wrapper');
    let lobbyWrapper = document.querySelector('#jobs #lobby-wrapper');

    switchScreens(myLobbyWrapper, lobbyWrapper);
}

window.jobs_closeLobby = (button) => {
    if (waiting) return;

    waiting = true;
    waitingButton = button;
    preHTML = button.innerHTML;

    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12,4a8,8,0,0,1,7.89,6.7A1.53,1.53,0,0,0,21.38,12h0a1.5,1.5,0,0,0,1.48-1.75,11,11,0,0,0-21.72,0A1.5,1.5,0,0,0,2.62,12h0a1.53,1.53,0,0,0,1.49-1.3A8,8,0,0,1,12,4Z"><animateTransform attributeName="transform" dur="0.75s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></svg>`;
    mta.triggerEvent('jobs:quitLobby');
}

window.jobs_createLobby = async (button) => {
    if (isButtonSpinner(button)) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('jobs', 'createLobby', jobs_getCurrentJob().job);

    makeButtonSpinner(button, false);
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);

        if (data.status == 'success') {
            jobs_goToMyLobbyScreen();
        }
    }
}

window.jobs_fetchLobbies = async () => {
    // mta.triggerEvent('jobs:fetchLobbies');

    let data = await mta.fetch('jobs', 'fetchLobbies', jobs_getCurrentJob().job);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {    
        if (data.status == 'success') {
            jobs_loadLobbies(data.lobbies);
        } else {
            notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
        }
    }
}

window.jobs_updateLobbyScreen = (data) => {
    let myLobbyTable = document.querySelector('#jobs #my-lobby-table');
    let iAmTheOwner = data.owner.uid == myUid;
    currentLobbyPlayers = data.players;

    new DataTable(myLobbyTable, {
        ...defaultTableData,
        destroy: true,
        data: data.players,
        columns: [
            { data: 'name' },
            { data: 'actions', render: (data, type, row) => {
                if (!iAmTheOwner) return '';

                let isMe = row.uid == myUid;

                if (isMe) return '';
                else {
                    return `<div class="d-flex gap-1 w-100 justify-end">
                        <div class="nice-button button-sm" onclick="jobs_kickFromLobby(this, ${row.uid})">Wyrzuć</div>
                    </div>`;
                }
            } }
        ],
        order: [[1, 'desc']],
        columnDefs: [
            { targets: [1], className: 'dt-right' }
        ]
    });
}

window.jobs_loadLobbies = (data) => {
    let lobbiesTable = document.querySelector('#jobs #lobbies-table');

    new DataTable(lobbiesTable, {
        ...defaultTableData,
        destroy: true,
        data: data,
        columns: [
            { data: 'owner', render: (data) => data.name },
            { data: 'players', render: (data) => `${data.length}/${lobbySize}` },
            { data: 'actions', render: (data, type, row) => {
                return `<div class="d-flex gap-1 w-100 justify-end">
                    <div class="nice-button button-sm" onclick="jobs_joinLobby(this, ${row.owner.uid})">Dołącz</div>
                </div>`;
            } }
        ],
        order: [[2, 'desc']],
        columnDefs: [
            { targets: [1, 2], className: 'dt-right' }
        ]
    });
}

window.jobs_joinLobby = (button, owner) => {
    if (waiting) return;

    waiting = true;
    waitingButton = button;
    preHTML = button.innerHTML;

    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12,4a8,8,0,0,1,7.89,6.7A1.53,1.53,0,0,0,21.38,12h0a1.5,1.5,0,0,0,1.48-1.75,11,11,0,0,0-21.72,0A1.5,1.5,0,0,0,2.62,12h0a1.53,1.53,0,0,0,1.49-1.3A8,8,0,0,1,12,4Z"><animateTransform attributeName="transform" dur="0.75s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></svg>`;
    mta.triggerEvent('jobs:joinLobby', owner);
}

window.jobs_kickFromLobby = (button, uid) => {
    if (waiting) return;

    waiting = true;
    waitingButton = button;
    preHTML = button.innerHTML;

    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12,4a8,8,0,0,1,7.89,6.7A1.53,1.53,0,0,0,21.38,12h0a1.5,1.5,0,0,0,1.48-1.75,11,11,0,0,0-21.72,0A1.5,1.5,0,0,0,2.62,12h0a1.53,1.53,0,0,0,1.49-1.3A8,8,0,0,1,12,4Z"><animateTransform attributeName="transform" dur="0.75s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></svg>`;
    mta.triggerEvent('jobs:kickFromLobby', uid);
}

window.jobs_startJobLobby = (button) => {
    if (waiting) return;

    if (currentLobbyPlayers.length < minLobbySize) {
        notis_addNotification('error', 'Lobby', `Minimalna ilość graczy do rozpoczęcia tej pracy to ${minLobbySize}`);
        return;
    }

    jobs_startJobRequest(button);
}

window.jobs_startJobRequest = (button) => {
    if (waiting) return;

    waiting = true;
    waitingButton = button;
    preHTML = button.innerHTML;
    
    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12,4a8,8,0,0,1,7.89,6.7A1.53,1.53,0,0,0,21.38,12h0a1.5,1.5,0,0,0,1.48-1.75,11,11,0,0,0-21.72,0A1.5,1.5,0,0,0,2.62,12h0a1.53,1.53,0,0,0,1.49-1.3A8,8,0,0,1,12,4Z"><animateTransform attributeName="transform" dur="0.75s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></svg>`;
    mta.triggerEvent('jobs:startJobI');
}

addEvent('jobs', 'lobby-left', (success) => {
    waiting = false;
    if (waitingButton) waitingButton.innerHTML = preHTML;

    if (success)
        jobs_closeLobbyScreen();
});

addEvent('jobs', 'lobby-closed', () => {
    waiting = false;
    if (waitingButton) waitingButton.innerHTML = preHTML;

    jobs_closeLobbyScreen();
    notis_addNotification('info', 'Lobby', 'Lobby zostało zamknięte');
    jobs_refreshLobbies();
});

addEvent('jobs', 'interface:data:lobby', (data) => {
    data = data[0];
    
    jobs_updateLobbyScreen(data);
});

addEvent('jobs', 'interface:data:player-uid', (uid) => {
    myUid = uid;
});

addEvent('jobs', 'interface:data:lobbies', (data) => {
    data = data[0];

    waiting = false;
    if (waitingButton) waitingButton.innerHTML = preHTML;

    jobs_loadLobbies(data);
});

addEvent('jobs', 'lobby-join-result', (success) => {
    waiting = false;
    if (waitingButton) waitingButton.innerHTML = preHTML;

    if (success) {
        jobs_goToMyLobbyScreen(true);
    }
});

addEvent('jobs', 'player-joined', (data) => {
    data = data[0];

    notis_addNotification('info', 'Lobby', `Gracz ${data.name} dołączył do lobby`);
});

addEvent('jobs', 'kick-from-lobby-result', (success) => {
    waiting = false;
    if (waitingButton) waitingButton.innerHTML = preHTML;
});

addEvent('jobs', 'job-started', (success) => {
    waiting = false;
    if (waitingButton) waitingButton.innerHTML = preHTML;
});

addEvent('jobs', 'load-lobby-screen', () => {
    jobs_showLobbyScreen();
});