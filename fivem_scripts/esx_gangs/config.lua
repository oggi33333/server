Config = {}

-- Gang System Settings
Config.EnableGangWars = true
Config.EnableTerritories = true
Config.EnableDrugSales = true
Config.EnableWeaponDealing = true

-- Gang Definitions
Config.Gangs = {
    ['vagos'] = {
        name = 'Los Santos Vagos',
        color = {255, 255, 0}, -- Yellow
        vehicles = {'tornado', 'tornado2', 'buccaneer', 'voodoo'},
        hq = {x = 331.3, y = -2039.9, z = 20.9},
        blip = {sprite = 84, color = 5}
    },
    ['ballas'] = {
        name = 'Ballas',
        color = {128, 0, 128}, -- Purple
        vehicles = {'emperor', 'emperor2', 'blade', 'buccaneer2'},
        hq = {x = 114.9, y = -1961.5, z = 21.3},
        blip = {sprite = 84, color = 27}
    },
    ['families'] = {
        name = 'Grove Street Families',
        color = {0, 255, 0}, -- Green
        vehicles = {'greenwood', 'glendale', 'manana', 'tornado3'},
        hq = {x = -158.7, y = -1611.8, z = 33.1},
        blip = {sprite = 84, color = 2}
    },
    ['marabunta'] = {
        name = 'Marabunta Grande',
        color = {0, 191, 255}, -- Light Blue
        vehicles = {'faction', 'faction2', 'chino', 'chino2'},
        hq = {x = 1437.6, y = -1492.9, z = 63.6},
        blip = {sprite = 84, color = 38}
    },
    ['triads'] = {
        name = 'Triads',
        color = {255, 0, 0}, -- Red
        vehicles = {'sultan', 'sultan2', 'kuruma', 'kuruma2'},
        hq = {x = -938.7, y = -29.5, z = 39.1},
        blip = {sprite = 84, color = 1}
    }
}

-- Gang Ranks
Config.GangRanks = {
    [1] = {name = 'Neuling', salary = 100},
    [2] = {name = 'Mitglied', salary = 250},
    [3] = {name = 'Veteran', salary = 400},
    [4] = {name = 'Leutnant', salary = 650},
    [5] = {name = 'Boss', salary = 1000}
}

-- Territory System
Config.Territories = {
    {
        id = 1,
        name = 'Davis',
        coords = {x = 95.2, y = -1909.8, z = 21.0},
        radius = 200.0,
        income = 500, -- Per hour
        default_owner = nil
    },
    {
        id = 2,
        name = 'Groove Street',
        coords = {x = 116.1, y = -1961.5, z = 21.3},
        radius = 150.0,
        income = 750,
        default_owner = 'families'
    },
    {
        id = 3,
        name = 'El Rancho',
        coords = {x = 1437.6, y = -1492.9, z = 63.6},
        radius = 180.0,
        income = 600,
        default_owner = 'marabunta'
    },
    {
        id = 4,
        name = 'Little Seoul',
        coords = {x = -938.7, y = -29.5, z = 39.1},
        radius = 220.0,
        income = 800,
        default_owner = 'triads'
    },
    {
        id = 5,
        name = 'Rancho',
        coords = {x = 331.3, y = -2039.9, z = 20.9},
        radius = 160.0,
        income = 650,
        default_owner = 'vagos'
    },
    {
        id = 6,
        name = 'Chamberlain Hills',
        coords = {x = 114.9, y = -1961.5, z = 21.3},
        radius = 170.0,
        income = 700,
        default_owner = 'ballas'
    },
    {
        id = 7,
        name = 'Strawberry',
        coords = {x = 349.9, y = -1804.5, z = 31.3},
        radius = 190.0,
        income = 550,
        default_owner = nil
    },
    {
        id = 8,
        name = 'Mirror Park',
        coords = {x = 1151.3, y = -314.0, z = 69.2},
        radius = 200.0,
        income = 900,
        default_owner = nil
    }
}

-- Drug System
Config.DrugLocations = {
    {
        name = 'Sandy Shores Airfield',
        coords = {x = 1392.48, y = 3614.58, z = 34.89},
        drugs = {
            {item = 'marijuana', min = 5, max = 15, price = {min = 150, max = 250}},
            {item = 'cocaine', min = 2, max = 8, price = {min = 300, max = 500}}
        }
    },
    {
        name = 'Grapeseed',
        coords = {x = 2434.09, y = 4968.98, z = 42.35},
        drugs = {
            {item = 'marijuana', min = 8, max = 20, price = {min = 200, max = 300}},
            {item = 'meth', min = 1, max = 5, price = {min = 500, max = 800}}
        }
    },
    {
        name = 'Mount Chiliad',
        coords = {x = 1905.25, y = 4924.45, z = 48.88},
        drugs = {
            {item = 'cocaine', min = 3, max = 10, price = {min = 400, max = 600}},
            {item = 'opium', min = 1, max = 3, price = {min = 800, max = 1200}}
        }
    }
}

