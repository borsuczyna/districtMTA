window.dashboard_renderAchievements = (data) => {
    let list = document.querySelector('#dashboard #achievements');
    list.innerHTML = '';

    data.achievements.forEach((achievement, index) => {
        let achieved = data.data.includes(index + 1);
        let card = document.createElement('div');
        card.classList.add('achievement-card');
        if (achieved) card.classList.add('achieved');

        card.innerHTML = `
            <div class="title">${achievement.title}</div>
            <div class="description">${achievement.description}</div>
            <div class="progress">
                <div class="progress-bar" style="width: ${achievement.achieved}%"></div>
            </div>
            <div class="percent">${Math.floor(achievement.achieved)}% graczy zdobyło to osiągnięcie</div>
        `;

        list.appendChild(card);
    });
}