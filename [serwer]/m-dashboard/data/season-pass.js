let seasonPassData = null;
let loadedQrCode = false;
let star = `
<svg width="50" height="48" viewBox="0 0 50 48" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M48.8568 21.7299C49.8398 20.7719 50.1868 19.3659 49.7628 18.0589C49.3378 16.7519 48.2308 15.8189 46.8708 15.6209L34.7788 13.8639C34.2638 13.7889 33.8188 13.4659 33.5888 12.9989L28.1828 2.04287C27.5758 0.811875 26.3438 0.046875 24.9708 0.046875C23.5988 0.046875 22.3668 0.811875 21.7598 2.04287L16.3528 12.9999C16.1228 13.4669 15.6768 13.7899 15.1618 13.8649L3.06979 15.6219C1.71079 15.8189 0.602793 16.7529 0.177792 18.0599C-0.246208 19.3669 0.100792 20.7729 1.08379 21.7309L9.83279 30.2589C10.2058 30.6229 10.3768 31.1469 10.2888 31.6589L8.22479 43.7009C8.04179 44.7609 8.31979 45.7919 9.00579 46.6049C10.0718 47.8719 11.9328 48.2579 13.4208 47.4759L24.2348 41.7899C24.6868 41.5529 25.2558 41.5549 25.7068 41.7899L36.5218 47.4759C37.0478 47.7529 37.6088 47.8929 38.1878 47.8929C39.2448 47.8929 40.2468 47.4229 40.9358 46.6049C41.6228 45.7919 41.8998 44.7589 41.7168 43.7009L39.6518 31.6589C39.5638 31.1459 39.7348 30.6229 40.1078 30.2589L48.8568 21.7299Z" fill="currentColor" />
</svg>`;

seasonPass_fetchPaymentUrl = async () => {
    let data = await mta.fetch('dashboard', 'fetchPaymentUrl');
    
    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        if (data.status == 'success') {
            // let qrCode = document.createElement('img');
            // // base64
            // qrCode.src = `data:image/png;base64,${data.qr}`;
            // qrCode.alt = 'Kod QR';
            // qrCode.style.width = '200px';
            // qrCode.style.height = '200px';
            // qrCode.style.position = 'absolute';
            // qrCode.style.top = '50%';
            // qrCode.style.left = '50%';
            // qrCode.style.transform = 'translate(-50%, -50%)';
            // qrCode.style.zIndex = '9999';

            // document.body.appendChild(qrCode);
            document.querySelector('#dashboard #pass-qr').src = `data:image/png;base64,${data.qr}`;
            document.querySelector('#dashboard #pass-qr').classList.remove('d-none');
            document.querySelector('#dashboard #pass-loading').classList.add('d-none');
        } else {
            notis_addNotification('error', 'Błąd', data.message);
        }
    }
}

seasonPass_clickItem = (button) => {
    if (!button.parentElement.parentElement.classList.contains('active')) return;
    // if (button.classList.contains('locked')) return;

    button.parentElement.querySelectorAll('.season-pass-card').forEach((card) => {
        card.classList.remove('active');
    });

    button.classList.add('active');
    seasonPass_renderItemInfo();
}

