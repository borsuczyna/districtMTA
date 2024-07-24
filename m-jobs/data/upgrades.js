let jobPoints = 0;
let upgradesData = [];
let playerUpgradesData = [];

window.jobs_setJobsPoints = (points) => {
    document.querySelector('#jobs #upgrade-points').innerHTML = points;
    jobPoints = points;
}

window.jobs_setUpgrades = (upgrades, playerUpgrades) => {
    playerUpgrades = playerUpgrades.map(x => parseInt(x));
    
    let upgradesWrapper = document.querySelector('#jobs .upgrades');
    upgradesWrapper.innerHTML = '';

    upgradesData = upgrades;
    playerUpgradesData = playerUpgrades;

    for (let i = 0; i < upgrades.length; i++) {
        let upgrade = upgrades[i];
        let gotUpgrade = playerUpgrades.find(x => i + 1 === x);

        upgradesWrapper.innerHTML += `
            <div class="item ${gotUpgrade ? 'bought' : ''}" data-id="${i + 1}">
                <div class="d-flex flex-column">
                    <div class="title">${upgrade.name}${!gotUpgrade ? ` <small>(${upgrade.points}pkt)</small>` : ''}</div>
                    <div class="description">${upgrade.description}</div>
                </div>
                ${!gotUpgrade ? `
                <div class="button" onclick="jobs_buyUpgrade(this, ${i + 1})">
                    <svg viewBox="0 0 27 22" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" clip-rule="evenodd" d="M6.82879 0.0320352C7.38519 0.174624 7.72348 0.75258 7.58438 1.32294L6.52235 5.67761H20.4777L19.4156 1.32294C19.2765 0.75258 19.6148 0.174624 20.1712 0.0320352C20.7276 -0.110554 21.2914 0.23622 21.4305 0.806576L22.6185 5.67761H25.9615C26.5351 5.67761 27 6.1542 27 6.74211C27 7.33002 26.5351 7.80661 25.9615 7.80661H24.1321L23.0904 18.4852C22.8957 20.4805 21.2578 22 19.3016 22H7.69843C5.74222 22 4.10428 20.4805 3.90963 18.4852L2.8679 7.80661H1.03846C0.464935 7.80661 0 7.33002 0 6.74211C0 6.1542 0.464935 5.67761 1.03846 5.67761H4.3815L5.56947 0.806576C5.70857 0.23622 6.27238 -0.110554 6.82879 0.0320352ZM10.2 12.8571C10.2 12.3838 9.70751 12 9.1 12C8.49249 12 8 12.3838 8 12.8571V15.1429C8 15.6162 8.49249 16 9.1 16C9.70751 16 10.2 15.6162 10.2 15.1429V12.8571ZM14.6 12.8571C14.6 12.3838 14.1075 12 13.5 12C12.8925 12 12.4 12.3838 12.4 12.8571V15.1429C12.4 15.6162 12.8925 16 13.5 16C14.1075 16 14.6 15.6162 14.6 15.1429V12.8571ZM19 12.8571C19 12.3838 18.5075 12 17.9 12C17.2925 12 16.8 12.3838 16.8 12.8571V15.1429C16.8 15.6162 17.2925 16 17.9 16C18.5075 16 19 15.6162 19 15.1429V12.8571Z" fill="currentColor" />
                    </svg>
                </div>` : ''}
            </div>
        `;
    }
}

window.jobs_buyUpgrade = async (button, id) => {
    if (isButtonSpinner(button)) return;
    
    makeButtonSpinner(button);
    let data = await mta.fetch('jobs', 'buyUpgrade', [jobs_getCurrentJob().job, id]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            playerUpgradesData.push(data.upgrade);
            jobPoints -= data.cost;
            
            jobs_setUpgrades(upgradesData, playerUpgradesData);
            jobs_setJobsPoints(jobPoints);
        }
    }
    
    makeButtonSpinner(button, false);
}