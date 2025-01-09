local t, f = true, false

function build(s)
    local t = {}
    local i = 1
    for w in s:gmatch("%S+") do
        if tonumber(w) then
            i = tonumber(w)
        else
            t[i] = (w == "t")
            i = i + 1
        end
    end
    return t
end

function generate(data)
    local t = {
        name = data.name,
        delay = data.delay,
    }
    
    for k,v in pairs(data) do
        if type(k) == "number" and v then
            local d = {}
            for i = 1, 50 do
                if i == v[2] then
                    d[v[1]] = t
                else
                    d[i] = f
                end
            end
            table.insert(t, d)
        end
        if data.between then
            for i = 1, data.between do
                local d = {}
                for k,v in pairs(data[1]) do
                    d[v] = false
                end
                table.insert(t, d)
            end
        end
    end

    local d = {}
    for k,v in pairs(data[1]) do
        d[v] = false
    end

    if data.wait then
        for i = 1, data.wait do
            table.insert(t, d)
        end
    end

    return t
end

modes = {
    --[[
        [vehicle model] = {
            [mode id (also key num_id)] = {
                collidable = {id, id, id}, -- With which other modes can this mode collide, for example if id 1 is on you can't run it
                name = "Name in menu",
                delay = 0, -- Change time in miliseconds

                build("id of group that you want to start of t f t f t f f f"),
                for example: build("1 t f") - group 1 is on, group 2 is off

                build("1 t f")
                build("1 f t") - simple blinking between 1 and 2

                you can also make it via table, it will automatically start from 1
                {t, f},
                {f, t},

                -- t = on, f = f
                ...
            },
            ...
        }
    ]]

    [597] = {
        [1] = generate({
            name = "test",
            delay = 80,
            wait = 10,
            between = 5,
            {1, 1},
            {2, 2},
        })
    },

    [598] = {
        [1] = {
            name = "HALOGEN",
            delay = 1000,
            build("1 t"),
        },
        
        draw = {
            ["top"] = {1},
        }
    },
    [596] = {
        presets = {
            ["b"] = {1, 3},
        },

        [1] = {
            collidable = {2},
            name = "TOP01",
            delay = 250,
            {t, f},
            {f, t},
        },
        [2] = {
            collidable = {1},
            name = "TOP02",
            delay = 50,
            {t, f},
            {f, f},
            {t, f},
            {f, f},
            {t, f},
            {f, f},
            {t, f},
            {f, f},

            {f, f},
            {f, f},
            {f, f},

            {f, t},
            {f, f},
            {f, t},
            {f, f},
            {f, t},
            {f, f},
            {f, t},
            {f, f},

            {f, f},
            {f, f},
            {f, f},
        },
        [3] = {
            name = "FRNT01",
            collidable = {4},
            delay = 250,
            build("3 t f t f"),
            build("3 f t f t"),
        },
        [4] = {
            name = "FRNT02",
            collidable = {3},
            delay = 50,
            build("3 t f t f"),
            build("3 f f f f"),
            build("3 t f t f"),
            build("3 f f f f"),
            build("3 t f t f"),
            build("3 f f f f"),
            build("3 t f t f"),
            build("3 f f f f"),
            build("3 f f f f"),
            build("3 f f f f"),
            build("3 f t f t"),
            build("3 f f f f"),
            build("3 f t f t"),
            build("3 f f f f"),
            build("3 f t f t"),
            build("3 f f f f"),
            build("3 f t f t"),
            build("3 f f f f"),
            build("3 f f f f"),
            build("3 f f f f"),
            build("3 f f f f"),
            build("3 f f f f"),
            build("3 f f f f"),
        },
        [5] = {
            name = "BACK01",
            collidable = {6},
            delay = 250,
            build("11 t f t f t f t f"),
            build("11 f t f t f t f t"),
        },
        [6] = {
            name = "BACK02",
            collidable = {5},
            delay = 50,
            build("11 t f f f f f f t"),
            build("11 t t f f f f t t"),
            build("11 t t t f f t t t"),
            build("11 f t t t f t t f"),
            build("11 f f t t t t f f"),
            build("11 f f f t t f f f"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
            build("11 f f f t t f f f"),
            build("11 f f t t t t f f"),
            build("11 f t t t t t t f"),
            build("11 t t t t t t t t"),
            build("11 t t t t t t t t"),
            build("11 t t t t t t t t"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
            build("11 t t t t t t t t"),
            build("11 t t t t t t t t"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
            build("11 t t t t t t t t"),
            build("11 t t t t t t t t"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
            build("11 t t t t t t t t"),
            build("11 t t t t t t t t"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
            build("11 t t t t t t t t"),
            build("11 t t t t t t t t"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
            build("11 t t t t t t t t"),
            build("11 t t t t t t t t"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
            build("11 t t t t t t t t"),
            build("11 t t t t t t t t"),
            build("11 f f f f f f f f"),
            build("11 f f f f f f f f"),
        },
        [7] = {
            name = "BELKA TEST",
            delay = 250,
            collidable = {6, 5},
            build("11 t f f f f f f t"),
        },

        draw = {
            ["top"] = {1, 2},
            ["front"] = {3, 4},
        }
    }
}

function getVehicleModes(veh)
    if type(veh) == "number" then
        return modes[veh]
    end

    local veh = getElementModel(veh)
    return modes[veh]
end