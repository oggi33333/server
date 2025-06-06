Config = {}

-- Ambulance Job Settings
Config.AmbulanceJobName = 'ambulance'
Config.EnableRevive = true
Config.EnableHeal = true
Config.EnableBilling = true

-- Vehicle Settings
Config.AmbulanceVehicles = {
    {model = 'ambulance', label = 'Rettungswagen'},
    {model = 'lguard', label = 'Notarzt Fahrzeug'},
    {model = 'polmav', label = 'Rettungshelikopter'},
    {model = 'firetruk', label = 'Feuerwehr'}
}

-- Medical Items
Config.MedicalItems = {
    {name = 'bandage', label = 'Verband', healAmount = 20},
    {name = 'medikit', label = 'Medikit', healAmount = 50},
    {name = 'painkillers', label = 'Schmerzmittel', healAmount = 15},
    {name = 'morphine', label = 'Morphin', healAmount = 75}
}

-- Healing Settings
Config.HealAmount = 75 -- Health amount restored when healing
Config.ReviveHealth = 100 -- Health after revive
Config.ReviveArmor = 0 -- Armor after revive

-- Billing Settings
Config.MaxBillAmount = 10000
Config.MinBillAmount = 1

-- Treatment Prices
Config.TreatmentPrices = {
    ['Erste Hilfe'] = 250,
    ['Wiederbelebung'] = 500,
    ['Krankenhaus Transport'] = 300,
    ['Intensive Behandlung'] = 750,
    ['Operation'] = 1500
}

-- Hospital Locations
Config.HospitalLocations = {
    {
        name = 'Pillbox Hospital',
        coords = vector3(298.6, -584.4, 43.3),
        heading = 70.0
    },
    {
        name = 'Sandy Shores Medical',
        coords = vector3(1839.6, 3672.9, 34.3),
        heading = 210.0
    },
    {
        name = 'Paleto Bay Medical',
        coords = vector3(-247.8, 6331.5, 32.4),
        heading = 225.0
    }
}

-- Death Settings
Config.RespawnTime = 300 -- 5 minutes
Config.EarlyRespawnFine = 2000 -- Fine for early respawn
Config.EnableDeathLogs = true

-- Backup Settings
Config.BackupBlip = {
    sprite = 153,
    scale = 1.0,
    color = 1,
    time = 30000 -- 30 seconds
}

-- Communication Settings
Config.EnableAnnouncements = true
Config.EnableEmergencyCalls = true

-- Animation Settings
Config.HealAnimation = {
    dict = 'mini@cpr@char_a@cpr_str',
    anim = 'cpr_pumpchest',
    duration = 5000
}

Config.ReviveAnimation = {
    dict = 'mini@cpr@char_a@cpr_str',
    anim = 'cpr_pumpchest',
    duration = 15000
}

-- Rewards Settings
Config.HealReward = {min = 200, max = 500}
Config.ReviveReward = {min = 500, max = 1000}
Config.TransportReward = {min = 300, max = 700}

-- Required Items for Actions
Config.RequiredItems = {
    heal = nil, -- No item required for basic heal
    revive = 'medikit', -- Medikit required for revive
    medicalItems = true -- Must have items in inventory to give them
}

-- Locales
Config.Locales = {
    ['not_ambulance'] = 'Du bist kein Sanitäter!',
    ['not_on_duty'] = 'Du musst im Dienst sein!',
    ['no_player_nearby'] = 'Kein Patient in der Nähe!',
    ['player_healed'] = 'Du hast %s geheilt!',
    ['player_revived'] = 'Du hast %s wiederbelebt!',
    ['item_given'] = 'Du hast %sx %s an %s gegeben!',
    ['backup_requested'] = 'Medizinische Verstärkung angefordert!',
    ['backup_received'] = 'Medizinische Verstärkung von %s angefordert bei %s',
    ['vehicle_spawned'] = '%s wurde gespawnt!',
    ['on_duty'] = 'Du bist jetzt im medizinischen Dienst!',
    ['off_duty'] = 'Du bist jetzt außer Dienst!',
    ['insufficient_grade'] = 'Du hast nicht die erforderliche Berechtigung!',
    ['target_healed'] = 'Du wurdest von einem Sanitäter geheilt!',
    ['target_revived'] = 'Du wurdest von einem Sanitäter wiederbelebt!',
    ['target_item_received'] = 'Du hast %sx %s erhalten!',
    ['not_enough_items'] = 'Du hast nicht genug %s!',
    ['announcement_sent'] = 'Durchsage gesendet!',
    ['bill_sent'] = 'Rechnung über $%s für %s wurde gestellt!',
    ['transported_to_hospital'] = 'Du wurdest ins Krankenhaus gebracht!',
    ['health_check'] = '%s - Gesundheit: %s%% | Panzerung: %s%%',
    ['death_notification'] = 'NOTFALL: %s benötigt medizinische Hilfe!',
    ['emergency_call'] = 'NOTRUF: %s - Ort: %s'
}