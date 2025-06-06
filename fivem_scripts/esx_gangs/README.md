# ESX Gang System

Ein vollständiges Gang Management System für ESX Framework mit Territory Wars, Drogenhandel und modernem rotem Design.

## Features

### 🔫 Gang System
- **5 Gangs**: Vagos, Ballas, Families, Marabunta Grande, Triads
- **Rang System**: 5 Ränge von Neuling bis Boss
- **Gang Menu**: F6-Taste für Gang Management
- **Mitgliederverwaltung**: Einladen, Kicken, Befördern, Degradieren
- **Gang Bank**: Einzahlen, Abheben, Transaktionshistorie

### 🗺️ Territory System
- **8 Territorien**: Davis, Groove Street, El Rancho, etc.
- **Territory Wars**: 5-Minuten Kämpfe um Territorien
- **Einkommen**: Stündliche Einnahmen pro Territorium ($500-900)
- **Blips**: Farbkodierte Territorien auf der Karte
- **Eroberung**: Angriff kostet $10,000

### ⚔️ Gang Wars
- **Vollständige Gang Kriege**: 30 Minuten Dauer
- **Belohnungen**: $50,000 für Gewinner, $25,000 Strafe für Verlierer
- **Cooldowns**: 2 Stunden zwischen Gang Wars
- **Live Benachrichtigungen**: Alle Spieler werden informiert

### 💊 Drogenhandel
- **Drug Runs**: Zu 3 verschiedenen Locations
- **Verkauf**: Marijuana, Kokain, Meth, Opium
- **Preise**: Dynamische Preise ($150-1200 pro Einheit)
- **Gang Cut**: 10% geht automatisch in Gang Bank

### 🔫 Waffenhandel
- **Waffenshop**: Pistolen, SMGs, Gewehre, Sniper
- **Rang-basiert**: Höhere Ränge = bessere Waffen
- **Preise**: $1,500 - $25,000
- **Waffenlager**: Storage System für Gang-Waffen

### 🚗 Gang Fahrzeuge
- **Gang-spezifische Autos**: Jede Gang hat eigene Fahrzeuge
- **Vagos**: Tornado, Buccaneer, Voodoo
- **Ballas**: Emperor, Blade, Buccaneer2
- **Families**: Greenwood, Glendale, Manana
- **Spawning**: Rang 2+ kann Fahrzeuge spawnen

### 🎨 Design Features
- **Rotes Design**: Konsistent mit Police/Ambulance
- **Multi-Color**: Verschiedene Farben für verschiedene Sektionen
- **Gang Patterns**: Spezielle Background-Patterns
- **Responsive UI**: Mobile-friendly Design
- **Animationen**: War-Pulse Effekte, Hover-Animationen

## Installation

### 1. Script Installation
```bash
# Kopiere den esx_gangs Ordner in deinen resources Ordner
cp -r esx_gangs [dein-server]/resources/[esx]/
```

### 2. Database Setup
```sql
-- Führe database.sql in deiner MySQL Datenbank aus
-- Erstellt alle notwendigen Tabellen und Default-Daten
```

### 3. Server Configuration
```lua
-- Füge zu deiner server.cfg hinzu:
ensure esx_gangs

-- Stelle sicher, dass es nach ESX geladen wird:
ensure es_extended
ensure esx_gangs
```

### 4. Dependencies
- **es_extended**: ESX Framework
- **oxmysql**: MySQL Resource für FiveM

## Nutzung

### Controls
- **F6**: Gang Menu öffnen (nur Gang-Mitglieder)
- **ESC**: Menu schließen

### Gang Beitritt
1. Einladung von Gang-Mitglied (Rang 3+) erhalten
2. **Y** drücken um anzunehmen, **N** um abzulehnen
3. Automatischer Rang 1 (Neuling)

