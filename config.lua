Config = {}
Config.DebugCode = false
Config.UseProgressBar = true
Config.NotifyScript = 'qb'

Config.RemoveBBQ = {
    Jobs = {
        ['police'] = true,
        ['sheriff'] = true,
        ['leo'] = true,
    },
}

Config.MaxPlacementDistance = 5.0 --max distance from player bbq can be before unable to place
Config.Controls = {
    Rotate = {
        ['bbqrotateleft'] = { --do not change
            Label = "Rotate BBQ Left",
            Control = 'NUMPAD1',
        },
        ['bbqrotateright'] = {--do not change
            Label = "Rotate BBQ Right",
            Control = 'NUMPAD2',
        },
    },
    Confirm = {
        ['confirmbbqplacement'] = {--do not change
            Label = "Confirm Placement",
            Control = 'E',
        },
        ['cancelbbqplacement'] = {--do not change
            Label = "Cancel Placement",
            Control = 'ESCAPE',
        },
    },
}

Config.Items = {
    ['bbq1'] = {
        Prop = 'prop_bbq_1',
        Fuel = {
            Item = 'propane',
            FillAmount = 150,
            MaxFuel = 150,
        },
    },
    ['bbq2'] = {
        Prop = 'prop_bbq_2',
        Fuel = {
            Item = 'coal',
            FillAmount = 10,
            MaxFuel = 30,
        },
    },
    ['bbq3'] = {
        Prop = 'prop_bbq_3',
        Fuel = {
            Item = 'wood',
            FillAmount = 10,
            MaxFuel = 75,
        },
    },
    ['bbq4'] = {
        Prop = 'prop_bbq_4',
        Fuel = {
            Item = 'coal',
            FillAmount = 10,
            MaxFuel = 50,
        },
    },
    ['bbq5'] = {
        Prop = 'prop_bbq_5',
        Fuel = {
            Item = 'propane',
            FillAmount = 200,
            MaxFuel = 200,
        },
    },
}
Config.Emotes = {
    Cooking = 'bbq',
    PlaceBBQ = 'mechanic4',
    Refuel = 'mechanic4',
}
Config.Timings = {
    PlaceBBQ = 5, -- in seconds
    Refuel = 10,
}
Config.EnableFuelSystem = true
Config.ShowItemImages = true
Config.EnableBBQShop = true
Config.ShopBlips = {
    Show = true,
    Sprite = 59,
    Colour = 3,
    Label = "BBQ Shop",
}
Config.ShopLocations = {
    ['southside'] = {Coords = vector4(53.06, -1479.82, 29.27, 181.97),PedModel = 'a_f_m_eastsa_02'},
    ['paleto'] = {Coords = vector4(-122.97, 6389.65, 32.18, 46.03),PedModel = 'a_f_m_eastsa_02'},
}
Config.Shop = { --change prices to your economy
    ['bbqs'] = { --this is the category (you can add more)
        Label = "BBQs", --category label
        Description = "Show Available BBQs", --category description
        Stock = {
            ["bbq1"] = {Cost = 100},
            ["bbq2"] = {Cost = 100},
            ["bbq3"] = {Cost = 100},
            ["bbq4"] = {Cost = 100},
            ["bbq5"] = {Cost = 100},
        },
    },
    ['food'] = { 
        Label = "Ingredients", 
        Description = "Show Available Ingredients", 
        Stock = {
            ["uncooked_burger"] = {Cost = 100},
            ["uncooked_chicken"] = {Cost = 100},
            ["uncooked_hotdog"] = {Cost = 100},
            ["uncooked_ribs"] = {Cost = 100},
            ["uncooked_brisket"] = {Cost = 100},
            ["bread"] = {Cost = 100},
            ["cheese"] = {Cost = 100},
        },
    },
    ['fuel'] = { 
        Label = "Fuel Types", 
        Description = "Show Available Fuels", 
        Stock = {
            ["wood"] = {Cost = 100},
            ["coal"] = {Cost = 100},
            ["propane"] = {Cost = 100},
        },
    },
}

Config.Zones = {
    ['mrpd'] = {
        Coords = vector3(449.03, -986.36, 30.69),
        Radius = 50.0,
        -- blocking (use only one at a time)
        Blocked = false, --blocks for everybody everybody regardless of job locked
        JobLocked = {'police','sheriff','leo'}, --blocks for anybody apart from these jobs
        GangLocked = false, --blocks for anybody apart from these gangs
    }
}

Config.Recipes = {
    ['meats'] = { --this is the category (you can add more)
        Label = "Meat", --category label
        Description = "Show List Of Meats", --category description
        Recipes = {
            ["burger"] = { --Item Name
                CookTime = 10,  --in seconds 
                FuelRequired = 5, --% of fuel needed to cook
                Ingredients = {
                    [1] = {item = "uncooked_burger", amount = 1, },
                    [2] = {item = "cheese",amount = 1,},
                    [3] = {item = "bread",amount = 1,},
                },
            },
            ["chicken"] = {
                CookTime = 10,
                FuelRequired = 5,
                Ingredients = {
                    [1] = {item = "uncooked_chicken",amount = 1,},
                    [2] = {item = "bread",amount = 1,},
                },
            },
            ["hotdog"] = {
                CookTime = 5,
                FuelRequired = 5,
                Ingredients = {
                    [1] = {item = "uncooked_hotdog",amount = 1,},
                    [2] = {item = "bread",amount = 1,},
                },
            },
            ["ribs"] = {
                CookTime = 20,
                FuelRequired = 5,
                Ingredients = {
                    [1] = {item = "uncooked_ribs",amount = 1,},
                },
            },
            ["brisket"] = {
                CookTime = 20,
                FuelRequired = 5,
                Ingredients = {
                    [1] = {item = "uncooked_brisket",amount = 1,},
                },
            },
            ["jacket_potato"] = {
                CookTime = 10,
                FuelRequired = 5,
                Ingredients = {
                    [1] = {item = "uncooked_jacket",amount = 1,},
                },
            },
        },
    },
    -- ['category2'] = { 
    --     Label = "ChangeME", 
    --     Description = "ChangeME", 
    --     Recipes = {
    --         ["itemcode"] = { 
    --             CookTime = 10,  
    --             FuelRequired = 5,
    --             Ingredients = {
    --                 [1] = {item = "changeme", amount = 1, },
    --                 [2] = {item = "changeme",amount = 1,},
    --                 [3] = {item = "changeme",amount = 1,},
    --             },
    --         },
    --     },
    -- },
}