seasonPass_loadData = (data) => {
    seasonPassData = data;
    
    let currentPage = document.querySelector('#dashboard #season-pass .page.active');
    let currentPageIndex = currentPage != null ? currentPage.dataset.index : 0;
    let currentActive = currentPage != null ? currentPage.querySelector('.season-pass-card.active') : null;
    let currentActiveIndex = currentActive != null ? currentActive.dataset.index : 0;

    let seasonPassView = document.querySelector('#dashboard #season-pass');
    let html = `
        <div class="d-flex flex-column justify-start gap-1" style="line-height: 1.7rem;">
            <span style="font-size: 1.4rem; font-weight: 700;" class="slant">SEZON ${data.season} - ${data.seasonName.toUpperCase()}</span>
            <span style="font-size: 2.8rem; font-weight: 900;" class="slant">PRZEPUSTKA SEZONOWA</span>
        </div>
    `;

    let previousPageRedeemed = true;
    
    for (let [index, page] of data.pages.entries()) {
        let redeemed = page.filter((item) => item.redeemed).length;
        let total = page.length;
        let className = index < currentPageIndex ? 'prev' : index > currentPageIndex ? 'next' : 'active';
        let pageLocked = !previousPageRedeemed;

        html += `
            <div class="page ${className} ${pageLocked ? 'locked' : ''}" data-index="${index}">
                <div class="d-flex gap-2 align-items-end">
                    <span style="line-height: 1rem; font-size: 1.4rem; font-weight: 700;" class="slant">STRONA ${index + 1}</span>
                    <span style="line-height: 1rem; font-size: 1rem; font-weight: 700;" class="slant">ODEBRANO ${redeemed}/${total}</span>
                    ${pageLocked ? '<span style="line-height: 1rem; font-size: 1rem; font-weight: 700;" class="slant">ZABLOKOWANA</span>' : ''}
                </div>

                <div class="page-grid mt-2">
        `;

        // for (let item of page) {
        for (let [index, item] of page.entries()) {
            let size = 'small';
            if (item.size[0] == 2 && item.size[1] == 2) size = 'big';
            if (item.size[0] == 2 && item.size[1] == 1) size = 'mid';
            if (item.size[0] == 3 && item.size[1] == 2) size = 'big';
            let locked = false;
            let active = currentActiveIndex == index;

            if ((!data.bought && !item.free && !item.redeemed) || pageLocked) {
                locked = true;
            }

            html += `
                <div class="season-pass-card card-bg-${size} ${locked ? 'locked' : ''} ${active ? 'active' : ''}" onclick="seasonPass_clickItem(this)" style="grid-column: span ${item.size[0]}; grid-row: span ${item.size[1]};" data-index="${index}">
                    <img src="/m-dashboard/season-pass/data/${item.image}" alt="${item.name}" class="season-pass-image">
                    <div class="owned">
                        ${item.redeemed ? '<span style="font-size: 0.8rem;">POSIADANE</span>' : `
                            ${star} ${item.stars}
                        `}
                    </div>
                </div>
            `;
        }

        html += `
                </div>
            </div>
        `;

        previousPageRedeemed = redeemed == total;
    }

    html += `
        <div id="season-stars">
            <div class="d-flex flex-column">
                <div class="d-flex gap-2 align-items-center justify-end">
                    ${data.stars} ${star}
                </div>
                <div class="d-flex gap-1 align-items-center justify-end">
                    ${data.dists}
                    <img src="/m-dashboard/season-pass/data/4.png" alt="Waluta" style="width: 2.5rem; height: 2.5rem;">
                </div>
            </div>
        </div>

        <div id="season-info">
            Gwiazdki sezonowe możesz zdobyć wykonując misje.<br>
            Przedmioty z przepustki sezonowej możesz odbierać tylko w trakcie trwania sezonu.<br>
            Po zakończeniu sezonu przedmioty nie będą już nigdy dostępne.
        </div>

        <div id="prev-page" class="pagination d-flex justify-center align-items-center mt-2">
            <div class="btn btn-primary" onclick="seasonPass_prevPage()">POPRZEDNIA STRONA</div>
        </div>
        <div id="next-page" class="pagination d-flex justify-center align-items-center mt-2">
            <div class="btn btn-primary" onclick="seasonPass_nextPage()">NASTĘPNA STRONA</div>
        </div>

        <div id="active-season-item"></div>
    `;

    seasonPassView.innerHTML = html;
    seasonPass_renderItemInfo();
    seasonPass_updatePageButtons();
}

seasonPass_renderItemInfo = () => {
    let activePage = document.querySelector('#dashboard #season-pass .page.active');
    let activeItem = activePage.querySelector('.season-pass-card.active');
    if (activeItem == null) {
        activeItem = activePage.querySelector('.season-pass-card:not(.locked)');
        if (activeItem == null) return;

        activeItem.classList.add('active');
    }

    let previousPageData = seasonPassData.pages[activePage.dataset.index - 1];
    let previousPageRedeemed = previousPageData ? previousPageData.filter((item) => item.redeemed).length == previousPageData.length : true;

    let item = seasonPassData.pages[activePage.dataset.index][activeItem.dataset.index];
    let itemInfo = document.querySelector('#dashboard #season-pass #active-season-item');
    let isFree = item.free;
    let canRedeem = !item.redeemed && (isFree || seasonPassData.bought);
    let redeemed = item.redeemed;
    let onClick = canRedeem ? `seasonPass_redeemItem(this, ${activePage.dataset.index}, ${activeItem.dataset.index})` : !redeemed ? 'seasonPass_getPass()' : '';
    let redeemButtonText = redeemed ? 'ODEBRANO' : canRedeem ? 'ODBIERZ' : 'ZDOBĄDŹ PRZEPUSTKĘ';

    if (!previousPageRedeemed) {
        onClick = '';
        redeemButtonText = 'ZABLOKOWANE';
    }

    let html = `
        <img src="/m-dashboard/season-pass/data/${item.image}" alt="${item.name}" class="season-pass-image">
        <div id="active-season-item-info">
            <div class="d-flex gap-1 align-items-center justify-end">
                ${isFree ? '<div class="item-tag">DARMOWE</div>' : ''}
                <div class="item-tag">${item.rarity.toUpperCase()}</div>
            </div>
            <div class="item-name">${item.name}</div>
            <div onclick="${onClick}" class="redeem-button ${!canRedeem ? 'get-pass' : ''} ${!previousPageRedeemed ? 'blue-button' : ''}">${redeemButtonText}</div>
        </div>
    `;

    itemInfo.innerHTML = html;
}

