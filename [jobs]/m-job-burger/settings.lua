settings = {
    jobStart = Vector3(1199.309, -918.793, 43.118),

    interior = {1193.423, -908.172, 42.354, 0, 0, 90},
    camera = {8, 0.2, 5},
    cameraLookAt = {-3, 0.2, 0},
    cameraFov = 60,
    removeObjects = {
        {1522, 200, 1198.611, -912.601, 43.143},
        {5858, 200, 1198.611, -912.601, 43.143},
        {6010, 200, 1198.611, -912.601, 43.143},
    },

    cookTime = {
        burger = 8000,
    },
    burnTime = 7000,

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
            model = 'burger/board',
            position = {2.3, -1.5, 0.99},
            rotation = {0, 0, -200},
            scale = 1.45,
        },
        {
            clickTrigger = {
                type = 'server',
                event = 'meat'
            },
            model = 'burger/meat',
            position = {2.3, -1.5, 1.025},
            rotation = {0, 0, -200},
            scale = 1.9,
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
            trigger = 'cola',
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

    
    fries = {
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

        ['burger/grill-meat'] = {
            position = {0, -0.08, 0.125},
            scale = 1.9,
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

    interiorExit = {1199.504, -920.487, 43.109},
}