-- Weapon System
Config.GangWeapons = {
    ['pistol'] = {
        name = 'Pistole',
        weapon = 'WEAPON_PISTOL',
        price = 1500,
        ammo = 100,
        rank_required = 3
    },
    ['smg'] = {
        name = 'SMG',
        weapon = 'WEAPON_SMG',
        price = 5000,
        ammo = 200,
        rank_required = 3
    },
    ['rifle'] = {
        name = 'Gewehr',
        weapon = 'WEAPON_CARBINERIFLE',
        price = 12000,
        ammo = 150,
        rank_required = 4
    },
    ['sniper'] = {
        name = 'Sniper',
        weapon = 'WEAPON_SNIPERRIFLE',
        price = 25000,
        ammo = 50,
        rank_required = 5
    }
}

-- Gang War Settings
Config.GangWarSettings = {
    duration = 1800, -- 30 minutes
    cooldown = 7200, -- 2 hours
    min_members = 3, -- Minimum members online to start war
    reward_winner = 50000,
    penalty_loser = 25000
}

-- Territory War Settings
Config.TerritoryWarSettings = {
    duration = 300, -- 5 minutes
    cooldown = 3600, -- 1 hour
    attack_cost = 10000,
    success_rate_base = 60, -- Base 60% success rate
    member_bonus = 5 -- +5% per additional member
}

-- Vehicle Settings
Config.VehicleSettings = {
    spawn_distance = 5.0,
    max_vehicles = 3, -- Max vehicles per gang member
    despawn_time = 300, -- 5 minutes idle despawn
    upgrade_cost = 5000
}

-- Bank Settings
Config.BankSettings = {
    max_deposit = 1000000,
    max_withdraw = 100000,
    withdraw_cooldown = 300, -- 5 minutes
    transaction_fee = 0.02 -- 2% fee
}

-- Activity Rewards
Config.ActivityRewards = {
    drug_sale = {min = 100, max = 500},
    territory_capture = {min = 5000, max = 15000},
    gang_war_participation = {min = 1000, max = 3000},
    successful_defense = {min = 2000, max = 5000}
}

-- Notification Settings
Config.Notifications = {
    gang_war_started = true,
    territory_attacked = true,
    member_joined = true,
    member_left = true,
    bank_transaction = true,
    rank_change = true
}

-- Blip Settings
Config.BlipSettings = {
    show_gang_hq = true,
    show_territories = true,
    show_drug_locations = false, -- Only for gang members
    show_active_wars = true
}

-- Experience System
Config.ExperienceSystem = {
    enabled = true,
    actions = {
        drug_sale = 10,
        territory_capture = 100,
        gang_war_kill = 25,
        successful_defense = 50,
        member_recruitment = 75
    },
    rank_requirements = {
        [2] = 100,  -- Member
        [3] = 500,  -- Veteran
        [4] = 1500, -- Lieutenant
        [5] = 5000  -- Boss
    }
}

-- Locales
Config.Locales = {
    ['not_in_gang'] = 'Du bist in keiner Gang!',
    ['insufficient_rank'] = 'Du hast nicht die erforderliche Berechtigung!',
    ['gang_war_started'] = 'Gang War zwischen %s und %s hat begonnen!',
    ['territory_captured'] = '%s hat %s erobert!',
    ['territory_attacked'] = '%s wird von %s angegriffen!',
    ['player_invited'] = 'Du wurdest zu %s eingeladen!',
    ['player_kicked'] = 'Du wurdest aus %s gekickt!',
    ['player_promoted'] = 'Du wurdest zu %s befördert!',
    ['player_demoted'] = 'Du wurdest zu %s degradiert!',
    ['money_deposited'] = '$%s in Gang-Bank eingezahlt!',
    ['money_withdrawn'] = '$%s aus Gang-Bank abgehoben!',
    ['vehicle_spawned'] = 'Gang-Fahrzeug %s gespawnt!',
    ['drug_run_started'] = 'Drug Run gestartet! Fahre zu den Koordinaten.',
    ['drugs_sold'] = 'Drogen für $%s verkauft!',
    ['weapon_purchased'] = '%s für $%s gekauft!',
    ['territory_war_won'] = 'Territorium-Krieg gewonnen! %s erobert!',
    ['territory_war_lost'] = 'Territorium-Krieg verloren!',
    ['gang_war_won'] = 'Gang War gewonnen gegen %s!',
    ['gang_war_lost'] = 'Gang War verloren gegen %s!',
    ['backup_requested'] = 'Gang-Verstärkung angefordert!',
    ['member_online'] = '%s ist online gekommen',
    ['member_offline'] = '%s ist offline gegangen',
    ['insufficient_funds'] = 'Nicht genug Geld!',
    ['no_player_nearby'] = 'Kein Spieler in der Nähe!',
    ['action_cooldown'] = 'Aktion ist noch %s Sekunden im Cooldown!',
    ['gang_full'] = 'Gang ist voll!',
    ['already_in_gang'] = 'Spieler ist bereits in einer Gang!',
    ['gang_disbanded'] = 'Gang %s wurde aufgelöst!',
    ['territory_income'] = 'Territorium-Einkommen: $%s erhalten',
    ['salary_received'] = 'Gang-Gehalt erhalten: $%s'
}