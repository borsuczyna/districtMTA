let waiting = false;

window.inventory_toggleNearbyPlayers = (visible) => {
    document.querySelector('#inventory #players-wrapper').classList.toggle('d-none', !visible);
    document.querySelector('#inventory #items-wrapper').classList.toggle('d-none', visible);
    document.querySelector('#inventory #main-tab-title').textContent = visible ? 'Pobliscy gracze' : 'Twoje przedmioty';

    let playerList = document.querySelector('#inventory #player-list');
    playerList.className= 'justify-center pt-3 pb-3';
    playerList.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12,4a8,8,0,0,1,7.89,6.7A1.53,1.53,0,0,0,21.38,12h0a1.5,1.5,0,0,0,1.48-1.75,11,11,0,0,0-21.72,0A1.5,1.5,0,0,0,2.62,12h0a1.53,1.53,0,0,0,1.49-1.3A8,8,0,0,1,12,4Z"><animateTransform attributeName="transform" dur="0.75s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></svg>
        Wczytywanie...`;

    mta.triggerEvent('inventory:getNearbyPlayers');
}

window.inventory_toggleTradeCategory = (visible) => {
    let category = document.querySelector('#inventory .category[key="trade"]');
    if (!category) return;

    category.classList.toggle('d-none', !visible);
    if (!visible) inventory_toggleNearbyPlayers(false);
}

addEvent('inventory', 'interface:data:nearbyPlayers', (players) => {
    players = players[0];

    let playerList = document.querySelector('#inventory #player-list');
    playerList.className = 'flex-column';
    playerList.innerHTML = '';

    players.forEach(player => {
        playerList.innerHTML += `<div class="player">
            <span>${htmlEscape(player.name)}</span>
            <div class="flat-button flat-button-small" onclick="inventory_tradeWith(${player.uid}, this)">Wymiana</div>
        </div>`;
    });

    if (players.length == 0) {
        playerList.className = 'justify-center pt-3 pb-3';
        playerList.innerHTML = 'Brak graczy w pobliżu';
    }
});

window.inventory_tradeWith = async (uid, button) => {
    if (waiting) return;
    if (isButtonSpinner(button)) return;

    makeButtonSpinner(button);
    waiting = true;
    let data = await mta.fetch('inventory', 'tradeWith', uid);
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    }

    makeButtonSpinner(button, false);
    waiting = false;
}