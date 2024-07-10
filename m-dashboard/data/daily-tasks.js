let waiting = false;
let waitingButton = null;
let preHTML = '';

window.dashboard_setDailyTasks = (tasks) => {
    let container = document.querySelector('#dashboard #daily-tasks');

    container.innerHTML = '';

    for (let task of tasks) {
        let taskData = JSON.parse(task.task)[0];
        let date = new Date(task.date);
        let isToday = date.toDateString() == new Date().toDateString();
        let isYesterday = date.toDateString() == new Date(new Date().setDate(new Date().getDate() - 1)).toDateString();
        let finished = task.progress >= taskData.max;
        let failed = !isToday && !finished;

        let progressColor = finished ? 'bg-success' : failed ? 'bg-danger' : 'bg-inprogress';
        let dayText = isToday ? 'Zadanie na dziś' : isYesterday ? 'Zadanie z wczoraj' : 'Zadanie z dnia ' + date.toLocaleDateString('pl-PL', { day: 'numeric', month: 'long', year: 'numeric' });

        // [
        //     {
        //         "date": "2024-07-10",
        //         "progress": 20,
        //         "claimed": 0,
        //         "task": {
        //             "max": 20,
        //             "text": "Graj przez 20 minut",
        //             "rewardText": "1000$"
        //         }
        //     },
        //     {
        //         "date": "2024-07-09",
        //         "progress": 0,
        //         "claimed": 0,
        //         "task": "^T^2"
        //     }
        // ]

        container.innerHTML += `
            <div class="task">
                <div class="task-header">${dayText}</div>
                <div class="d-flex justify-between gap-4">
                    <div class="task-details flex-grow-1">
                        <div>${taskData.text} (${task.progress}/${taskData.max})</div>
                        <div>Nagroda: ${taskData.rewardText}</div>
                    </div>
                    ${finished && !task.claimed ? `<div>
                        <div class="flat-button flat-button-small" onclick="dashboard_claimDailyTask(this, '${task.date}')">Odbierz</div>
                    </div>` : ''}
                </div>
                <div class="task-progress">
                    <div class="progress mt-2">
                        <div class="progress-bar ${progressColor}" role="progressbar" style="width: ${task.progress / taskData.max * 100}%;"></div>
                    </div>
                </div>
            </div>
        `;
    }
}

window.dashboard_claimDailyTask = async (button, date) => {
    if (waiting) return;
    waiting = true;
    
    waitingButton = button;
    preHTML = button.innerHTML;
    button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="1.3em" height="1.3em" viewBox="0 0 24 24"><path fill="currentColor" d="M12,4a8,8,0,0,1,7.89,6.7A1.53,1.53,0,0,0,21.38,12h0a1.5,1.5,0,0,0,1.48-1.75,11,11,0,0,0-21.72,0A1.5,1.5,0,0,0,2.62,12h0a1.53,1.53,0,0,0,1.49-1.3A8,8,0,0,1,12,4Z"><animateTransform attributeName="transform" dur="0.75s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></svg>`;
    
    mta.triggerEvent('dashboard:claimDailyTask', date);
}

addEvent('dashboard', 'get-player-last-10-daily-tasks-result', (data) => {
    data = data[0];

    dashboard_setDailyTasks(data);
});

addEvent('dashboard', 'redeem-daily-reward-result', (success) => {
    if (!success) {
        waitingButton.innerHTML = preHTML;
    } else {
        waitingButton.parentElement.remove();
    }

    waiting = false;
});