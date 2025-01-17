let iconsList = {
    'trash': `<svg style="width: 0.8rem !important; height: 0.8rem !important;" viewBox="0 0 24 24" version="1.1">
        <g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
            <rect x="0" y="0" width="24" height="24"/>
            <path d="M6,8 L18,8 L17.106535,19.6150447 C17.04642,20.3965405 16.3947578,21 15.6109533,21 L8.38904671,21 C7.60524225,21 6.95358004,20.3965405 6.89346498,19.6150447 L6,8 Z M8,10 L8.45438229,14.0894406 L15.5517885,14.0339036 L16,10 L8,10 Z" fill="currentColor" fill-rule="nonzero"/>
            <path d="M14,4.5 L14,3.5 C14,3.22385763 13.7761424,3 13.5,3 L10.5,3 C10.2238576,3 10,3.22385763 10,3.5 L10,4.5 L5.5,4.5 C5.22385763,4.5 5,4.72385763 5,5 L5,5.5 C5,5.77614237 5.22385763,6 5.5,6 L18.5,6 C18.7761424,6 19,5.77614237 19,5.5 L19,5 C19,4.72385763 18.7761424,4.5 18.5,4.5 L14,4.5 Z" fill="currentColor" opacity="0.3"/>
        </g>
    </svg>`,
    'teleport': `<svg style="width: 0.8rem !important; height: 0.8rem !important;" viewBox="0 0 24 24" version="1.1">
        <path d="M11.7308 0C10.7503 0.124441 9.85738 1.21008 9.78297 2.64757V2.65187C9.78297 2.71194 9.77859 2.77202 9.77859 2.83638C9.77859 3.67742 10.0762 4.42407 10.514 4.93899L11.0436 5.56548L10.2251 5.71567C9.66041 5.82295 9.24895 6.11474 8.8944 6.59104C8.77184 6.7541 8.66241 6.93862 8.56174 7.1403C5.53711 6.8056 3.41857 6.05466 3.41857 5.18358C3.41857 4.29104 5.65968 3.53582 8.81561 3.22687C8.80248 3.09813 8.7981 2.9694 8.7981 2.83638C8.7981 2.79347 8.7981 2.75056 8.80248 2.70765C3.73372 3.05522 0.0131318 4.20952 0.0131318 5.57407C0.0131318 6.87854 3.40106 7.98993 8.10651 8.38899C8.09776 8.42761 8.08463 8.46623 8.07587 8.50485C7.95331 9.0069 7.86139 9.54757 7.80011 10.1011C7.80011 10.1011 7.80011 10.1011 7.79573 10.1011C7.77385 10.2899 7.75634 10.4787 7.73883 10.6718H7.74321C7.67317 11.4828 7.65129 12.311 7.64253 13.0877H9.52909L9.63852 14.5509C6.05362 14.2935 3.41857 13.4696 3.41857 12.4998C3.41857 11.8175 4.72296 11.2168 6.74084 10.8349C6.75834 10.6246 6.77585 10.4144 6.79774 10.2084C2.78388 10.689 0.0131318 11.7103 0.0131318 12.8903C0.0131318 14.3407 4.20208 15.5507 9.73482 15.8125L10.0456 19.919C10.5971 20.0563 11.3544 20.1336 12.0985 20.1293C12.8207 20.125 13.5298 20.0435 14.0113 19.9233L14.2871 15.8125C19.8198 15.5465 24 14.3407 24 12.8903C24 11.706 21.2074 10.6804 17.1672 10.2041C17.1848 10.4101 17.1979 10.616 17.2066 10.822C19.2508 11.2082 20.5683 11.809 20.5683 12.4998C20.5683 13.4696 17.9508 14.2935 14.3746 14.5509L14.4709 13.0877H16.2655C16.2655 12.311 16.2612 11.4785 16.213 10.6632C16.2043 10.4744 16.1911 10.2856 16.1736 10.0968C16.1211 9.52183 16.0467 8.96399 15.9329 8.45336C15.9285 8.4319 15.9241 8.41045 15.9198 8.38899C20.6208 7.98563 24 6.87854 24 5.57407C24 4.19664 20.2181 3.03377 15.0837 2.69907C15.0881 2.74198 15.0881 2.78918 15.0881 2.83638C15.0881 2.96511 15.0837 3.08955 15.0706 3.21828C18.2878 3.51866 20.5683 4.27817 20.5683 5.18358C20.5683 6.05037 18.4848 6.79702 15.4952 7.13172C15.3901 6.91287 15.2719 6.71549 15.1406 6.53955C14.7817 6.06754 14.3484 5.78004 13.7137 5.68134L12.8776 5.55261L13.4073 4.90466C13.7706 4.4584 14.0332 3.84049 14.0945 3.14104C14.1032 3.04235 14.1076 2.93937 14.1076 2.83638C14.1076 2.79776 14.1032 2.75485 14.1032 2.71623C14.1032 2.69478 14.1032 2.66903 14.0989 2.64328C14.0244 1.11138 13.0221 0.00429078 11.9409 0.00429078C11.8096 0.00429078 11.7352 0 11.7308 0ZM8.85063 17.1513C3.75123 17.4946 0 18.6489 0 20.022C0 21.6698 5.37078 23 11.9934 23C18.6161 23 23.9869 21.6698 23.9869 20.022C23.9869 18.6532 20.2575 17.4989 15.18 17.1556L15.145 17.6662C18.3184 17.9752 20.5595 18.7433 20.5595 19.6444C20.5595 20.8159 16.7252 21.7685 11.9934 21.7685C7.26172 21.7685 3.42732 20.8159 3.42732 19.6444C3.42732 18.739 5.69469 17.9709 8.89002 17.6619L8.85063 17.1513Z" fill="white" opacity="0.8" />
    </svg>`,
}

