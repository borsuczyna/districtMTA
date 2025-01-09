let currentJob = false;
let waiting = false;

window.jobs_startJob = (button) => {
    if (jobs_getLobbySize() > 1) {
        mta.triggerEvent('jobs:checkJobAvailability');
    } else {
        jobs_startJobRequest(button);
    }
}

window.jobs_getCurrentJob = () => currentJob;

window.jobs_endJob = async (button) => {
    if (isButtonSpinner(button)) return;
    
    makeButtonSpinner(button);
    let data = await mta.fetch('jobs', 'endJobI');

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        makeButtonSpinner(button, false);
    } else if (data.status == 'success') {
        makeButtonSpinner(button, false);
        button.innerHTML = 'Rozpocznij pracę';
        currentJob.current = false;
    }
}

window.jobs_startOrEndJob = (button) => {
    if (currentJob.current == currentJob.job) {
        window.jobs_endJob(button);
    } else {
        window.jobs_startJob(button);
    }
}

addEvent('jobs', 'interface:data:job-details', async (data) => {
    data = data[0];

    if (data.multiplier && data.multiplier != 1) {
        data.description += `<br><br><span class="multiplier-info">Mnożnik zarobków ${data.multiplier}x</span>`;
    }

    document.querySelector('#jobs #job-name').innerText = data.name;
    document.querySelector('#jobs .background').style.backgroundImage = `url('/m-jobs/data/images/${data.background}.png')`;
    document.querySelector('#jobs #job-description').innerHTML = data.description;
    document.querySelector('#jobs #level-required').innerHTML = data.minLevel;
    jobs_setLobbySize(data.lobbySize, data.minLobbySize);
});

addEvent('jobs', 'interface:data:in-job', async (job) => {
    currentJob = job[0];

    document.querySelector('#jobs #start-job-main').innerText = currentJob.current == currentJob.job ? 'Zakończ pracę' : 'Rozpocznij pracę';
});

addEvent('jobs', 'interface:data:job-player-data', async (data) => {
    data = data[0];

    let topPlayers = data.topPlayers.split(';').map(x => {
        let [id, name, avatar, points] = x.split(' ');
        return { id, name, avatar, points };
    });

    jobs_setUpgrades(data.upgrades, data.playerUpgrades);
    jobs_setTopPlayers(topPlayers);
    jobs_setJobsPoints(data.upgradePoints);
});

addEvent('jobs', 'play-animation', async (appear) => {
    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#jobs #jobs-wrapper').style.opacity = appear ? '1' : '0';
    document.querySelector('#jobs #jobs-wrapper').style.transform = appear ? 'translate(-50%, -50%) scale(1)' : 'translate(-50%, -50%) scale(0.9)';
    
    if (!appear) {
        document.querySelector('#jobs #lobby-wrapper').style.opacity = appear ? '1' : '0';
        document.querySelector('#jobs #lobby-wrapper').style.transform = appear ? 'translate(-50%, -50%) scale(1)' : 'translate(-50%, -50%) scale(0.9)';
        document.querySelector('#jobs #my-lobby-wrapper').style.opacity = appear ? '1' : '0';
        document.querySelector('#jobs #my-lobby-wrapper').style.transform = appear ? 'translate(-50%, -50%) scale(1)' : 'translate(-50%, -50%) scale(0.9)';
        intro_hideIntro('jobs');
    } else {
        jobs_showIntro();
    }
});