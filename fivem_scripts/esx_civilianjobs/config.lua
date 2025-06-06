Config = {}

-- General Settings
Config.EnableJobSwitching = true
Config.RequireJobCenter = false -- If true, players must visit job center to change jobs
Config.EnableJobStatistics = true
Config.EnableHourlyBonus = true

-- Job Center Location (if enabled)
Config.JobCenter = {
    coords = {x = -265.0, y = -963.6, z = 31.2},
    blip = {sprite = 408, color = 3, scale = 0.8}
}

-- GARBAGE COLLECTOR JOB
Config.GarbageJob = {
    enabled = true,
    vehicleModel = 'trash',
    vehicleSpawn = {x = -322.3, y = -1545.9, z = 31.0, h = 180.0},
    depot = {x = -322.3, y = -1545.9, z = 31.0},
    routes = {
        {
            name = 'Davis Route',
            containers = {
                {x = 128.9, y = -1298.7, z = 29.2},
                {x = 213.9, y = -1461.1, z = 29.3},
                {x = 341.3, y = -1574.5, z = 29.3},
                {x = 435.7, y = -1703.6, z = 29.6},
                {x = 321.8, y = -1935.9, z = 24.9},
                {x = 149.4, y = -1864.8, z = 24.6},
                {x = 76.4, y = -1948.1, z = 21.2},
                {x = -34.0, y = -1847.3, z = 26.2}
            }
        }
    },
    payment = {
        perContainer = {min = 50, max = 150},
        routeBonus = {min = 500, max = 1000}
    }
}

-- FISHING JOB
Config.FishingJob = {
    enabled = true,
    requiresFishingRod = true,
    fishingRodPrice = 50,
    spots = {
        {
            name = 'Vespucci Beach',
            coords = {x = -1850.7, y = -1248.0, z = 8.6},
            fishTypes = {
                {name = 'Sardine', chance = 40, price = {min = 20, max = 30}},
                {name = 'Forelle', chance = 30, price = {min = 40, max = 50}},
                {name = 'Lachs', chance = 20, price = {min = 70, max = 80}},
                {name = 'Thunfisch', chance = 8, price = {min = 115, max = 125}},
                {name = 'Hai', chance = 2, price = {min = 480, max = 520}}
            }
        },
        {
            name = 'Chumash Beach',
            coords = {x = -3426.3, y = 967.4, z = 8.3},
            fishTypes = {
                {name = 'Sardine', chance = 35, price = {min = 25, max = 35}},
                {name = 'Forelle', chance = 35, price = {min = 45, max = 55}},
                {name = 'Lachs', chance = 20, price = {min = 75, max = 85}},
                {name = 'Thunfisch', chance = 8, price = {min = 120, max = 130}},
                {name = 'Hai', chance = 2, price = {min = 500, max = 550}}
            }
        },
        {
            name = 'Alamo Sea',
            coords = {x = 1300.4, y = 4216.7, z = 33.9},
            fishTypes = {
                {name = 'Karpfen', chance = 50, price = {min = 15, max = 25}},
                {name = 'Barsch', chance = 30, price = {min = 35, max = 45}},
                {name = 'Hecht', chance = 15, price = {min = 60, max = 70}},
                {name = 'Wels', chance = 5, price = {min = 90, max = 110}}
            }
        },
        {
            name = 'Sandy Shores',
            coords = {x = 2835.8, y = 1584.7, z = 24.5},
            fishTypes = {
                {name = 'Karpfen', chance = 45, price = {min = 20, max = 30}},
                {name = 'Barsch', chance = 35, price = {min = 40, max = 50}},
                {name = 'Hecht', chance = 15, price = {min = 65, max = 75}},
                {name = 'Wels', chance = 5, price = {min = 95, max = 115}}
            }
        },
        {
            name = 'Paleto Bay',
            coords = {x = -783.4, y = 5432.1, z = 34.1},
            fishTypes = {
                {name = 'Sardine', chance = 30, price = {min = 30, max = 40}},
                {name = 'Forelle', chance = 40, price = {min = 50, max = 60}},
                {name = 'Lachs', chance = 25, price = {min = 80, max = 90}},
                {name = 'Thunfisch', chance = 4, price = {min = 125, max = 135}},
                {name = 'Hai', chance = 1, price = {min = 520, max = 580}}
            }
        }
    },
    fishingTime = {min = 5000, max = 15000}, -- milliseconds
    catchChance = 70 -- 70% chance to catch fish
}

