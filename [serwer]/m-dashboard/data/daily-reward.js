let dailyRewardData = {
    day: 1,
    date: 0
}

function canRedeemDailyReward() {
    return dailyRewardData.date <= new Date().getTime() / 1000;
}

function updateTimeLeft(card, date) {
    let timeLeft = date - new Date();
    let button = card.querySelector('.button');

    if (timeLeft <= 1) {
        button.innerText = 'Odbierz';
        button.setAttribute('onclick', 'dashboard_redeemDailyReward(this);');
        return;
    } else {
        let hours = Math.floor(timeLeft / 1000 / 60 / 60);
        let minutes = Math.floor(timeLeft / 1000 / 60 % 60);
        let seconds = Math.floor(timeLeft / 1000 % 60);
        let timeLeftString = [];

        if (hours > 0) timeLeftString.push(hours + 'h');
        if (minutes > 0) timeLeftString.push(minutes + 'm');
        if (seconds > 0) timeLeftString.push(seconds + 's');
        if (timeLeftString.length == 0) timeLeftString.push('0s');

        button.innerText = timeLeftString.join(' ');
        // button.classList.add('grayed');

        setTimer('dashboard', updateTimeLeft, 1000, card, date);
    }
}

function showNextDailyReward() {
    dailyRewardData.day++;
    dailyRewardData.date = new Date().getTime() / 1000 + 86400;
    dashboard_setDailyRewardData(dailyRewardData.day, dailyRewardData.date);

    // set yesterday reward as today reward and today reward as Ładowanie...
    let dailyCards = document.querySelectorAll('#dashboard .daily-reward-card');
    let yesterdayReward = dailyCards[0].querySelector('.reward');
    let todayReward = dailyCards[1].querySelector('.reward');

    yesterdayReward.innerText = todayReward.innerText;
    todayReward.innerText = 'Ładowanie...';
}

window.dashboard_redeemDailyReward = async (button) => {
    if (isButtonSpinner(button)) return;
    if (!canRedeemDailyReward()) return;
    
    makeButtonSpinner(button);
    let data = await mta.fetch('dashboard', 'redeemDailyReward');

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            showNextDailyReward();
            mta.triggerEvent('dashboard:fetchDailyReward');
        }
    }
    
    makeButtonSpinner(button, false);
}

window.dashboard_setDailyRewardData = (day, date) => {
    dailyRewardData.day = parseInt(day);
    dailyRewardData.date = date;

    let dailyCards = document.querySelectorAll('#dashboard .daily-reward-card');
    let redeemCard = dailyCards[1];

    dailyCards[0].classList.toggle('d-none', day <= 1);
    
    let drawDay = day - 1;
    for (let card of dailyCards) {
        let dayBox = card.querySelector('.day');
        let button = card.querySelector('.button');
        dayBox.innerText = drawDay++;
        if (button) button.onclick = null;
    }

    if (date == true) {
        updateTimeLeft(redeemCard, new Date() - 1);
    } else {
        let dateObj = new Date(parseInt(date) * 1000);
        updateTimeLeft(redeemCard, dateObj);
    }
}

window.dashboard_setDailyReward = (yesterday, today) => {
    let dailyCards = document.querySelectorAll('#dashboard .daily-reward-card');
    let yesterdayReward = dailyCards[0].querySelector('.reward');
    let todayReward = dailyCards[1].querySelector('.reward');

    if (yesterday != false) {
        yesterdayReward.innerText = yesterday;
    }

    if (today != false) {
        todayReward.innerText = today;
    }

    let dailyHistory = document.querySelector('#dashboard #daily-reward-history');
    dailyHistory.innerHTML = '';
}

window.dashboard_setLast10DaysRewards = (last10Days) => {
    let dailyHistory = document.querySelector('#dashboard #daily-reward-history');
    dailyHistory.innerHTML = '';

    last10Days.sort((a, b) => new Date(b.date) - new Date(a.date));

    for (let day of last10Days) {
        let dateObj = new Date(day.date);
        let dayBox = document.createElement('div');
        dayBox.classList.add('d-flex', 'justify-between');
        dayBox.innerHTML = `<span>${day.reward}</span><span>${dateObj.toLocaleDateString('pl-PL', { day: 'numeric', month: 'long', year: 'numeric' })}</span>`;

        dailyHistory.appendChild(dayBox);
    }

    let dailyCards = document.querySelectorAll('#dashboard .daily-reward-card');
    let yesterdayReward = dailyCards[0].querySelector('.reward');

    if (last10Days.length == 0) {
        yesterdayReward.innerText = 'Brak danych';
        return;
    }
    
    yesterdayReward.innerText = last10Days[0].reward;
}

addEvent('dashboard', 'fetch-daily-reward-result', (data) => {
    data = data[0];

    dashboard_setDailyReward(data.yesterday, data.today);
});

addEvent('dashboard', 'get-player-last-10-daily-rewards-result', (data) => {
    dashboard_setLast10DaysRewards(data[0]);
});