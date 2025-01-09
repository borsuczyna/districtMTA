permissions = {
    {name = 'manageFaction', label = 'Administrator (wszystkie uprawnienia)'},
    {name = 'panel', label = 'Dostęp do panelu'},
    {name = 'mainPage', label = 'Dostęp do strony głównej panelu'},

    {name = 'manageMembers', label = 'Dostęp do zakładki członkowie'},
    {name = 'addMember', label = 'Dodawanie członków'},
    {name = 'removeMember', label = 'Usuwanie członków'},
    {name = 'editMember', label = 'Edycja członków'},

    {name = 'manageRanks', label = 'Dostęp do zakładki rangi'},
    {name = 'addRank', label = 'Dodawanie rang'},
    {name = 'removeRank', label = 'Usuwanie rang'},
    {name = 'editRank', label = 'Edycja rang'},

    {name = 'duty', label = 'Wejście na służbę'},
    {name = 'gate', label = 'Otwieranie drzwi/bram'},

    {name = 'shelf', label = 'Dostęp do szafki'},
    {name = 'virtualParking', label = 'Dostęp do wirtualnego parkingu'},
    {name = 'defaultEquipment', label = 'Dostęp do domyślnego ekwipunku'},
    {name = 'midEquipment', label = 'Dostęp do średniego ekwipunku'},
    {name = 'highEquipment', label = 'Dostęp do wysokiego ekwipunku'},
}

payPerMinute = 6200 -- 1$ = 100

function table.find(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end