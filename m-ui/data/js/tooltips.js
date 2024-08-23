function updateMapTooltips(event) {
    let tooltip = document.getElementById('__tooltip');

    // get items that have tooltips
    let items = document.querySelectorAll('[data-tooltip]');
    if (!items.length) {
        tooltip.style.opacity = 0;
        return;
    }

    // find which item is hovered
    let hoveredItem = null;
    for (let i = 0; i < items.length; i++) {
        let item = items[i];
        if (item.matches(':hover')) {
            hoveredItem = item;
            break;
        }
    }

    // if no item is hovered, hide tooltip
    if (!hoveredItem) {
        tooltip.style.opacity = 0;
        return;
    }

    // get item position
    let itemRect = hoveredItem.getBoundingClientRect();
    let itemX = itemRect.left + itemRect.width / 2;
    let itemY = `calc(${itemRect.top}px - 0.5rem)`;

    // set tooltip text
    tooltip.innerHTML = hoveredItem.dataset.tooltip;
    tooltip.style.opacity = 1;
    tooltip.style.left = `${itemX}px`;
    tooltip.style.top = itemY;
}


addEvent('ui', 'mousemove', updateMapTooltips);