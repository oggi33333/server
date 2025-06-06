# ESX Ambulance Job Script

Ein vollständiges Ambulance/EMS Job Script für ESX Framework mit modernem rotem Design und medizinischen Funktionen.

## Features

### 🚑 Ambulance Job System
- **Dienststatus**: Ein-/Ausschalten des medizinischen Dienstes
- **Fahrzeug System**: Spawnen von Rettungsfahrzeugen und Helikoptern
- **Medizinische Behandlung**: Heilen, Wiederbeleben, Gesundheitschecks
- **Hospital System**: Transport ins Krankenhaus, Rechnungen stellen
- **Kommunikation**: Verstärkung anfordern, Notrufe bearbeiten
- **Vollständige Database Integration**: Logs aller medizinischen Aktionen

### 🚗 Fahrzeuge
- Rettungswagen (ambulance)
- Notarzt Fahrzeug (lguard)
- Rettungshelikopter (polmav)
- Feuerwehr (firetruk)

### ⚕️ Medizinische Aktionen
- **Heilen**: Spieler heilen und Gesundheit wiederherstellen
- **Wiederbeleben**: "Tote" Spieler wiederbeleben
- **Gesundheit prüfen**: Spieler-Status überprüfen
- **Transport**: Patienten ins Krankenhaus bringen
- **Medizinische Items**: Verbände, Medikits, Schmerzmittel, Morphin

### 🏥 Hospital Features
- **Krankenhaus Transport**: Automatischer Transport zu Krankenhäusern
- **Rechnungen stellen**: Behandlungskosten abrechnen
- **Patientenakten**: Behandlungshistorie einsehen
- **Rezepte**: Medikamente verschreiben

### 📡 Kommunikation & Notrufe
- **Verstärkung anfordern**: Backup mit GPS-Koordinaten
- **Notrufe bearbeiten**: Emergency Calls System
- **Durchsagen**: Medizinische Ansagen an alle Spieler
- **Leitstelle**: Dispatch System Integration

### 🎨 Design Features
- **Rotes Design-Schema**: Konsistent mit Police System
- **Moderne UI**: Gradients, Animationen, responsive Design
- **Medizinische Icons**: Speziell angepasste FontAwesome Icons
- **Mehrfarbige Sektionen**: Verschiedene Farben für verschiedene Bereiche
- **Notfall-Animationen**: Pulse-Effekte für kritische Aktionen

## Installation

### 1. Script Installation
```bash
# Kopiere den esx_ambulance Ordner in deinen resources Ordner
cp -r esx_ambulance [dein-server]/resources/[esx]/
```

### 2. Database Setup
```sql
-- Führe database.sql in deiner MySQL Datenbank aus
-- Erstellt alle notwendigen Tabellen für Ambulance System
```

### 3. Server Configuration
```lua
-- Füge zu deiner server.cfg hinzu:
ensure esx_ambulance

-- Stelle sicher, dass es nach ESX geladen wird:
ensure es_extended
ensure esx_ambulance
```

### 4. Dependencies
- **es_extended**: ESX Framework
- **oxmysql**: MySQL Resource für FiveM
- **esx_basicneeds**: Für Heal-Funktionen (optional)

## Nutzung

### Controls
- **F5**: Ambulance Menu öffnen (nur als Ambulance Job)
- **ESC**: Menu schließen

### Job Requirements
- Spieler muss Ambulance Job haben
- Für medizinische Aktionen muss Dienststatus aktiv sein

### Medizinische Behandlungen
- **Heilen**: 5 Sekunden Animation, +75 Gesundheit
- **Wiederbeleben**: 15 Sekunden Animation, vollständige Wiederbelebung
- **Items geben**: Verschiedene medizinische Items mit Heileffekten

### Berechtigungen nach Rang
- **Praktikant (0)**: Grundfunktionen, Heilen
- **Sanitäter (1+)**: Wiederbeleben, Items geben
- **Oberarzt (2+)**: Alle Fahrzeuge, Hospital Transport
- **Arzt (4+)**: Rechnungen stellen, Rezepte
- **Chefarzt (6+)**: Alle Features, Statistiken

## Configuration

### Config.lua Anpassungen
```lua
-- Fahrzeuge anpassen
Config.AmbulanceVehicles = {
    {model = 'ambulance', label = 'Dein Custom Name'},
    -- Füge weitere Fahrzeuge hinzu
}

-- Heilungsmengen anpassen
Config.HealAmount = 75
Config.ReviveHealth = 100

-- Belohnungen anpassen
Config.HealReward = {min = 200, max = 500}
Config.ReviveReward = {min = 500, max = 1000}
```

