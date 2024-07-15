let currentJob = false;
let waiting = false;

window.jobs_startJob = (button) => {
    if (jobs_getLobbySize() > 1) {
        jobs_showLobbyScreen();
    } else {
        jobs_startJobRequest(button);
    }
}

window.jobs_endJob = (button) => {
    if (waiting) return;

    waiting = true;
    waitingButton = button;
    preHTML = button.innerHTML;

    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><path fill="currentColor" d="M12,4a8,8,0,0,1,7.89,6.7A1.53,1.53,0,0,0,21.38,12h0a1.5,1.5,0,0,0,1.48-1.75,11,11,0,0,0-21.72,0A1.5,1.5,0,0,0,2.62,12h0a1.53,1.53,0,0,0,1.49-1.3A8,8,0,0,1,12,4Z"><animateTransform attributeName="transform" dur="0.75s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></svg>`;
    mta.triggerEvent('jobs:endJobI');
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

    document.querySelector('#jobs #job-name').innerText = data.name;
    document.querySelector('#jobs .background').style.backgroundImage = `url('../../m-jobs/data/images/${data.background}.png')`;
    document.querySelector('#jobs #job-description').innerText = data.description;
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
    }
});

addEvent('jobs', 'job-ended', () => {
    waiting = false;
    waitingButton.innerHTML = 'Rozpocznij pracę';
    currentJob.current = false;
});