window.jobs_setTopPlayers = (topPlayers) => {
    let sortedPlayers = [
        topPlayers[1],
        topPlayers[0],
        topPlayers[2]
    ];
    // [
    //     {
    //         "id": "12",
    //         "name": "ssdas",
    //         "avatar": "null",
    //         "points": "32"
    //     },
    //     {
    //         "id": "13",
    //         "name": "novers",
    //         "avatar": "null",
    //         "points": "15"
    //     },
    //     {
    //         "id": "11",
    //         "name": "borsuczyna",
    //         "avatar": "null",
    //         "points": "5"
    //     }
    // ]

    // <div class="item small second">
    //     <div class="avatar"></div>
    //     <span>borsuczyna</span>
    //     <span class="points">386</span>
    // </div>
    // <div class="item first">
    //     <div class="avatar"></div>
    //     <span>borsuczyna</span>
    //     <span class="points">386</span>
    // </div>
    // <div class="item small third">
    //     <div class="avatar"></div>
    //     <span>borsuczyna</span>
    //     <span class="points">386</span>
    // </div>

    let classNames = ['first', 'second', 'third'];
    let list = document.querySelector('#jobs #top-players');
    let count = 0;
    list.innerHTML = '';

    for (let i = 0; i < sortedPlayers.length; i++) {
        let player = sortedPlayers[i];
        if (!player || !player.name) continue;

        count++;
        list.innerHTML += `
            <div class="item ${classNames[i]} ${i != 1 ? 'small' : ''}" data-id="${player.id}">
                <div class="avatar"></div>
                <span>${player.name}</span>
                <span class="points">${player.points}</span>
            </div>
        `;
    }

    if (count == 0) {
        list.innerHTML += `<div class="d-flex align-items-center justify-center h-100">
            <span class="empty">Brak danych</span>
        </div>`;
    }
}

window.jobs_setAvatar = (uid, avatar) => {
    let item = document.querySelector(`#jobs #top-players .item[data-id="${uid}"] .avatar`);
    if (!item) return;

    if (avatar.length > 100) {
        item.style.backgroundImage = `url('data:image/png;base64,${avatar}')`;
    } else {
        avatar = `../../${avatar.slice(1)}`;
        item.style.backgroundImage = `url('${avatar}')`;
    }
}