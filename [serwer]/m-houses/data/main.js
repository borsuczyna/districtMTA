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
    calendar: `<svg viewBox="0 0 512 512" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M160.001 53.3333C160.001 41.5513 150.449 32 138.667 32C126.885 32 117.334 41.5513 117.334 53.3333V74.6667C117.334 86.4487 126.885 96 138.667 96C150.449 96 160.001 86.4487 160.001 74.6667V53.3333Z" fill="currentColor" />
        <path d="M394.667 53.3333C394.667 41.5513 385.115 32 373.333 32C361.551 32 352 41.5513 352 53.3333V74.6667C352 86.4487 361.551 96 373.333 96C385.115 96 394.667 86.4487 394.667 74.6667V53.3333Z" fill="currentColor" />
        <path d="M42.666 192V437.333C42.666 460.896 61.77 480 85.3327 480H426.666C450.229 480 469.333 460.896 469.333 437.333V192H42.666ZM170.666 405.333C170.666 417.12 161.119 426.667 149.333 426.667H127.999C116.213 426.667 106.666 417.12 106.666 405.333V384C106.666 372.213 116.213 362.667 127.999 362.667H149.333C161.119 362.667 170.666 372.213 170.666 384V405.333ZM170.666 288C170.666 299.787 161.119 309.333 149.333 309.333H127.999C116.213 309.333 106.666 299.787 106.666 288V266.667C106.666 254.88 116.213 245.333 127.999 245.333H149.333C161.119 245.333 170.666 254.88 170.666 266.667V288ZM287.999 405.333C287.999 417.12 278.453 426.667 266.666 426.667H245.333C233.546 426.667 223.999 417.12 223.999 405.333V384C223.999 372.213 233.546 362.667 245.333 362.667H266.666C278.453 362.667 287.999 372.213 287.999 384V405.333ZM287.999 288C287.999 299.787 278.453 309.333 266.666 309.333H245.333C233.546 309.333 223.999 299.787 223.999 288V266.667C223.999 254.88 233.546 245.333 245.333 245.333H266.666C278.453 245.333 287.999 254.88 287.999 266.667V288ZM405.333 405.333C405.333 417.12 395.786 426.667 383.999 426.667H362.666C350.879 426.667 341.333 417.12 341.333 405.333V384C341.333 372.213 350.879 362.667 362.666 362.667H383.999C395.786 362.667 405.333 372.213 405.333 384V405.333ZM405.333 288C405.333 299.787 395.786 309.333 383.999 309.333H362.666C350.879 309.333 341.333 299.787 341.333 288V266.667C341.333 254.88 350.879 245.333 362.666 245.333H383.999C395.786 245.333 405.333 254.88 405.333 266.667V288Z" fill="currentColor" />
        <path d="M469.333 170.667V106.667C469.333 83.104 450.229 64 426.666 64H415.999V74.6667C415.999 98.1973 396.863 117.333 373.333 117.333C349.802 117.333 330.666 98.1973 330.666 74.6667V64H181.333V74.6667C181.333 98.1973 162.197 117.333 138.666 117.333C115.135 117.333 95.9994 98.1973 95.9994 74.6667V64H85.3327C61.77 64 42.666 83.104 42.666 106.667V170.667H469.333Z" fill="currentColor" />
    </svg>`,
    exit: `<svg width="683" height="683" viewBox="0 0 683 683" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
        <path d="M426.662 369.781C410.933 369.781 398.22 382.526 398.22 398.223V512.003C398.22 527.675 385.475 540.446 369.772 540.446H284.44V113.784C284.44 89.4922 268.966 67.7893 245.701 59.7113L237.279 56.8936H369.772C385.475 56.8936 398.22 69.6643 398.22 85.3412V170.674C398.22 186.371 410.933 199.116 426.662 199.116C442.391 199.116 455.105 186.371 455.105 170.674V85.3412C455.105 38.2948 416.819 0.00878906 369.772 0.00878906H63.9993C62.916 0.00878906 62.0098 0.49316 60.9577 0.633782C59.5879 0.519201 58.2806 0.00878906 56.89 0.00878906C25.5154 0.00878906 0 25.5189 0 56.8936V568.888C0 593.18 15.4738 614.883 38.7392 622.961L209.92 680.023C215.722 681.814 221.492 682.668 227.555 682.668C258.93 682.668 284.44 657.153 284.44 625.778V597.336H369.772C416.819 597.336 455.105 559.05 455.105 512.003V398.223C455.105 382.526 442.391 369.781 426.662 369.781Z" fill="currentColor" />
        <path d="M674.326 264.339L560.546 150.565C552.415 142.429 540.181 139.981 529.546 144.388C518.937 148.799 511.994 159.179 511.994 170.674V256.006H398.219C382.516 256.006 369.771 268.746 369.771 284.449C369.771 300.151 382.516 312.891 398.219 312.891H511.994V398.223C511.994 409.718 518.937 420.098 529.546 424.51C540.181 428.916 552.415 426.468 560.546 418.338L674.326 304.558C685.445 293.438 685.445 275.459 674.326 264.339Z" fill="currentColor" />
    </svg>`,
    furniture: `<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" data-name="glyph">
        <path d="m59.91513 27.79185a5.80619 5.80619 0 0 0 -5.531-4.79087c-3.62066-.11006-5.471 3.13053-5.9411 4.81089l-2.33045 6.94129c-3.13058-1.22026-9.22166-1.70033-14.15258-1.89037-3.88584.08843-11.88565.82122-14.07258 1.88048l-2.31042-6.8814c-.49008-1.73036-2.36048-4.95093-5.96112-4.86088a5.803 5.803 0 0 0 .29 11.60211l3.86076 10.512a4.17526 4.17526 0 0 0 4.38084 2.66039c8.11155.00118 19.59305-.00073 27.705.00007a4.18157 4.18157 0 0 0 4.38084-2.65056l3.86079-10.5219a5.84646 5.84646 0 0 0 5.82102-6.81125z" fill="currentColor" />
        <path d="m39.2213 49.77589 1.32026 3.62067a2.237 2.237 0 0 0 2.10042 1.4703h1.0102a2.23246 2.23246 0 0 0 2.23039-2.23046v-2.86051c-1.10291-.00123-6.66127 0-6.66127 0z" fill="currentColor" />
        <path d="m18.11743 49.77589v2.86051a2.23246 2.23246 0 0 0 2.23039 2.23046h1.01018a2.21582 2.21582 0 0 0 2.0804-1.46029l1.34028-3.63068c-1.14668-.00056-6.66125 0-6.66125 0z" fill="currentColor" />
        <path d="m17.48731 27.27173 1.6803 4.99092c2.82036-.773 9.29685-1.30375 12.86242-1.40018a66.708 66.708 0 0 1 12.80236 1.41019l1.70032-5.05092c.89095-3.551 5.35776-7.967 10.80207-5.56091-3.64378-11.59237-17.71428-17.24058-26.03513-7.6913a13.48013 13.48013 0 0 1 -3.56047 3.07037c-1.79029 1.40025-5.421.66006-6.59116.29-2.83054-1.19022-5.341-1.3302-7.4614-.41a7.66732 7.66732 0 0 0 -3.93073 4.08076c4.04398-.21149 7.14121 3.76821 7.73142 6.27107z" fill="currentColor" />
    </svg>`,
    paint: `<svg enable-background="new 0 0 66 66" viewBox="0 0 66 66" xmlns="http://www.w3.org/2000/svg" fill="currentColor">
        <path d="m37.01 38.76h-11.88c-1.45 0-2.63 1.18-2.63 2.63s1.18 2.63 2.63 2.63h1.66l-2.03 13.33c-.47 3.79 2.48 7.14 6.3 7.14s6.78-3.35 6.3-7.14l-2.03-13.33h1.66c1.45 0 2.63-1.18 2.63-2.63s-1.15-2.63-2.61-2.63zm-5.94 23.21c-1.92 0-3.48-1.56-3.48-3.48s1.56-3.49 3.48-3.49 3.48 1.56 3.48 3.48-1.56 3.49-3.48 3.49z" />
        <circle cx="31.07" cy="58.49" r="1.48" />
        <path d="m25.73 28.57c.53-.52.86-1.26.86-2.06v-4.7-.65c0-1.64 1.33-2.97 2.97-2.97.82 0 1.57.33 2.1.87s.87 1.28.87 2.1v.65.33c0 1.76 1.42 3.18 3.17 3.18.88 0 1.67-.35 2.25-.94.57-.57.93-1.36.93-2.24v-.33h9.46c1.58 0 2.86-1.28 2.86-2.86v-14.59c0-1.58-1.28-2.86-2.86-2.86h-9.46-28.88c-1.58 0-2.86 1.28-2.86 2.86v14.59l-.02 13.87c0 1.98 1.59 3.57 3.57 3.57h.09c2.05 0 3.69-1.64 3.69-3.67v-10.62c0-.1 0-.19.02-.29.14-1.59 1.48-2.84 3.11-2.84h.01c1.63 0 2.97 1.25 3.11 2.84.02.1.02.19.02.29v4.41c0 1.61 1.31 2.92 2.92 2.92.81 0 1.54-.32 2.07-.86z" />
        <path d="m53.19 9.79v3.83c3.66.42 6.51 3.53 6.51 7.3 0 4.05-3.3 7.35-7.35 7.35h-14.61c-4.7 0-8.53 3.8-8.58 8.49h3.82c.05-2.58 2.16-4.67 4.75-4.67h14.62c6.16 0 11.17-5.01 11.17-11.17.01-5.88-4.56-10.7-10.33-11.13z" />
        <path d="m2.47 11.66c0 1.05.85 1.91 1.91 1.91h.75v-3.82h-.75c-1.05 0-1.91.85-1.91 1.91z" />
    </svg>`,
};
let houseOptions = [
    {
        name: (houseData) => 'Obejrzyj mieszkanie',
        condition: (houseData) => !houseData.isInside && houseData.ownerName == undefined,
        icon: houseIcons.door,
        callback: 'houses_enterHouse'
    },
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
    },
    {
        name: (houseData) => 'Przedłuż wynajem',
        condition: (houseData) => houseData.isYou && houseData.ownerName != undefined,
        icon: houseIcons.calendar,
        callback: 'houses_extendRent'
    },
    {
        name: (houseData) => 'Wyprowadź się',
        condition: (houseData) => houseData.isYou && houseData.ownerName != undefined,
        icon: houseIcons.exit,
        callback: 'houses_cancelRentAsk'
    },
    {
        name: (houseData) => 'Edytuj umebelowanie',
        condition: (houseData) => houseData.isYou && houseData.ownerName != undefined,
        icon: houseIcons.furniture,
        callback: 'houses_furnitureMenu'
    },
    {
        name: (houseData) => 'Edytuj wystrój',
        condition: (houseData) => houseData.isYou && houseData.ownerName != undefined,
        icon: houseIcons.paint,
        callback: 'houses_appearTexturesMenu'
    },
    {
        name: (houseData) => 'Wyrzuć gości',
        condition: (houseData) => houseData.isYou && houseData.ownerName != undefined,
        icon: houseIcons.group,
        callback: 'houses_kickGuests'
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
    document.querySelector('#houses .preview').src = `/m-houses/data/previews/${data.interior[0]}.png`;

    if (data.owner != undefined) {
        document.querySelector('#houses #furnitured').parentElement.style.display = 'none';
        document.querySelector('#houses #owner').innerText = data.ownerName;
        document.querySelector('#houses #rent-to').innerText = new Date(data.rentDate.timestamp * 1000).toLocaleDateString('pl-PL', { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' });
        document.querySelector('#houses #main-button').innerText = (
            data.isInside ? 'Wyjdź' : (data.isYou ? 'Wejdź' :
            ((data.canEnter || !data.locked) ? 'Wejdź' : 'Zadzwoń dzwonkiem'))
        );
    } else {
        document.querySelector('#houses #furnitured').innerText = data.furnitured ? 'Z wyposażeniem' : 'Bez wyposażenia';
        document.querySelector('#houses #owner').parentElement.style.display = 'none';
        document.querySelector('#houses #rent-to').parentElement.style.display = 'none';
        document.querySelector('#houses #main-button').innerText = data.isInside ? 'Wyjdź' : 'Wynajmij';
    }

    houses_renderHouseOptions();
    houses_renderTexturesList(data.interiorData.textureNames, data.textures, data.possibleTextures);

    mapGoToPosition(document.querySelector('#houses #house-map'), data.position[0], data.position[1], 0);
    createMapBlip({
        element: document.querySelector('#houses #house-map'),
        icon: `/m-hud/data/images/blips/${data.owner && 47 || 46}.png`,
        size: 12,
        class: 'blip',
        x: data.position[0],
        y: data.position[1],
        hoverTooltip: data.name,
    });

    for (let shop of data.furnitureShops) {
        createMapBlip({
            element: document.querySelector('#houses #house-map'),
            icon: `/m-hud/data/images/blips/17.png`,
            size: 12,
            class: 'blip',
            x: shop[0],
            y: shop[1],
            hoverTooltip: 'Sklep z meblami',
        });
    }
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
    if (houseData.isInside) {
        houses_enterHouse(button);
    } else if (houseData.ownerName == undefined) {
        houses_openRentHouse();
    } else if (houseData.isYou || houseData.canEnter || !houseData.locked) {
        houses_enterHouse(button);
    } else {
        houses_ringBell();
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
        texture: 'map-dark.png?v1.01',
        background: 'rgba(255, 255, 255, 0.05)',
    });
}

addEvent('houses', 'play-animation', async (appear) => {
    if (!appear) {
        houses_appearRentHouseTime(false);
        houses_appearEditTenants(false);
        houses_appearFurnitureMenu(false);
        houses_appearTexturesMenu(false);
    }

    await new Promise(resolve => setTimeout(resolve, 100));
    document.querySelector('#houses #houses-wrapper').style.opacity = appear ? '1' : '0';
    document.querySelector('#houses #houses-wrapper').style.transform = appear ? 'translate(-50%, -50%) scale(1)' : 'translate(-50%, -50%) scale(1)';
});

addEvent('houses', 'interface:data:houses', (data) => {
    setHouseData(data[0]);
})

loadHouseMap();