### Gang Ränge & Berechtigungen
- **Rang 1 (Neuling)**: Grundfunktionen, Drug Sales
- **Rang 2 (Mitglied)**: Fahrzeuge spawnen, Territory Angriffe
- **Rang 3 (Veteran)**: Spieler einladen, Waffen kaufen, Geld abheben
- **Rang 4 (Leutnant)**: Spieler kicken, Waffen upgraden
- **Rang 5 (Boss)**: Alle Funktionen, Gang Wars starten

### Territory System
- **Territorien angreifen**: Kostet $10,000, dauert 5 Minuten
- **Erfolgsrate**: 60% base + 5% pro zusätzlichem Mitglied
- **Einkommen**: Stündliche Zahlung an Gang Bank
- **Cooldown**: 1 Stunde zwischen Angriffen

### Gang Wars
- **Nur Boss** kann Gang Wars starten
- **Dauer**: 30 Minuten
- **Cooldown**: 2 Stunden nach Ende
- **Minimum**: 3 Mitglieder online erforderlich

## Configuration

### config.lua Anpassungen
```lua
-- Neue Gang hinzufügen
Config.Gangs['new_gang'] = {
    name = 'Neue Gang',
    color = {255, 0, 0}, -- RGB Farbe
    vehicles = {'vehicle1', 'vehicle2'},
    hq = {x = 0.0, y = 0.0, z = 0.0},
    blip = {sprite = 84, color = 1}
}

-- Territorium hinzufügen
table.insert(Config.Territories, {
    id = 9,
    name = 'Neues Territorium',
    coords = {x = 0.0, y = 0.0, z = 0.0},
    radius = 200.0,
    income = 600,
    default_owner = nil
})

-- Waffen anpassen
Config.GangWeapons['new_weapon'] = {
    name = 'Neue Waffe',
    weapon = 'WEAPON_HASH',
    price = 10000,
    ammo = 100,
    rank_required = 4
}
```

### Gang-spezifische Fahrzeuge
```lua
-- In config.lua bei Config.Gangs
vehicles = {'model1', 'model2', 'model3', 'model4'}
```

### Einkommen & Belohnungen anpassen
```lua
Config.ActivityRewards = {
    drug_sale = {min = 100, max = 500},
    territory_capture = {min = 5000, max = 15000},
    gang_war_participation = {min = 1000, max = 3000}
}
```

## Database Tables

### gangs
Haupt-Gang Tabelle mit Bank, Statistiken, Leader

### gang_members
Alle Gang-Mitglieder mit Rang, Experience, Statistiken

### gang_territories
Alle Territorien mit Besitzer, Einkommen, Status

### gang_wars
Alle Gang Wars mit Dauer, Gewinner, Teilnehmer

### gang_activities
Komplettes Aktivitäts-Log aller Gang-Aktionen

### gang_vehicles
Gespawnte Gang-Fahrzeuge tracking

### gang_bank_transactions
Alle Bank-Transaktionen mit Balance-Historie

### gang_drug_operations
Drogenhandel-Logs mit Locations und Preisen

### gang_weapon_transactions
Waffenkäufe/-verkäufe tracking

### gang_alliances
Gang-Allianzen, Truces, War-Status

## Gang Management

### Als Gang-Boss
```lua
-- Gang erstellen (Admin-Befehl)
/creategang [gangname] [playerId]

-- Gang auflösen
/deletegang [gangname]

-- Spieler zu Gang hinzufügen
/addtogang [playerId] [gangname]

-- Spieler aus Gang entfernen
/removefromgang [playerId]
```

### Automatische Systeme
- **Stündliches Einkommen**: Territorien zahlen automatisch
- **Gehälter**: Automatische Gehaltszahlungen
- **Territory Cooldowns**: Automatische Cooldown-Verwaltung
- **War Timers**: Automatische War-Beendigung

## Events & Triggers

### Client Events
```lua
-- Gang Menu öffnen
TriggerEvent('esx_gangs:openMenu')

-- Gang Info aktualisieren
TriggerClientEvent('esx_gangs:setPlayerGang', source, gang, rank)

-- Territory Updates
TriggerClientEvent('esx_gangs:updateTerritories', source, territories)

-- Gang War benachrichtigungen
TriggerClientEvent('esx_gangs:gangWarStarted', source, gang1, gang2)
```

