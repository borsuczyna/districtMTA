let houseData = false;
let houseIcons = {
    door: `<svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M450.88 53.3599C446.516 48.9969 440.598 46.5459 434.425 46.5459C434.423 46.5459 434.419 46.5459 434.419 46.5459L411.152 46.5539V69.8269V93.0999V418.91V442.183V465.456H434.425C447.278 465.456 457.698 455.036 457.698 442.183V69.8189C457.697 63.6449 455.246 57.7249 450.88 53.3599Z" fill="currentColor" />
        <path d="M356.292 5.44278C351.021 1.02078 344.065 -0.844216 337.289 0.355784L73.5307 46.9288C62.4097 48.8918 54.3027 58.5548 54.3027 69.8468V442.183C54.3027 453.476 62.4107 463.141 73.5317 465.102L337.29 511.647C338.637 511.884 339.988 512.001 341.333 512.001C346.762 512.001 352.07 510.1 356.293 506.557C361.564 502.135 364.606 495.609 364.606 488.729V483.905V465.456V442.183V418.91V93.1118V69.8388V46.5658V23.2728C364.606 16.3938 361.564 9.86678 356.292 5.44278ZM264.703 287.977C260.376 292.307 254.37 294.788 248.243 294.788C242.115 294.788 236.126 292.306 231.781 287.975C227.452 283.634 224.97 277.645 224.97 271.515C224.97 265.387 227.452 259.396 231.781 255.055C236.125 250.725 242.114 248.242 248.243 248.242C254.37 248.242 260.376 250.724 264.703 255.055C269.032 259.398 271.516 265.387 271.516 271.515C271.515 277.646 269.031 283.635 264.703 287.977Z" fill="currentColor" />
    </svg>`,
    group: `<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" data-name="Layer 3" fill="currentColor">
        <circle cx="4" cy="6" r="3" />
        <path d="m7.29 11.07a6.991 6.991 0 0 0 -3.29 5.93h-2a2.006 2.006 0 0 1 -2-2v-2a3.009 3.009 0 0 1 3-3h2a3 3 0 0 1 2.29 1.07z" />
        <circle cx="20" cy="6" r="3" />
        <path d="m24 13v2a2.006 2.006 0 0 1 -2 2h-2a6.991 6.991 0 0 0 -3.29-5.93 3 3 0 0 1 2.29-1.07h2a3.009 3.009 0 0 1 3 3z" />
        <circle cx="12" cy="7" r="4" />
        <path d="m18 17v1a3.009 3.009 0 0 1 -3 3h-6a3.009 3.009 0 0 1 -3-3v-1a5 5 0 0 1 5-5h2a5 5 0 0 1 5 5z" />
    </svg>`,
};
let houseOptions = [
    {
        name: (houseData) => houseData.locked ? 'Otwórz drzwi' : 'Zamknij drzwi',
        condition: (houseData) => houseData.canEnter && houseData.ownerName != undefined,
        icon: houseIcons.door,
        callback: 'houses_toggleDoorLock'
    },
    {
        name: (houseData) => 'Edytuj lokatorów',
        condition: (houseData) => houseData.isYou && houseData.ownerName != undefined,
        icon: houseIcons.group,
        callback: 'houses_editTenants'
    }
];

function formatNumber(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

function getHouseOptions() {
    return houseOptions
        .filter(option => option.condition(houseData))
        .map(option => {
            return {
                name: option.name(houseData),
                icon: option.icon,
                callback: option.callback
            }
        });
}

function setHouseData(data) {
    houseData = data;

    document.querySelector('#houses .title').innerText = data.name;
    document.querySelector('#houses .description').innerText = data.interiorData.description;
    document.querySelector('#houses #cost').innerText = `$${formatNumber(data.price)}`;
    document.querySelector('#houses #street').innerText = data.streetName;
    document.querySelector('#houses #beds').innerText = data.interiorData.bedrooms;
    document.querySelector('#houses #garages').innerText = data.garages;
    
    if (data.owner != undefined) {
        document.querySelector('#houses #furnitured').parentElement.style.display = 'none';
        document.querySelector('#houses #owner').innerText = data.ownerName;
        document.querySelector('#houses #rent-to').innerText = new Date(data.rentDate.timestamp * 1000).toLocaleDateString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' });
        document.querySelector('#houses #main-button').innerText = (
            data.isInside ? 'Wyjdź' : (data.isYou ? 'Wejdź' :
            ((data.canEnter || !data.locked) ? 'Wejdź' : 'Zadzwoń dzwonkiem'))
        );
    } else {
        document.querySelector('#houses #furnitured').innerText = data.interiorData.furnitured ? 'Z wyposażeniem' : 'Bez wyposażenia';
        document.querySelector('#houses #owner').parentElement.style.display = 'none';
        document.querySelector('#houses #rent-to').parentElement.style.display = 'none';
        document.querySelector('#houses #main-button').innerText = 'Wynajmij';
    }

    houses_renderHouseOptions();

    mapGoToPosition(document.querySelector('#houses #house-map'), data.position[0], data.position[1], 0);
    createMapBlip({
        element: document.querySelector('#houses #house-map'),
        icon: '/m-hud/data/images/blips/40.png',
        size: 15,
        class: 'blip',
        x: data.position[0],
        y: data.position[1],
        hoverTooltip: data.name,
    });
}

window.houses_renderHouseOptions = function() {
    let options = getHouseOptions();
    let optionsElement = document.querySelector('#houses #icons');
    optionsElement.parentElement.classList.toggle('d-none', options.length == 0);
    optionsElement.innerHTML = options.map(option => {
        return `
            <div class="icon" data-tooltip="${option.name}" onclick="${option.callback}(this)">
                ${option.icon}
            </div>
        `;
    }).join('');
}

window.houses_useMainButton = function(button) {
    if (houseData.ownerName == undefined) {
        houses_appearRentHouseTime(true);
    } else if (houseData.isInside || houseData.isYou || houseData.canEnter || !houseData.locked) {
        houses_enterHouse(button);
    }
}

window.houses_getHouseData = function() {
    return houseData;
}

window.houses_closeGui = function() {
    mta.triggerEvent('houses:hideInterface');
}

function loadHouseMap() {
    createMap({
        element: document.querySelector('#houses #house-map'),
        minZoom: 1.5,
        zoom: 2.5,
        maxZoom: 4,
        x: 0,
        y: 0,
        limitBounds: true,
        bounds: { x: 400, y: 400 },
        texture: 'map.png?v1.01'
    });
}

addEvent('houses', 'play-animation', async (appear) => {
    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#houses #houses-wrapper').style.opacity = appear ? '1' : '0';
    document.querySelector('#houses #houses-wrapper').style.transform = appear ? 'translate(-50%, -50%) scale(1)' : 'translate(-50%, -50%) scale(1)';
});

addEvent('houses', 'interface:data:houses', (data) => {
    setHouseData(data[0]);
})

// tooltips
// addEvent('houses', 'mousemove', (event) => {
//     let tooltip = document.querySelector('#houses #tooltip');
//     let isOption = event.target.closest('.icon');
//     if (isOption) {
//         tooltip.innerText = isOption.getAttribute('data-houses-tooltip');
//         tooltip.style.opacity = '1';
//         tooltip.style.display = 'block';
//         tooltip.style.left = `${event.clientX + 10}px`;
//         tooltip.style.top = `${event.clientY + 10}px`;
//     } else {
//         tooltip.style.opacity = '0';
        
//     }
// });

loadHouseMap();