window.adminLogs_addLog = (category, text, icons) => {
    let rows = document.querySelector('#admin-logs .rows');
    const atBottom = rows.scrollHeight - rows.scrollTop >= rows.clientHeight - 1;

    const row = document.createElement('div');
    const span = document.createElement('span');
    const iconsDom = document.createElement('span');
    iconsDom.classList.add('icons');
    span.innerHTML = applyHexColor(htmlEscape(text));

    if (icons) {
        icons.forEach((icon) => {
            let iconDom = document.createElement('span');
            iconDom.innerHTML = iconsList[icon[0]];
            iconDom.classList.add('icon');
            iconDom.onclick = () => {
                mta.triggerEvent('logs:iconClick', ...icon.slice(1));
            }
            iconsDom.appendChild(iconDom);
        });
    }

    row.appendChild(span);
    row.appendChild(iconsDom);
    row.dataset.category = category;
    let currentCategory = document.querySelector('#admin-logs .category.active').dataset.category;
    if (currentCategory !== 'wszystko' && category !== currentCategory) {
        row.classList.add('d-none');
    }

    rows.appendChild(row);

    if (atBottom) {
        rows.scrollTop = rows.scrollHeight;
    }
}

window.adminLogs_setCategory = (category) => {
    document.querySelectorAll('#admin-logs .category').forEach((el) => {
        el.classList.remove('active');
    });
    category.classList.add('active');

    document.querySelectorAll('#admin-logs .rows div').forEach((el) => {
        el.classList.toggle('d-none', category.dataset.category !== 'wszystko' && el.dataset.category !== category.dataset.category);
    });

    document.querySelector('#admin-logs .rows').scrollTop = document.querySelector('#admin-logs .rows').scrollHeight;
}

addEvent('admin-logs', 'mousedown', (e) => {
    if (e?.target?.classList.contains('top') && e?.target?.closest('#admin-logs')) {
        let dom = e.target.parentElement.getBoundingClientRect();
        e.target.parentElement.dataset.dragging = true;
        e.target.parentElement.dataset.draggingX = e.clientX - dom.x;
        e.target.parentElement.dataset.draggingY = e.clientY - dom.y;
    }
});

addEvent('admin-logs', 'mouseup', (e) => {
    if (e?.target?.classList.contains('top') && e?.target?.closest('#admin-logs')) {
        e.target.parentElement.dataset.dragging = false;
    }
});

addEvent('admin-logs', 'mousemove', (e) => {
    let window = document.querySelector('#admin-logs .window');
    if (window.dataset.dragging === 'true') {
        window.style.left = e.clientX - window.dataset.draggingX + 'px';
        window.style.top = e.clientY - window.dataset.draggingY + 'px';
    }
});

addEvent('admin-logs', 'interface:data:addLog', async (data) => {
    data = data[0];
    adminLogs_addLog(data.category, data.message, data.icons);
});

adminLogs_addLog('wszystko', 'Załadowano logi serwerowe');