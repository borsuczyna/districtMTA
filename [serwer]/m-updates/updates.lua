local updates = {
    {
        date = 1719160364,
        title = 'Wywóz śmieci',
        description = 'Dodano pracę wywozu śmieci znajdującą się w Blueberry. Ta nowa praca pozwala graczom na interakcję z otoczeniem w bardziej realistyczny sposób, zbierając i przetwarzając odpady. Dzięki temu gracze mogą zarabiać pieniądze, jednocześnie dbając o czystość miasta.',
        image = 'data/3.png?v2'
    },
    {
        date = 1719160364,
        title = 'Praca burgerowni',
        description = 'Dodano pracę w burgerowni znajdującej się w Los Santos. Gracze mogą teraz pracować jako kucharze, przygotowując różnorodne posiłki dla klientów, co dodaje nowy wymiar do rozgrywki. Ta praca oferuje również możliwość awansu i zdobywania nowych umiejętności kulinarnych.',
        image = 'data/2.png?v2'
    },
    {
        date = 1719160364,
        title = 'Kolejka linowa',
        description = 'Dodano kolejke linową na górze Galileo. Ta atrakcja turystyczna pozwala graczom na podziwianie zapierających dech w piersiach widoków z wysokości, co dodaje nowy poziom immersji do gry. Kolejka linowa jest również świetnym sposobem na szybkie przemieszczanie się między różnymi częściami mapy.',
        image = 'data/1.png?v2'
    },
    {
        date = 1729263779,
        title = 'Praca fotografa',
        description = 'Dodano pracę fotografa! Aparaty fotograficzne są porozrzucane po całej mapie, po podniesieniu aparatu gracz ma za zadanie zrobić zdjęcie określonego pojazdu, miejsca lub gracza. Za każde udane zdjęcie gracz otrzymuje pieniądze!',
        image = 'data/4.png?v2'
    },
}

function getUpdates()
    return updates
end

function getUpdatesSinceLastJoin(player)
    player = player or localPlayer
    if not player then return {} end

    local lastJoin = getElementData(player, 'player:lastActive') or 0
    local updatesSinceLastJoin = {}
    
    for i, update in ipairs(updates) do
        if update.date > lastJoin then
            table.insert(updatesSinceLastJoin, update)
        end
    end

    return updatesSinceLastJoin
end