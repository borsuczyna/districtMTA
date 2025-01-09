let dataCache = {};
window.dashboard_playerPosition = [0, 0, 0];

window.dashboard_changeTab = function(item) {
    seasonPass_closeBuyPass();
    
    let tabs = document.querySelectorAll('#dashboard #list .item');
    let tabsContent = document.querySelectorAll('#dashboard #tabs .tab');
    let currentTab = item.getAttribute('tab');

    tabs.forEach(tab => {
        tab.classList.toggle('active', tab.getAttribute('tab') === currentTab);
    });

    tabsContent.forEach(tab => {
        tab.classList.toggle('active', tab.getAttribute('tab') === currentTab);
    });

    dashboard_hideVehicleDetails();
}

window.dashboard_fetchData = async (tab) => {
    if (dataCache[tab]) {
        fetchDataResult([{ data: tab, result: dataCache[tab] }]);
        return;
    }

    let currentTab = document.querySelector('#dashboard #list .item.active').getAttribute('tab');
    if (currentTab == tab) return;

    let data = await mta.fetch('dashboard', 'fetchData', tab);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        switch (tab) {
            case 'logs':
                dashboard_renderLogs(document.querySelector('#dashboard #tabs [tab="logs"]'), data.data);
                break;
            case 'money-logs':
                dashboard_renderLogs(document.querySelector('#dashboard #tabs [tab="money-logs"]'), data.data, true);
                break;
            case 'punishments':
                dashboard_renderPunishments(data.data);
                break;
            case 'vehicles':
                dashboard_renderVehicles(data.data);
                break;
            case 'account':
                dashboard_renderAccount(data.data);
                break;
            case 'achievements':
                dashboard_renderAchievements(data.data);
                break;
            case 'discord':
                dashboard_renderDiscord(data.data[0]);
                break;
        }
    }
}

window.dashboard_setAvatar = (avatar) => {
    if (avatar.length > 100) {
        document.querySelector('#dashboard .avatar').style.backgroundImage = `url('data:image/png;base64,${avatar}')`;
    } else {
        avatar = `/${avatar.slice(1)}`;
        document.querySelector('#dashboard .avatar').style.backgroundImage = `url('${avatar}')`;
    }
}

addEvent('dashboard', 'play-animation', async (appear) => {
    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#dashboard').style.opacity = appear ? '1' : '0';
});

addEvent('dashboard', 'update-data', (data) => {
    data = data[0];
    
    // settings
    Object.keys(data.settings).forEach(key => {
        dashboard_setSetting(key, data.settings[key]);
    });

    // daily reward
    dashboard_setDailyRewardData(data.dailyRewardDay, data.dailyRewardRedeem);

    // position
    window.dashboard_playerPosition = data.playerPosition;
});