seasonPass_getPass = () => {
    if (!loadedQrCode) {
        seasonPass_fetchPaymentUrl();
        loadedQrCode = true;
    }
    document.querySelector('#dashboard #buy-pass').classList.remove('d-none');
}

seasonPass_closeBuyPass = () => {
    document.querySelector('#dashboard #buy-pass').classList.add('d-none');
}

seasonPass_buyPassForDists = async (button) => {
    if (isButtonSpinner(button)) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('dashboard', 'buySeasonPass');

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    }
    
    makeButtonSpinner(button, false);
}

seasonPass_usePromoCode = async (button) => {
    if (isButtonSpinner(button)) return;

    let promoCode = document.querySelector('#dashboard #promo-code').value;
    if (promoCode == '') {
        notis_addNotification('error', 'Błąd', 'Wprowadź kod promocyjny');
        return;
    }

    makeButtonSpinner(button);
    let data = await mta.fetch('dashboard', 'useSeasonPassPromoCode', [promoCode]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    }

    makeButtonSpinner(button, false);
}

seasonPass_redeemItem = async (button, page, index) => {
    if (isButtonSpinner(button)) return;

    makeButtonSpinner(button);
    let data = await mta.fetch('dashboard', 'redeemSeasonItem', [page, index]);

    if (data == null) {
        notis_addNotification('error', 'Błąd', 'Połączenie przekroczyło czas oczekiwania');
    } else {
        notis_addNotification(data.status, data.status == 'success' ? 'Sukces' : 'Błąd', data.message);
    
        if (data.status == 'success') {
            seasonPass_loadData(data.data);
        }
    }
    
    makeButtonSpinner(button, false);
}

seasonPass_getData = async () => {
    let data = await mta.fetch('dashboard', 'fetchSeasonPassData');

    if (data != null) {
        if (data.status == 'success') {
            seasonPass_loadData(data.data);
        } else {
            notis_addNotification('error', 'Błąd', data.message);
        }
    }
}

seasonPass_updatePageButtons = () => {
    let allPages = document.querySelectorAll('#dashboard #season-pass .page');
    let activePageIndex = Array.from(allPages).findIndex((page) => page.classList.contains('active'));
    let prevPage = allPages[activePageIndex - 1];
    let nextPage = allPages[activePageIndex + 1];

    document.querySelector('#dashboard #season-pass #prev-page').classList.toggle('d-none', prevPage == null);
    document.querySelector('#dashboard #season-pass #next-page').classList.toggle('d-none', nextPage == null);
    seasonPass_renderItemInfo();
}

seasonPass_updateActiveItem = () => {
    let currentPage = document.querySelector('#dashboard #season-pass .page.active');
    let activeItem = currentPage.querySelector('.season-pass-card.active');
    if (!activeItem || activeItem.classList.contains('locked')) {
        if (activeItem != null) {
            activeItem.classList.remove('active');
        }
        
        activeItem = currentPage.querySelector('.season-pass-card:not(.locked)');
        if (activeItem != null) {
            activeItem.classList.add('active');
        }
    }
}

seasonPass_prevPage = () => {
    let activePage = document.querySelector('#dashboard #season-pass .page.active');
    let prevPage = activePage.previousElementSibling;

    let prevPageButton = document.querySelector('#dashboard #season-pass #prev-page');
    if (prevPageButton.classList.contains('d-none')) return;

    activePage.classList.remove('active');
    activePage.classList.add('next');
    prevPage.classList.add('active');
    prevPage.classList.remove('prev');

    seasonPass_updateActiveItem();
    seasonPass_updatePageButtons();
}

seasonPass_nextPage = () => {
    let activePage = document.querySelector('#dashboard #season-pass .page.active');
    let nextPage = activePage.nextElementSibling;

    let nextPageButton = document.querySelector('#dashboard #season-pass #next-page');
    if (nextPageButton.classList.contains('d-none')) return;

    activePage.classList.remove('active');
    activePage.classList.add('prev');
    nextPage.classList.add('active');
    nextPage.classList.remove('next');

    seasonPass_updateActiveItem();
    seasonPass_updatePageButtons();
}

addEvent('dashboard', 'wheel', (event) => {
    if (event.deltaY > 0) {
        seasonPass_nextPage();
    } else {
        seasonPass_prevPage();
    }
});

seasonPass_getData();

addEvent('dashboard', 'bought-season-pass', () => {
    seasonPass_closeBuyPass();
    seasonPass_getData();
});