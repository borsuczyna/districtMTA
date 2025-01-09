let settings = [
    {
        type: 'switch',
        name: 'status-rp',
        text: 'Status RP',
    },
    {
        type: 'switch',
        name: 'block-dms',
        text: 'Zablokuj prywatne wiadomości',
        input: {
            type: 'text',
            placeholder: 'Powód',
            maxlength: 60
        },
    },
    {
        type: 'switch',
        name: 'block-premium-chat',
        text: 'Wyłącz czat premium',
    },
    {
        type: 'switch',
        name: 'hide-hud',
        text: 'Ukryj HUD'
    },
    // {
    //     type: 'switch',
    //     name: 'controller-mode',
    //     text: 'Tryb przeskakiwania kontrolera',
    //     norender: true
    // },
    {
        type: 'switch',
        name: 'hide-nametags',
        text: 'Ukryj nametagi'
    },
    {
        type: 'range',
        name: 'interface-blur',
        text: 'Jakość rozmycia interfejsu',
        min: 0,
        max: 0.4,
        step: 0.05,
    },
    {
        type: 'range',
        name: 'interface-size',
        text: 'Rozmiar interfejsu',
        min: 8,
        max: 22,
        step: 1,
    },
];

function renderSettings() {
    let rows = document.querySelector('#dashboard #settings #settings-rows');
    let ranges = [];
    rows.innerHTML = '';

    settings.forEach(setting => {
        switch (setting.type) {
            case 'switch':
                if (!setting.norender) {
                    rows.innerHTML += `
                        <div data-setting="${setting.name}">
                            <div class="switch-box" id="${setting.name}" onclick="dashboard_switchSetting(this)" tabindex="0" onkeydown="if (event.key === 'Enter' || event.key === ' ') dashboard_switchSetting(this)">
                                <div class="switch">
                                    <div class="inner"></div>
                                </div>
                                <div class="label">
                                    ${setting.text}
                                </div>
                            </div>
                            ${setting.input ? `<input type="${setting.input.type}" class="input mt-2 mb-2 d-none" id="reason" placeholder="${setting.input.placeholder}" maxlength="${setting.input.maxlength}" onchange="dashboard_sendSetting('${setting.name}')"/>` : ''}
                        </div>
                    `;
                }
                break;
            case 'range':
                rows.innerHTML += `
                    <div data-setting="${setting.name}">
                        <div class="label">
                            ${setting.text}
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <div class="range-container mt-1">
                                <span class="text-muted">${setting.min}</span>
                                <div min="${setting.min}" max="${setting.max}" step="${setting.step}" data-value="${setting.min}" id="range-${setting.name}" onchange="dashboard_sendSetting('${setting.name}')"></div>
                                <span class="text-muted">${setting.max}</span>
                            </div>
                        </div>
                    </div>
                `;
                ranges.push(`#dashboard #range-${setting.name}`);
                break;
        }

        for (let range of ranges) {
            createRangeInput(document.querySelector(range));
        }
    });
}

window.dashboard_switchSetting = function(item) {
    let setting = item.parentElement.getAttribute('data-setting');
    let settingData = settings.find(s => s.name === setting);
    item.classList.toggle('switched');

    if (settingData.input) {
        item.nextElementSibling.classList.toggle('d-none', !item.classList.contains('switched'));
    }

    dashboard_sendSetting(setting);
}

window.dashboard_setSetting = function(setting, value) {
    let settingData = settings.find(s => s.name === setting);
    let item = document.querySelector(`#dashboard [data-setting="${setting}"] .switch-box`);

    if (settingData.type === 'switch') {
        item.classList.toggle('switched', value.value);
        
        if (settingData.input) {
            item.nextElementSibling.classList.toggle('d-none', !value.value);
            item.nextElementSibling.value = value.input;
        }
    } else if (settingData.type === 'range') {
        let range = document.querySelector(`#dashboard #range-${setting}`);
        setRangeInput(range, value.value);
    }
}

window.dashboard_sendSetting = function(setting) {
    let settingData = settings.find(s => s.name === setting);

    if (settingData.type === 'switch') {
        let item = document.querySelector(`#dashboard [data-setting="${setting}"] .switch-box`);
        let switched = item.classList.contains('switched');
        let input = item.nextElementSibling;

        if (input) {
            mta.triggerEvent('dashboard:setSetting', setting, switched, input.value);
        } else {
            mta.triggerEvent('dashboard:setSetting', setting, switched);
        }

        if (setting == 'controller-mode') {
            setCurrentControllerMode(switched);
        }
    } else if (settingData.type === 'range') {
        let range = document.querySelector(`#dashboard #range-${setting}`);
        let value = range?.dataset.value;

        mta.triggerEvent('dashboard:setSetting', setting, value);

        if (setting == 'interface-size') {
            setRemSize(parseInt(value));
            stopHoldingRangeInput();
        }
    }
}

renderSettings();