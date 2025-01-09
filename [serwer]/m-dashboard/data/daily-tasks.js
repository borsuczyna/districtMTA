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
    if (isButtonSpinner(button)) return;
    
    makeButtonSpinner(button);
    let data = await mta.fetch('dashboard', 'claimDailyTask', date);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            button.parentElement.remove();
        }
    }
    
    makeButtonSpinner(button, false);
}

addEvent('dashboard', 'get-player-last-10-daily-tasks-result', (data) => {
    data = data[0];

    dashboard_setDailyTasks(data);
});