tablet_issueTicket = async (button) => {
    if (isButtonSpinner(button)) return;

    let username = document.querySelector('#tablet #ticket-name').value;
    let amount = document.querySelector('#tablet #ticket-amount').value;
    let reason = document.querySelector('#tablet #ticket-reason').value;

    amount = parseInt(amount);
    if (isNaN(amount)) {
        notis_addNotification('error', 'Błąd', 'Nieprawidłowa kwota');
        return;
    }

    if (amount < 50) {
        notis_addNotification('error', 'Błąd', 'Kwota musi być większa niż $50');
        return;
    }

    if (amount > 1000) {
        notis_addNotification('error', 'Błąd', 'Kwota musi być mniejsza niż $1000');
        return;
    }

    makeButtonSpinner(button);
    let data = await mta.fetch('sapd', 'issueTicket', [username, amount, reason]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);

        if (data.status == 'success') {
            tablet_goToTab('main');
        }
    }

    makeButtonSpinner(button, false);
}