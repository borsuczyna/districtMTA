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

    let setData = (key, value, html) => {
        let element = document.querySelector(`#dashboard .tab[tab="main"] [data-item="${key}"]`);
        if (!element) {
            notis_addNotification('error', 'Błąd', 'Nie udało się znaleźć elementu.');
            return;
        }

        if (html) {
            element.innerHTML = value;
        } else {
            element.innerText = value;
        }
    }

    setData('username', data.username);
    setData('rank', `<span style="color: rgb(${data.rankColor.join(', ')})">${htmlEscape(data.rank)}</span>`, true);
    setData('registerDate', new Date(data.registerDate).toLocaleString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' }));
    setData('lastLogin', new Date(data.lastActive).toLocaleString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' }));
    setData('timePlayed', timeToString(data.timePlayed));
    setData('timeAfk', timeToString(data.timeAfk));
    setData('organization', data.organization);
    setData('vehiclesCount', data.vehiclesCount);

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