### Server Events
```lua
-- Spieler einladen
TriggerServerEvent('esx_gangs:invitePlayer', targetId, gang)

-- Territorium angreifen
TriggerServerEvent('esx_gangs:attackTerritory', territoryId, gang)

-- Gang War starten
TriggerServerEvent('esx_gangs:startGangWar', gang1, gang2)

-- Drug Run starten
TriggerServerEvent('esx_gangs:startDrugRun', gang)
```

## Integration

### Mit anderen Scripts
```lua
-- ESX Job Integration
-- Gangs können als Jobs behandelt werden
exports.esx_gangs:getPlayerGang(playerId)
exports.esx_gangs:isPlayerInGang(playerId, gang)

-- Police Integration
-- Polizei kann Gang-Aktivitäten überwachen
exports.esx_gangs:getActiveWars()
exports.esx_gangs:getGangMembers(gang)
```

### Webhook Integration
```lua
-- Discord Webhooks für Gang-Events
Config.Webhooks = {
    gang_wars = 'YOUR_WEBHOOK_URL',
    territory_captures = 'YOUR_WEBHOOK_URL',
    major_events = 'YOUR_WEBHOOK_URL'
}
```

## Performance

### Optimierungen
- **Async Database Queries**: Alle DB-Operationen sind async
- **Efficient Blip Management**: Dynamische Blip-Updates
- **Cooldown System**: Verhindert Spam und Server-Last
- **Automatic Cleanup**: Alte Daten werden bereinigt

### Server Load
- **Low Impact**: Optimiert für hohe Spielerzahlen
- **Caching**: Häufig verwendete Daten werden gecached
- **Event-driven**: Nur Updates bei Änderungen

## Troubleshooting

### Häufige Probleme

1. **Gang Menu öffnet sich nicht**
   - Prüfe ob Spieler in Gang ist
   - Console auf Lua-Fehler prüfen
   - F6 Key binding prüfen

2. **Territory Wars funktionieren nicht**
   - Database Territories prüfen
   - Coordinates validieren
   - Gang ownership prüfen

3. **Drug Sales funktionieren nicht**
   - Item-Namen in Database prüfen
   - Inventory System Kompatibilität
   - Drug locations validieren

4. **Blips zeigen nicht**
   - Client-side Territory updates prüfen
   - Blip sprite/color settings
   - Player gang status validieren

## Advanced Features

### Experience System
```lua
-- Automatisches Ranking basierend auf Experience
Config.ExperienceSystem = {
    enabled = true,
    rank_requirements = {
        [2] = 100,  -- Member
        [3] = 500,  -- Veteran
        [4] = 1500, -- Lieutenant
        [5] = 5000  -- Boss
    }
}
```

### Alliance System
```lua
-- Gang-Allianzen erstellen
/createalliance [gang1] [gang2]

-- Truce zwischen Gangs
/createtruce [gang1] [gang2] [duration]
```

### Statistics Dashboard
- **Gang Performance**: Wins/Losses, Territory control
- **Member Stats**: Individual member performance
- **Financial Reports**: Income/Expenses tracking
- **Activity Logs**: Detailed activity timeline

## Credits

- **Framework**: ESX Legacy
- **Design**: Modern Gang Theme mit Multi-Color
- **Icons**: FontAwesome Gang Icons
- **Database**: MySQL optimiert für Performance
- **Territory System**: Advanced zone detection

Entwickelt für deutsche FiveM Server mit ESX Framework.

## Support

Bei Problemen:
1. Console-Logs prüfen
2. Database-Verbindung testen
3. Gang member status validieren
4. Config-Einstellungen prüfen
5. Event-Triggers testen

**Kompatibel mit ESX Legacy und älteren ESX Versionen.**