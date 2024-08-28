// [
//     {
//         "discordAccount": "1250137230920388640", | false
//         "discordCode": "BZR58Q1V"
//     }
// ]

window.dashboard_renderDiscord = (data) => {
    let element = document.querySelector(`#dashboard .tab[tab="discord"]`);

    if (!data.discordAccount) {
        element.innerHTML = `
            <h2 class="mb-1">Łączenie konta z Discord</h2>
            <p>Do części funkcji na naszym serwerze wymagane jest połączenie konta z Discordem.
            Aby to zrobić, dołącz na <a href="#" onclick="dashboard_copyDiscordUrl()">nasz serwer discord</a> i wpisz poniższy kod na kanale #komendy</p>
            <br>
            <h2 class="mb-1" style="font-weight: 400;">Kod do wpisania: <a href="#" style="font-weight: 600;" onclick="dashboard_copyDiscordCode('${data.discordCode}')">${data.discordCode}</a></h2>
        `;
    } else {
        // tutaj zrob
    }
}

window.dashboard_copyDiscordUrl = () => {
    mta.triggerEvent('interface:setClipboard', 'https://discord.gg/85Jjz2CZpT');
    notis_addNotification('info', 'Discord', 'Adres serwera został skopiowany do schowka.');
}

window.dashboard_copyDiscordCode = (code) => {
    mta.triggerEvent('interface:setClipboard', `/polacz kod:${code}`);
    notis_addNotification('info', 'Discord', 'Kod został skopiowany do schowka.');
}