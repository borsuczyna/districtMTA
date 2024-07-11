function timeToString(time) {
    let timeData = [];
    time *= 60;

    let addTime = (time, name) => {
        if (time <= 0) return;
        timeData.push(`${time} ${name}`);
    }

    addTime(Math.floor(time / 86400), 'dni');
    addTime(Math.floor(time / 3600), 'godzin');
    addTime(Math.floor(time % 3600 / 60), 'minut');
    addTime(time % 60, 'sekund');

    return timeData.join(', ');
}

window.dashboard_renderAccount = (data) => {
    data = data[0];
    if (!data) {
        notis_addNotification('error', 'Błąd', 'Nie udało się pobrać danych konta.');
        return;
    }

    // <div class="item">
    //     <span>Nazwa użytkownika</span>
    //     <span data-item="username"><svg style="width: 1rem; height: 1rem;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><style>.spinner_6kVp{transform-origin:center;animation:spinner_irSm .75s infinite linear}@keyframes spinner_irSm{100%{transform:rotate(360deg)}}</style><path d="M10.72,19.9a8,8,0,0,1-6.5-9.79A7.77,7.77,0,0,1,10.4,4.16a8,8,0,0,1,9.49,6.52A1.54,1.54,0,0,0,21.38,12h.13a1.37,1.37,0,0,0,1.38-1.54,11,11,0,1,0-12.7,12.39A1.54,1.54,0,0,0,12,21.34h0A1.47,1.47,0,0,0,10.72,19.9Z" class="spinner_6kVp" fill="currentColor"/></svg></span>
    // </div>
    // <div class="item">
    //     <span>Ranga</span>
    //     <span data-item="rank"><svg style="width: 1rem; height: 1rem;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><style>.spinner_6kVp{transform-origin:center;animation:spinner_irSm .75s infinite linear}@keyframes spinner_irSm{100%{transform:rotate(360deg)}}</style><path d="M10.72,19.9a8,8,0,0,1-6.5-9.79A7.77,7.77,0,0,1,10.4,4.16a8,8,0,0,1,9.49,6.52A1.54,1.54,0,0,0,21.38,12h.13a1.37,1.37,0,0,0,1.38-1.54,11,11,0,1,0-12.7,12.39A1.54,1.54,0,0,0,12,21.34h0A1.47,1.47,0,0,0,10.72,19.9Z" class="spinner_6kVp" fill="currentColor"/></svg></span>
    // </div>
    // <div class="item">
    //     <span>Czas gry</span>
    //     <span data-item="timePlayed"><svg style="width: 1rem; height: 1rem;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><style>.spinner_6kVp{transform-origin:center;animation:spinner_irSm .75s infinite linear}@keyframes spinner_irSm{100%{transform:rotate(360deg)}}</style><path d="M10.72,19.9a8,8,0,0,1-6.5-9.79A7.77,7.77,0,0,1,10.4,4.16a8,8,0,0,1,9.49,6.52A1.54,1.54,0,0,0,21.38,12h.13a1.37,1.37,0,0,0,1.38-1.54,11,11,0,1,0-12.7,12.39A1.54,1.54,0,0,0,12,21.34h0A1.47,1.47,0,0,0,10.72,19.9Z" class="spinner_6kVp" fill="currentColor"/></svg></span>
    // </div>
    // <div class="item">
    //     <span>Czas AFK</span>
    //     <span data-item="timeAfk"><svg style="width: 1rem; height: 1rem;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><style>.spinner_6kVp{transform-origin:center;animation:spinner_irSm .75s infinite linear}@keyframes spinner_irSm{100%{transform:rotate(360deg)}}</style><path d="M10.72,19.9a8,8,0,0,1-6.5-9.79A7.77,7.77,0,0,1,10.4,4.16a8,8,0,0,1,9.49,6.52A1.54,1.54,0,0,0,21.38,12h.13a1.37,1.37,0,0,0,1.38-1.54,11,11,0,1,0-12.7,12.39A1.54,1.54,0,0,0,12,21.34h0A1.47,1.47,0,0,0,10.72,19.9Z" class="spinner_6kVp" fill="currentColor"/></svg></span>
    // </div>
    // <div class="item">
    //     <span>Data rejestracji</span>
    //     <span data-item="registerDate"><svg style="width: 1rem; height: 1rem;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><style>.spinner_6kVp{transform-origin:center;animation:spinner_irSm .75s infinite linear}@keyframes spinner_irSm{100%{transform:rotate(360deg)}}</style><path d="M10.72,19.9a8,8,0,0,1-6.5-9.79A7.77,7.77,0,0,1,10.4,4.16a8,8,0,0,1,9.49,6.52A1.54,1.54,0,0,0,21.38,12h.13a1.37,1.37,0,0,0,1.38-1.54,11,11,0,1,0-12.7,12.39A1.54,1.54,0,0,0,12,21.34h0A1.47,1.47,0,0,0,10.72,19.9Z" class="spinner_6kVp" fill="currentColor"/></svg></span>
    // </div>
    // <div class="item">
    //     <span>Ostatnie logowanie</span>
    //     <span data-item="lastLogin"><svg style="width: 1rem; height: 1rem;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><style>.spinner_6kVp{transform-origin:center;animation:spinner_irSm .75s infinite linear}@keyframes spinner_irSm{100%{transform:rotate(360deg)}}</style><path d="M10.72,19.9a8,8,0,0,1-6.5-9.79A7.77,7.77,0,0,1,10.4,4.16a8,8,0,0,1,9.49,6.52A1.54,1.54,0,0,0,21.38,12h.13a1.37,1.37,0,0,0,1.38-1.54,11,11,0,1,0-12.7,12.39A1.54,1.54,0,0,0,12,21.34h0A1.47,1.47,0,0,0,10.72,19.9Z" class="spinner_6kVp" fill="currentColor"/></svg></span>
    // </div>
    // <div class="item">
    //     <span>Ilość pojazdów</span>
    //     <span data-item="vehiclesCount"><svg style="width: 1rem; height: 1rem;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><style>.spinner_6kVp{transform-origin:center;animation:spinner_irSm .75s infinite linear}@keyframes spinner_irSm{100%{transform:rotate(360deg)}}</style><path d="M10.72,19.9a8,8,0,0,1-6.5-9.79A7.77,7.77,0,0,1,10.4,4.16a8,8,0,0,1,9.49,6.52A1.54,1.54,0,0,0,21.38,12h.13a1.37,1.37,0,0,0,1.38-1.54,11,11,0,1,0-12.7,12.39A1.54,1.54,0,0,0,12,21.34h0A1.47,1.47,0,0,0,10.72,19.9Z" class="spinner_6kVp" fill="currentColor"/></svg></span>
    // </div>
    // <div class="item">
    //     <span>Organizacja</span>
    //     <span data-item="organization"><svg style="width: 1rem; height: 1rem;" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><style>.spinner_6kVp{transform-origin:center;animation:spinner_irSm .75s infinite linear}@keyframes spinner_irSm{100%{transform:rotate(360deg)}}</style><path d="M10.72,19.9a8,8,0,0,1-6.5-9.79A7.77,7.77,0,0,1,10.4,4.16a8,8,0,0,1,9.49,6.52A1.54,1.54,0,0,0,21.38,12h.13a1.37,1.37,0,0,0,1.38-1.54,11,11,0,1,0-12.7,12.39A1.54,1.54,0,0,0,12,21.34h0A1.47,1.47,0,0,0,10.72,19.9Z" class="spinner_6kVp" fill="currentColor"/></svg></span>
    // </div>

    document.querySelector(`#dashboard .tab[tab="main"] .loading`).classList.add('d-none');
    let element = document.querySelector(`#dashboard .tab[tab="main"] .list`);
    element.innerHTML = '';

    let setData = (key, value, html) => {
        let item = document.createElement('div');
        item.classList.add('item');
        item.innerHTML = `<span>${key}</span><span>${html ? value : htmlEscape(value.toString())}</span>`;
        element.appendChild(item);
    }

    setData('Nazwa użytkownika', data.username);
    setData('Ranga', `<span style="color: rgb(${data.rankColor.join(', ')})">${htmlEscape(data.rank)}</span>`, true);
    setData('Przegrany czas', timeToString(data.timePlayed));
    setData('Czas AFK', timeToString(data.timeAfk));
    setData('Data rejestracji', new Date(data.registerDate).toLocaleString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' }));
    setData('Ostatnie logowanie', new Date(data.lastActive).toLocaleString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' }));
    setData('Ilość pojazdów', data.vehiclesCount);
    setData('Organizacja', data.organization);

    setArcPercent(document.querySelector('#dashboard .level-card .level'), 0.7 * 99.99);
    document.querySelector('#dashboard .level-card .level-text').innerText = data.level;
    document.querySelectorAll('#dashboard .money-card .money')[0].innerText = `\$${data.money.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`;
    document.querySelectorAll('#dashboard .money-card .money')[1].innerText = `\$${data.bankMoney.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`;
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