-- DELIVERY JOB
Config.DeliveryJob = {
    enabled = true,
    vehicleModel = 'boxville',
    vehicleSpawn = {x = 1025.2, y = -2400.5, z = 30.5, h = 180.0},
    depot = {x = 1025.2, y = -2400.5, z = 30.5},
    routes = {
        {
            name = 'City Route',
            deliveries = {
                {x = 25.7, y = -1347.3, z = 29.5, name = 'Vanilla Unicorn'},
                {x = 373.5, y = 325.6, z = 103.6, name = 'Clinton Ave'},
                {x = -1487.5, y = -379.1, z = 40.2, name = 'Morningwood'},
                {x = -1821.5, y = 792.5, z = 138.1, name = 'Banham Canyon'},
                {x = 1167.0, y = -324.1, z = 69.2, name = 'Mirror Park'}
            }
        }
    },
    payment = {
        perDelivery = {min = 100, max = 250},
        routeBonus = {min = 300, max = 600},
        timeBonus = 10 -- $10 per minute
    }
}

-- CONSTRUCTION JOB
Config.ConstructionJob = {
    enabled = true,
    sites = {
        {
            name = 'Davis Construction',
            coords = {x = -141.9, y = -1687.4, z = 32.9},
            workTime = {min = 10000, max = 20000}
        },
        {
            name = 'El Burro Heights',
            coords = {x = 1273.9, y = -1524.5, z = 49.6},
            workTime = {min = 12000, max = 18000}
        },
        {
            name = 'Vespucci Beach',
            coords = {x = -967.5, y = -1434.1, z = 7.5},
            workTime = {min = 8000, max = 25000}
        },
        {
            name = 'Vinewood Hills',
            coords = {x = 2561.3, y = 384.8, z = 108.6},
            workTime = {min = 15000, max = 22000}
        }
    },
    payment = {
        perWork = {min = 150, max = 350},
        hourlyBonus = 100
    }
}

-- CLOTHING STORE JOB
Config.ClothingJob = {
    enabled = true,
    stores = {
        {
            name = 'Binco',
            coords = {x = 425.2, y = -806.2, z = 29.5},
            commission = 0.10 -- 10% commission
        },
        {
            name = 'SubUrban',
            coords = {x = -709.2, y = -152.3, z = 37.4},
            commission = 0.12
        },
        {
            name = 'Ponsonbys',
            coords = {x = -164.6, y = -302.5, z = 39.7},
            commission = 0.15
        }
    },
    items = {
        {name = 'T-Shirt', price = 50},
        {name = 'Jeans', price = 80},
        {name = 'Sneakers', price = 120},
        {name = 'Jacket', price = 200},
        {name = 'Suit', price = 500}
    }
}

-- TAXI JOB
Config.TaxiJob = {
    enabled = true,
    vehicleModel = 'taxi',
    vehicleSpawn = {x = 909.8, y = -177.4, z = 74.2, h = 240.0},
    pricePerMeter = 2.5,
    baseFare = 10,
    tipChance = 60, -- 60% chance for tip
    tipAmount = {min = 10, max = 100},
    destinations = {
        {name = 'Los Santos International Airport', coords = {x = -1037.7, y = -2738.0, z = 20.2}},
        {name = 'Vinewood Sign', coords = {x = 738.3, y = 1198.6, z = 326.4}},
        {name = 'Del Perro Pier', coords = {x = -1850.4, y = -1230.1, z = 13.0}},
        {name = 'Sandy Shores Airfield', coords = {x = 1747.8, y = 3273.7, z = 41.1}},
        {name = 'Paleto Bay', coords = {x = -234.7, y = 6336.9, z = 32.4}},
        {name = 'Mount Chiliad', coords = {x = 501.9, y = 5593.9, z = 797.9}},
        {name = 'Maze Bank Tower', coords = {x = -75.8, y = -818.9, z = 326.2}},
        {name = 'Fort Zancudo', coords = {x = -2267.0, y = 3120.5, z = 32.8}}
    }
}

-- BONUS SYSTEM
Config.BonusSystem = {
    hourlyBonus = {
        enabled = true,
        amount = 200,
        interval = 3600000 -- 1 hour in milliseconds
    },
    dailyBonus = {
        enabled = true,
        amount = 1000,
        resetTime = "00:00" -- 24h format
    },
    weeklyBonus = {
        enabled = true,
        amount = 5000,
        resetDay = "monday"
    },
    randomEvents = {
        enabled = true,
        chance = 10, -- 10% chance every 30 minutes
        interval = 1800000, -- 30 minutes
        bonusAmount = {min = 100, max = 500}
    }
}

