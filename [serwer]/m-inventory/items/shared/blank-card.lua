function createBlankCardItem()
    return {
        title = 'Biała karta PCV',
        description = 'Tajemnicza karta, która otwiera drzwi do nieznanych przygód. Użyj jej ostrożnie, bo może zaskoczyć Cię nieoczekiwanym wynikiem.',
        category = 'weapon',
        icon = '/m-inventory/data/icons/blank-card.png',
        rarity = 'common',
        onUse = onBlankCardUse
    }
end