function formatNumber(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

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

factionPanel_renderMainPage = () => {
    let topWorkedMinutes = factionData.members.sort((a, b) => b.dutyTime - a.dutyTime)[0];
    let myData = factionData.members.find(member => member.user === factionData.uid);
    let totalPayTime = factionData.members.reduce((acc, member) => acc + member.payTime, 0);
    let totalWorkedMinutes = factionData.members.reduce((acc, member) => acc + member.dutyTime, 0);

    document.querySelector('#faction-panel #main-page-cards .card[data-card="topWorkedMinutes"] .value').innerText = topWorkedMinutes ? `${topWorkedMinutes.playerName} (${timeToString(topWorkedMinutes.dutyTime)})` : 'Brak';
    document.querySelector('#faction-panel #main-page-cards .card[data-card="totalWorkers"] .value').innerText = factionData.members.length;
    document.querySelector('#faction-panel #main-page-cards .card[data-card="yourPayment"] .value').innerText = myData ? `$${addCents(myData.payTime * factionData.payPerMinute)}` : 'Brak';
    document.querySelector('#faction-panel #main-page-cards .card[data-card="totalPayment"] .value').innerText = `$${addCents(totalPayTime * factionData.payPerMinute)}`;
    document.querySelector('#faction-panel #main-page-cards .card[data-card="workedMinutes"] .value').innerText = timeToString(myData ? myData.dutyTime : 0);
    document.querySelector('#faction-panel #main-page-cards .card[data-card="totalWorkedMinutes"] .value').innerText = timeToString(totalWorkedMinutes);
}