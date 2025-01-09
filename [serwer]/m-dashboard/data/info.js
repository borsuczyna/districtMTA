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

window.dashboard_renderAccount = (data) => {
    data = data[0];
    if (!data) {
        notis_addNotification('error', 'Błąd', 'Nie udało się pobrać danych konta.');
        return;
    }

    document.querySelector(`#dashboard .tab[tab="main"] .loading`).classList.add('d-none');
    let element = document.querySelector(`#dashboard .tab[tab="main"] .list`);
    element.innerHTML = '';

    let setData = (key, value, html) => {
        let item = document.createElement('div');
        item.classList.add('item');
        item.classList.add('ignore');
        item.innerHTML = `<span>${key}</span><span>${html ? value : htmlEscape(value.toString())}</span>`;
        element.appendChild(item);
    }

    setData('ID konta', data.uid);
    setData('Nazwa użytkownika', data.username);
    setData('Ranga', `<span style="color: rgb(${data.rankColor.join(', ')})">${htmlEscape(data.rank)}</span>`, true);
    setData('Przegrany czas', timeToString(data.timePlayed));
    setData('Czas AFK', timeToString(data.timeAfk));
    setData('Data rejestracji', new Date(data.registerDate).toLocaleString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' }));
    setData('Ostatnie logowanie', new Date(data.lastActive).toLocaleString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' }));
    setData('Ilość pojazdów', data.vehiclesCount);
    setData('Organizacja', data.organization);
    dashboard_setMissions(data.missions);

    setArcPercent(document.querySelector('#dashboard .level-card .level'), data.exp / data.nextLevelExp * 99.99);
    
    document.querySelector('#dashboard .level-card .level-text').innerText = data.level;
    document.querySelector('#dashboard .level-card .level-text').style.fontSize = (data.level >= 1000 && '2.5rem' || data.level >= 100 && '3rem' || '4.1rem');
    
    document.querySelectorAll('#dashboard .money-card .money')[0].innerText = `\$${addCents(data.money).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`;
    document.querySelectorAll('#dashboard .money-card .money')[1].innerText = `\$${addCents(data.bankMoney).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`;
    document.querySelector('#dashboard #username').innerText = data.username;
    document.querySelector('#dashboard #rank').innerHTML = `<span style="color: rgb(${data.rankColor.join(', ')})">${htmlEscape(data.rank)}</span>`;
}

window.dashboard_setMissions = (missions) => {
    let list = document.querySelector('#dashboard #missions-list');
    list.innerHTML = '';

    for (const mission of missions) {
        let item = document.createElement('div');
        item.className = 'item d-flex gap-2 update';
        item.innerHTML = `
            <img src="/m-missions/data/backgrounds/${mission.icon ?? '1.png'}" class="mission-image"/>
            <div class="d-flex flex-column w-100">
                <div class="d-flex justify-between">
                    <div class="title">${mission.title}</div>
                    ${mission.passed ? `
                    <div class="d-flex gap-2 align-items-center">
                        <div class="date">Wykonano</div>
                        <div class="nice-button button-sm" onclick="dashboard_repeatMission(this, ${mission.id})">Powtórz</div>
                    </div>` : ''}
                </div>
                <div class="description">${mission.description}</div>
            </div>
        `;
        list.appendChild(item);
    }
}

function polarToCartesian(centerX, centerY, radius, angleInDegrees) {
    const angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
    return {
        x: centerX + (radius * Math.cos(angleInRadians)),
        y: centerY + (radius * Math.sin(angleInRadians))
    };
}

function setArcStartAndEndAngle(element, start, end) {
    const radius = 50;
    const centerX = 50;
    const centerY = 50;
    const startCoords = polarToCartesian(centerX, centerY, radius, end);
    const endCoords = polarToCartesian(centerX, centerY, radius, start);

    const largeArcFlag = end - start <= 180 ? "0" : "1";

    const d = [
        "M", centerX, centerY,
        "L", startCoords.x, startCoords.y,
        "A", radius, radius, 0, largeArcFlag, 0, endCoords.x, endCoords.y,
        "Z"
    ].join(" ");

    element.querySelector('path').setAttribute('d', d);
}

function setArcPercent(element, percent) {
    setArcStartAndEndAngle(element, 0, percent * 3.6);
}

dashboard_repeatMission = async (button, index) => {
    if (isButtonSpinner(button)) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('missions', 'restartMission', index);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    }

    makeButtonSpinner(button, false);
}