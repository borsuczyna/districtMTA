window.dashboard_playerPosition = [0, 0, 0];

window.dashboard_changeTab = function(item) {
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

window.dashboard_setLevelData = function(current, next, progress) {
    document.querySelector('#dashboard #level-current').innerText = current;
    document.querySelector('#dashboard #level-next').innerText = next;
    document.querySelector('#dashboard #level-progress').style.width = progress + '%';
}

window.dashboard_fetchData = function(tab) {
    let currentTab = document.querySelector('#dashboard #list .item.active').getAttribute('tab');
    if (currentTab == tab) return;

    mta.triggerEvent('dashboard:fetchData', tab);
}

addEvent('dashboard', 'fetch-data-result', (data) => {
    data = data[0];
    let type = data.data;
    let result = data.result;

    if (type === 'punishments') {
        dashboard_renderPunishments(result);
    } else if (type === 'vehicles') {
        dashboard_renderVehicles(result);
    }
});

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

    // level
    dashboard_setLevelData(data.level, data.level + 1, data.levelProgress);

    // position
    window.dashboard_playerPosition = data.playerPosition;
});