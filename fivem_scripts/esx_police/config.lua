Config = {}

-- Police Job Settings
Config.PoliceJobName = 'police'
Config.EnableCuffs = true
Config.EnableBilling = true
Config.EnableJail = true

-- Vehicle Settings
Config.PoliceVehicles = {
    {model = 'police', label = 'Streifenwagen'},
    {model = 'police2', label = 'Police SUV'},
    {model = 'policeb', label = 'Police Motorrad'},
    {model = 'polmav', label = 'Police Helikopter'},
    {model = 'riot', label = 'SWAT Van'},
    {model = 'fbi2', label = 'Unmarked SUV'}
}

-- Fine Settings
Config.MaxFineAmount = 50000
Config.MinFineAmount = 1

-- Arrest Settings
Config.DefaultJailTime = 300 -- 5 minutes in seconds

-- Backup Settings
Config.BackupBlip = {
    sprite = 161,
    scale = 1.0,
    color = 1,
    time = 30000 -- 30 seconds
}

-- License Check Settings
Config.RequiredLicenses = {
    'dmv',
    'drive',
    'drive_bike',
    'drive_truck'
}

-- Weapon Confiscation
Config.ConfiscateWeapons = true
Config.IllegalWeapons = {
    'WEAPON_PISTOL',
    'WEAPON_COMBATPISTOL',
    'WEAPON_APPISTOL',
    'WEAPON_PISTOL50',
    'WEAPON_MICROSMG',
    'WEAPON_SMG',
    'WEAPON_ASSAULTSMG',
    'WEAPON_CARBINERIFLE',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_MG',
    'WEAPON_COMBATMG',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_SAWNOFFSHOTGUN',
    'WEAPON_ASSAULTSHOTGUN',
    'WEAPON_BULLPUPSHOTGUN',
    'WEAPON_STUNGUN',
    'WEAPON_SNIPERRIFLE',
    'WEAPON_HEAVYSNIPER',
    'WEAPON_GRENADELAUNCHER',
    'WEAPON_RPG',
    'WEAPON_MINIGUN'
}

-- Item Confiscation
Config.ConfiscateItems = true
Config.IllegalItems = {
    'weed',
    'coke',
    'meth',
    'opium',
    'marijuana',
    'cocaine',
    'methamphetamine',
    'lockpick',
    'crowbar'
}

-- Locales
Config.Locales = {
    ['not_police'] = 'Du bist kein Polizist!',
    ['not_on_duty'] = 'Du musst im Dienst sein!',
    ['no_player_nearby'] = 'Kein Spieler in der Nähe!',
    ['player_arrested'] = 'Du hast %s verhaftet!',
    ['player_fined'] = 'Du hast %s eine Strafe von $%s gegeben!',
    ['player_searched'] = 'Du hast %s durchsucht!',
    ['backup_requested'] = 'Verstärkung angefordert!',
    ['backup_received'] = 'Verstärkung von %s angefordert bei %s',
    ['vehicle_spawned'] = '%s wurde gespawnt!',
    ['on_duty'] = 'Du bist jetzt im Dienst!',
    ['off_duty'] = 'Du bist jetzt außer Dienst!',
    ['insufficient_grade'] = 'Du hast nicht die erforderliche Berechtigung!',
    ['target_arrested'] = 'Du wurdest von der Polizei verhaftet!',
    ['target_fined'] = 'Du hast eine Strafe von $%s erhalten!\nGrund: %s',
    ['target_searched'] = 'Du wirst von der Polizei durchsucht!',
    ['not_enough_money'] = 'Der Spieler hat nicht genug Geld!',
    ['announcement_sent'] = 'Durchsage gesendet!'
}