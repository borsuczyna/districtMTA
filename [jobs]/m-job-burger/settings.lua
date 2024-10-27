settings = {
    jobStart = Vector3(1206.442, -905.916, 43.211),
    upgradePointChance = 0.01,

    interior = {1193.423, -908.172, 42.354, 0, 0, 90},
    camera = {8, 0.2, 5},
    cameraLookAt = {-3, 0.2, 0},
    cameraFov = 60,
    removeObjects = {
        {5741, 200, 1198.611, -912.601, 43.143},
    },

    cookTime = {
        burger = 8000,
        fries = 6000,
        cola = 400,
        colaRenew = 5000,
    },
    burnTime = 7000,

    npcSpawnInterval = {10000, 55000},
    orderMoney = {300, 600}, -- w groszach, $1 = 100

    elements = {
        -- salad
        {
            clickTrigger = {
                type = 'server',
                event = 'salad'
            },
            model = 'burger/salad',
            position = {-1.3, -1.55, 0.98},
            rotation = {0, 0, 0},
            scale = 2,
        },
        -- buns
        {
            model = 'burger/board',
            position = {-0.35, -1.62, 0.99},
            rotation = {0, 0, 8},
            scale = 1.55,
        },
        {
            clickTrigger = {
                type = 'server',
                event = 'bun'
            },
            model = 'burger/bun',
            position = {-0.3, -1.55, 1.045},
            rotation = {0, 0, 0},
            scale = 2.3,
        },
        -- grills
        {
            clickTrigger = {
                type = 'server',
                event = 'grill-1'
            },
            model = 'burger/grill',
            position = {0.7, -1.45, 0.98},
            rotation = {0, 0, 0},
            scale = 1,
        },
        {
            clickTrigger = {
                type = 'server',
                event = 'grill-2'
            },
            model = 'burger/grill',
            position = {1.4, -1.45, 0.98},
            rotation = {0, 0, 0},
            scale = 1,
        },
        -- meat
        {
            clickTrigger = {
                type = 'server',
                event = 'meat'
            },
            model = 'burger/board',
            position = {2.3, -1.5, 0.99},
            rotation = {0, 0, -200},
            scale = 1.45,
        },
        {
            model = 'burger/meat',
            position = {2.3, -1.5, 1.025},
            rotation = {0, 0, -200},
            scale = 1.9,
            noCollision = true,
        },
        -- fryers
        {
            clickTrigger = {
                type = 'server',
                event = 'fryer-1'
            },
            model = 'burger/fryer',
            position = {-0.35, 2.0, 0.95},
            rotation = {0, 0, 0},
            scale = 1.8,
        },
        {
            clickTrigger = {
                type = 'server',
                event = 'fryer-2'
            },
            model = 'burger/fryer',
            position = {0.75, 2.0, 0.95},
            rotation = {0, 0, 0},
            scale = 1.8,
        },
        -- cola dispenser
        {
            clickTrigger = {
                type = 'server',
                event = 'cola'
            },
            model = 'burger/cola-dispenser',
            position = {2.75, 1.85, 1},
            rotation = {0, 0, -25},
        },
        {
            model = 'burger/cola-liquid',
            position = {2.79, 1.925, 1.5},
            rotation = {0, 0, -25},
            scale = 1.12,
        },
        -- trash
        {
            clickTrigger = {
                type = 'server',
                event = 'trash'
            },
            model = 'burger/trash',
            position = {3, -0.5, 1},
            rotation = {0, 0, 90},
        },
        -- 2 boards
        {
            clickTrigger = {
                type = 'server',
                event = 'board-1'
            },
            model = 'burger/board',
            position = {2.94, 0.25, 0.99},
            rotation = {0, 0, -97},
            scale = 1.2,
        },
        {
            clickTrigger = {
                type = 'server',
                event = 'board-2'
            },
            model = 'burger/board',
            position = {3, 1, 0.99},
            rotation = {0, 0, 94},
            scale = 1.2,
        },
        -- door
        {
            model = 'burger/door',
            position = {-7.25, -0.86, 0},
            rotation = {0, 0, -80},
        },
    },
    
    fryers = {
        {
            position = {-0.35, 1.85, 1.2},
            rotation = {0, 0, 0},
            scale = 1.8,
        },
        {
            position = {0.75, 1.85, 1.2},
            rotation = {0, 0, 0},
            scale = 1.8,
        },
    },

    cola = {
        model = 'burger/cola-glass',
        position = {2.59, 1.63, 1.25},
        rotation = {0, 0, 0},
        scale = 1.0,
    },

    pedSpawns = {
        {1191.595, -911.085, 43.354, 0},
        {1192.595, -911.085, 43.354, 0},
        {1193.695, -911.085, 43.354, 0},
        {1194.695, -911.085, 43.354, 0},
    },

    pedLeaveTarget = {1193.315, -914.912, 43.354},

    carryPositions = {
        ['burger/burger-in-packaging'] = {
            position = {0.01, 0, 0},
            rotation = {-90, 0, 0},
            scale = 1.2,
        },
        ['burger/meat'] = {
            position = {0.06, 0.05, 0},
            rotation = {-90, 0, 0},
            scale = 1.5,
        },
        ['burger/meat-cooked'] = {
            position = {0.06, 0.05, 0},
            rotation = {-90, 0, 0},
            scale = 1.5,
        },
        ['burger/meat-overcooked'] = {
            position = {0.06, 0.05, 0},
            rotation = {-90, 0, 0},
            scale = 1.5,
        },
        ['burger/salad-box'] = {
            position = {0.06, 0.05, 0},
            rotation = {-90, 0, 0},
            scale = 1.5,
        },
        ['burger/fries-box'] = {
            position = {0.1, 0.16, -0.015},
            rotation = {-90, 0, 0},
            scale = 1.5,
        },
        ['burger/fries-box-burned'] = {
            position = {0.1, 0.16, -0.015},
            rotation = {-90, 0, 0},
            scale = 1.5,
        },
        ['burger/cola-glass-full'] = {
            position = {0.07, 0.2, -0.011},
            rotation = {-90, 0, 0},
            scale = 1.0,
        },
    },
    
    layPositions = {
        ['burger/burger-in-packaging'] = {
            position = {0, 0, -0.025},
            scale = 1.3,
        },
        ['burger/meat'] = {
            position = {0, 0, 0.025},
            scale = 1.9,
        },
        ['burger/meat-cooked'] = {
            position = {0, 0, 0.025},
            scale = 1.9,
        },
        ['burger/meat-overcooked'] = {
            position = {0, 0, 0.025},
            scale = 1.9,
        },
        ['burger/salad-box'] = {
            position = {0, 0, 0.025},
            scale = 1.6,
        },
        ['burger/fries-box'] = {
            position = {0, 0, 0.145},
            scale = 1.6,
        },
        ['burger/fries-box-burned'] = {
            position = {0, 0, 0.145},
            scale = 1.6,
        },

        ['burger/grill-meat'] = {
            position = {0, -0.08, 0.125},
            scale = 1.9,
        },
        ['burger/fryer-fries'] = {
            position = {0, 0, 0.025},
            rotation = {0, 0, 0},
            scale = 1.9,
        },
        ['burger/cola-glass-full'] = {
            position = {0, 0, 0.2},
            rotation = {0, 0, 0},
            scale = 1.0,
        },
    },

    getJobSpawn = function()
        local center = {1193.132, -908.231, 43.354}
        return {center[1] + math.random(-8, 8)/10, center[2] + math.random(-8, 8)/10, center[3]}
    end,

    getJobBounds = function()
        local center = {1193.132, -908.231, 43.354}
        return {
            x = {center[1] - 1, center[1] + 1},
            y = {center[2] - 0.7, center[2] + 2.43},
        }
    end,

    interiorExit = {1206.660, -907.264, 43.211},
}