-- EXPERIENCE SYSTEM
Config.ExperienceSystem = {
    enabled = true,
    activities = {
        garbage_collected = 5,
        fish_caught = 3,
        delivery_completed = 8,
        construction_work = 10,
        clothing_sale = 15,
        taxi_ride = 7
    },
    levelRequirements = {
        [1] = 0,
        [2] = 100,
        [3] = 300,
        [4] = 600,
        [5] = 1000,
        [6] = 1500,
        [7] = 2100,
        [8] = 2800,
        [9] = 3600,
        [10] = 4500
    },
    levelBonuses = {
        [2] = {type = 'payment_multiplier', value = 1.1}, -- +10% earnings
        [3] = {type = 'payment_multiplier', value = 1.15},
        [4] = {type = 'payment_multiplier', value = 1.2},
        [5] = {type = 'payment_multiplier', value = 1.25},
        [6] = {type = 'unlock_job', value = 'special_delivery'},
        [7] = {type = 'payment_multiplier', value = 1.3},
        [8] = {type = 'unlock_job', value = 'premium_fishing'},
        [9] = {type = 'payment_multiplier', value = 1.4},
        [10] = {type = 'payment_multiplier', value = 1.5}
    }
}

-- BLIP SETTINGS
Config.Blips = {
    jobCenter = {
        enabled = true,
        sprite = 408,
        color = 3,
        scale = 0.8,
        name = 'Job Center'
    },
    garbageDepot = {
        enabled = true,
        sprite = 318,
        color = 2,
        scale = 0.7,
        name = 'Müll-Depot'
    },
    deliveryDepot = {
        enabled = true,
        sprite = 478,
        color = 5,
        scale = 0.7,
        name = 'Lieferdepot'
    },
    clothingStores = {
        enabled = true,
        sprite = 73,
        color = 4,
        scale = 0.6,
        name = 'Kleidungsladen'
    }
}

-- ITEMS (for inventory systems)
Config.Items = {
    fishing_rod = {
        name = 'fishing_rod',
        label = 'Angelrute',
        weight = 2000,
        unique = false,
        useable = true
    },
    fish_sardine = {
        name = 'fish_sardine',
        label = 'Sardine',
        weight = 300,
        unique = false,
        useable = false
    },
    fish_trout = {
        name = 'fish_trout',
        label = 'Forelle',
        weight = 800,
        unique = false,
        useable = false
    },
    fish_salmon = {
        name = 'fish_salmon',
        label = 'Lachs',
        weight = 1200,
        unique = false,
        useable = false
    },
    fish_tuna = {
        name = 'fish_tuna',
        label = 'Thunfisch',
        weight = 2000,
        unique = false,
        useable = false
    },
    fish_shark = {
        name = 'fish_shark',
        label = 'Hai',
        weight = 5000,
        unique = false,
        useable = false
    }
}

-- LOCALES
Config.Locales = {
    ['job_started'] = 'Job gestartet: %s',
    ['job_finished'] = 'Job beendet',
    ['not_in_vehicle'] = 'Du musst im Fahrzeug sein!',
    ['no_player_nearby'] = 'Kein Spieler in der Nähe!',
    ['insufficient_funds'] = 'Nicht genug Geld!',
    ['fishing_rod_bought'] = 'Angelrute für $%s gekauft!',
    ['fish_caught'] = '%s gefangen! ($%s)',
    ['fish_escaped'] = 'Der Fisch ist entkommen!',
    ['garbage_collected'] = 'Müll gesammelt! +$%s',
    ['route_completed'] = 'Route abgeschlossen! Bonus: +$%s',
    ['delivery_completed'] = 'Paket geliefert an %s! +$%s',
    ['construction_work'] = 'Arbeit abgeschlossen! +$%s',
    ['clothing_sale'] = 'Kleidung für $%s verkauft! Provision: +$%s',
    ['taxi_fare'] = 'Fahrt beendet! Fare: $%s, Trinkgeld: $%s',
    ['hourly_bonus'] = 'Stunden-Bonus erhalten: $%s',
    ['random_bonus'] = 'Zufallsbonus! Du hast $%s gefunden!',
    ['level_up'] = 'Level Up! Du bist jetzt Level %s',
    ['job_already_active'] = 'Du hast bereits einen Job aktiv!',
    ['job_not_available'] = 'Dieser Job ist derzeit nicht verfügbar',
    ['return_to_depot'] = 'Fahre zurück zum Depot',
    ['work_in_progress'] = 'Arbeite...',
    ['fishing_in_progress'] = 'Angelst...',
    ['vehicle_spawned'] = 'Fahrzeug gespawnt: %s'
}