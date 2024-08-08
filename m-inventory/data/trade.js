window.inventory_yourOffer = [];
window.inventory_theirOffer = [];
window.inventory_isTrading = false;
window.inventory_tradeAccepted = false;
window.inventory_meAccepted = false;

window.inventory_showTrade = () => {
    document.querySelector('#inventory #trade-wrapper').classList.remove('d-none');
    window.inventory_isTrading = true;
    inventory_toggleTradeCategory(false);
    inventory_renderItems();
}

window.inventory_updateTrade = () => {
    inventory_renderItems(true, document.querySelector('#inventory #your-offer-wrapper .items'), inventory_yourOffer);
    inventory_renderItems(true, document.querySelector('#inventory #their-offer-wrapper .items'), inventory_theirOffer);
}

window.inventory_addToOffer = async (hash) => {
    let item = inventory_getItemByHash(hash);
    if (!item) return;

    let count = item.amount > 1 ? (await inventory_askForCount(item.amount)) : 1;
    if (count == null || count < 1) {
        notis_addNotification('error', 'Błąd', 'Nieprawidłowa ilość');
        return;
    }

    let data = await mta.fetch('inventory', 'addToOffer', [hash, count]);
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else if (data.status != 'success') {
        notis_addNotification('error', 'Błąd', data.message);
        return;
    }

    notis_addNotification('success', 'Sukces', 'Dodano przedmiot do oferty');
}

window.inventory_removeFromOfferTrade = async (hash) => {
    let item = inventory_getItemByHash(hash);
    if (!item) return;

    let count = item.amount > 1 ? (await inventory_askForCount(item.amount)) : 1;
    if (count == null || count < 1) {
        notis_addNotification('error', 'Błąd', 'Nieprawidłowa ilość');
        return;
    }

    let data = await mta.fetch('inventory', 'removeFromOffer', [hash, count]);
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else if (data.status != 'success') {
        notis_addNotification('error', 'Błąd', data.message);
        return;
    }

    notis_addNotification('success', 'Sukces', 'Usunięto przedmiot z oferty');
}

window.inventory_cancelTrading = async () => {
    let data = await mta.fetch('inventory', 'cancelTrading', []);
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else if (data.status != 'success') {
        notis_addNotification('error', 'Błąd', data.message);
        return;
    }

    notis_addNotification('success', 'Sukces', 'Anulowano wymiane');
}

window.inventory_acceptTrading = async () => {
    let data = await mta.fetch('inventory', 'acceptTrading', []);
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
        return;
    } else if (data.status != 'success') {
        notis_addNotification('error', 'Błąd', data.message);
        return;
    }

    inventory_meAccepted = !inventory_meAccepted;
    notis_addNotification('info', 'Wymiana', !window.inventory_meAccepted ? 'Zaakceptowano wymianę' : 'Anulowano akceptację wymiany');
}

window.inventory_hideTrading = () => {
    document.querySelector('#inventory #trade-wrapper').classList.add('d-none');
    window.inventory_isTrading = false;
    inventory_hideOptions();
    inventory_toggleTradeCategory(true);
}

function updateAcceptedUsers([a, b]) {
    document.querySelector('#inventory #trade-1').parentElement.querySelector('.status').classList.toggle('active', a);
    document.querySelector('#inventory #trade-2').parentElement.querySelector('.status').classList.toggle('active', b);
    document.querySelector('#inventory #accept-button').innerText = a ? 'Cofnij' : 'Zatwierdź';
    window.inventory_meAccepted = a;
}

function updateTradeAccepted() {
    let timer = document.querySelector('#inventory #accepted-timer');
    timer.classList.toggle('d-none', !inventory_tradeAccepted);

    // inventory_tradeAccepted is date timestamp, calculate time left
    let secondsLeft = Math.floor(((inventory_tradeAccepted + 15) - Date.now() / 1000));
    if (secondsLeft < 0) {
        inventory_tradeAccepted = false;
        inventory_updateTrade();
        return;
    }

    timer.innerText = `Finalizacja za ${secondsLeft} sekund...`;
    setTimer('inventory', updateTradeAccepted, 1000);
}

addEvent('inventory', 'interface:data:tradeItems', (data) => {
    data = data[0];

    // let yourOffer = Object.keys(data.myOffer).map((item) => {
    //     if (data.myOffer[item] == 0) return
    //     return {
    //         item: item,
    //         amount: data.myOffer[item]
    //     }
    // });

    // let theirOffer = Object.keys(data.theirOffer).map((item) => {
    //     if (data.theirOffer[item] == 0) return
    //     return {
    //         item: item,
    //         amount: data.theirOffer[item]
    //     }
    // });

    // {
    //     "myOffer": {
    //         "KvEeTLMQXjJ14MTc": {
    //             "metadata": {
    //                 "progress": 0,
    //                 "equipped": false
    //             },
    //             "item": "m4",
    //             "amount": 1
    //         }
    //     },
    //     "theirOffer": [],
    //     "accepted": false,
    //     "acceptedUsers": [
    //         false,
    //         false
    //     ]
    // }

    let yourOffer = Object.keys(data.myOffer).map((item) => {
        let itemData = data.myOffer[item];
        return {
            item: itemData.item,
            amount: itemData.amount,
            metadata: itemData.metadata,
            hash: item
        }
    });

    let theirOffer = Object.keys(data.theirOffer).map((item) => {
        let itemData = data.theirOffer[item];
        return {
            item: itemData.item,
            amount: itemData.amount,
            metadata: itemData.metadata,
            hash: item
        }
    });

    inventory_tradeAccepted = data.accepted;
    inventory_yourOffer = yourOffer;
    inventory_theirOffer = theirOffer;

    inventory_updateTrade();
    updateTradeAccepted();
    updateAcceptedUsers(data.acceptedUsers);
});