### Medizinische Items
```lua
Config.MedicalItems = {
    {name = 'bandage', label = 'Verband', healAmount = 20},
    {name = 'medikit', label = 'Medikit', healAmount = 50},
    -- Weitere Items...
}
```

### Krankenhaus Standorte
```lua
Config.HospitalLocations = {
    {
        name = 'Pillbox Hospital',
        coords = vector3(298.6, -584.4, 43.3),
        heading = 70.0
    }
    -- Weitere Standorte...
}
```

## Database Tables

### ambulance_treatments
Alle medizinischen Behandlungen (Heilen, Wiederbeleben, Transport)

### ambulance_bills
Rechnungen für medizinische Behandlungen

### ambulance_items_given
Ausgegebene medizinische Items tracking

### ambulance_deaths
Death/Revive Logs für Statistiken

### ambulance_duty_log
Dienst-Zeiten aller Sanitäter

### ambulance_backup
Verstärkungsanfragen mit Koordinaten

### ambulance_emergency_calls
Notrufe und deren Bearbeitung

### ambulance_statistics
Leistungsstatistiken pro Sanitäter

## Rewards System

### Automatische Belohnungen
- **Heilen**: $200-500
- **Wiederbeleben**: $500-1000
- **Transport**: $300-700

### Behandlungspreise
- **Erste Hilfe**: $250
- **Wiederbelebung**: $500
- **Transport**: $300
- **Operation**: $1500

## Integration mit anderen Scripts

### ESX BasicNeeds
```lua
-- Für Heal-Funktionen
TriggerClientEvent('esx_basicneeds:healPlayer', targetId)
```

### ESX Jail (für Police Integration)
```lua
-- Medizinische Versorgung für Gefangene
TriggerClientEvent('esx_ambulance:jailMedical', targetId)
```

## Troubleshooting

### Häufige Probleme

1. **Heal/Revive funktioniert nicht**
   - Prüfe ob esx_basicneeds läuft
   - Stelle sicher, dass Animationen geladen werden

2. **Items können nicht gegeben werden**
   - Prüfe Inventory System Kompatibilität
   - Stelle sicher, dass Items in der Database existieren

3. **Transport funktioniert nicht**
   - Prüfe Hospital Koordinaten in Config
   - Stelle sicher, dass Teleport-Events funktionieren

4. **Database Errors**
   - Führe database.sql komplett aus
   - Prüfe oxmysql Verbindung

## Anpassungen

### Neue medizinische Items hinzufügen
```lua
-- In config.lua
Config.MedicalItems = {
    {name = 'adrenaline', label = 'Adrenalin', healAmount = 100}
}
```

### Neue Fahrzeuge hinzufügen
```lua
-- In config.lua
Config.AmbulanceVehicles = {
    {model = 'your_custom_ambulance', label = 'Custom Ambulance'}
}
```

### Custom Animations
```lua
-- In config.lua
Config.HealAnimation = {
    dict = 'your_animation_dict',
    anim = 'your_animation',
    duration = 5000
}
```

## API Events

### Client Events
```lua
-- Heilen empfangen
TriggerClientEvent('esx_ambulance:healedPlayer', source, targetName)

-- Wiederbeleben empfangen
TriggerClientEvent('esx_ambulance:revivedPlayer', source, targetName)

-- Item erhalten
TriggerClientEvent('esx_ambulance:receivedMedicalItem', targetId, item, amount)
```

### Server Events
```lua
-- Spieler heilen
TriggerServerEvent('esx_ambulance:healPlayer', targetId)

-- Spieler wiederbeleben
TriggerServerEvent('esx_ambulance:revivePlayer', targetId)

-- Item geben
TriggerServerEvent('esx_ambulance:giveMedicalItem', targetId, item, amount)
```

## Performance

### Optimierungen
- Alle Database Queries sind async
- NUI wird nur bei Bedarf geöffnet
- Animationen werden ordnungsgemäß verwaltet
- Memory Leaks werden verhindert

### Server Load
- Minimale Server-Last durch effiziente Queries
- Caching von häufig verwendeten Daten
- Cleanup bei Player Disconnect

## Credits

- **Framework**: ESX Legacy
- **Design**: Modern Medical Red Theme
- **Icons**: FontAwesome Medical Icons
- **Database**: MySQL/MariaDB optimiert
- **Animations**: GTA V Native Animations

Entwickelt für deutsche FiveM Server mit ESX Framework.

## Support

Bei Problemen:
1. Console-Logs prüfen
2. Database-Verbindung testen
3. Dependencies prüfen
4. Config-Einstellungen validieren
5. Animations-Dictionary laden prüfen

**Kompatibel mit ESX Legacy und älteren ESX Versionen.**