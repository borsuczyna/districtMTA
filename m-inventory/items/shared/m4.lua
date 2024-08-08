function createM4Item()
    return {
        title = 'M4',
        description = 'Karabin szturmowy, który jest używany przez wiele jednostek specjalnych na całym świecie',
        category = 'weapon',
        icon = '/m-inventory/data/icons/m4.png',
        rarity = 'divine',
        onUse = onM4Use,

        metadata = {
            ammo = 30,
        },

        render = [[{description}<br><br>
            <div class="label">Amunicja: 30</div>
        ]],
    }
end