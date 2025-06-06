# ESX Police Job Script

Ein vollständiges Police Job Script für ESX Framework mit modernem rotem Design.

## Features

### 👮‍♂️ Police Job System
- **Dienststatus**: Ein-/Ausschalten des Dienstes
- **Fahrzeug System**: Spawnen von verschiedenen Polizeifahrzeugen
- **Spieler Aktionen**: Verhaften, Durchsuchen, Strafen erteilen
- **Kommunikation**: Verstärkung anfordern, Durchsagen
- **Datenbank Integration**: Vollständige Logs aller Aktionen

### 🚗 Fahrzeuge
- Streifenwagen (police)
- Police SUV (police2) 
- Police Motorrad (policeb)
- Police Helikopter (polmav)
- SWAT Van (riot)
- Unmarked SUV (fbi2)

### ⚖️ Spieler Aktionen
- **Verhaften**: Spieler ins Gefängnis schicken
- **Strafen**: Bußgelder mit vordefiniertem Katalog
- **Durchsuchen**: Inventar und Waffen prüfen
- **Ausweis prüfen**: Lizenzen kontrollieren

### 📡 Kommunikation
- **Verstärkung**: Backup mit GPS-Koordinaten anfordern
- **Durchsagen**: Polizei-Ansagen an alle Spieler
- **Funk**: Radio-System (Placeholder)

### 🎨 Design Features
- **Rotes Design**: Wie gewünscht mit rotem Farbschema
- **Moderne UI**: Gradients, Animationen, responsive Design
- **Glasmorphism**: Moderne Blur-Effekte
- **Icons**: FontAwesome Icons für alle Funktionen
- **Animationen**: Smooth transitions und hover effects

## Installation

### 1. Script Installation
```bash
# Kopiere den esx_police Ordner in deinen resources Ordner
cp -r esx_police [dein-server]/resources/[esx]/
```

### 2. Database Setup
```sql
-- Führe database.sql in deiner MySQL Datenbank aus
-- Erstellt alle notwendigen Tabellen für Police System
```

### 3. Server Configuration
```lua
-- Füge zu deiner server.cfg hinzu:
ensure esx_police

-- Stelle sicher, dass es nach ESX geladen wird:
ensure es_extended
ensure esx_police
```

### 4. Dependencies
- **es_extended**: ESX Framework
- **oxmysql**: MySQL Resource für FiveM
- **esx_jail**: Für Verhaftungen (optional)

## Nutzung

### Controls
- **F5**: Police Menu öffnen (nur als Police Job)
- **ESC**: Menu schließen

### Job Requirements
- Spieler muss Police Job haben
- Für manche Aktionen muss Dienststatus aktiv sein

### Berechtigungen
Verschiedene Aktionen erfordern verschiedene Police-Ränge:
- **Rekrut (0)**: Grundfunktionen
- **Beamter (1+)**: Verhaftungen, Strafen
- **Sergeant (2+)**: Fahrzeug-Spawn erweitert
- **Leutnant (3+)**: Alle Features

## Configuration

### Config.lua Anpassungen
```lua
-- Fahrzeuge anpassen
Config.PoliceVehicles = {
    {model = 'police', label = 'Dein Custom Name'},
    -- Füge weitere Fahrzeuge hinzu
}

-- Strafen-Limits anpassen
Config.MaxFineAmount = 50000
Config.MinFineAmount = 1

-- Gefängnis-Zeit anpassen
Config.DefaultJailTime = 300 -- in Sekunden
```

### Sprache anpassen
Alle Texte sind in Config.lua unter `Config.Locales` anpassbar.

## Database Tables

### police_arrests
Speichert alle Verhaftungen mit Officer, Verdächtigem, Zeit, etc.

### police_fines
Alle Strafen mit Betrag, Grund und Bezahlstatus

### police_evidence
Beschlagnahmte Gegenstände und Waffen

### police_vehicles
Gespawnte Police-Fahrzeuge tracking

### police_duty_log
Dienst-Zeiten aller Polizisten

### police_announcements
Alle Polizei-Durchsagen

### police_backup
Verstärkungsanfragen mit Koordinaten

## Troubleshooting

### Häufige Probleme

1. **Menu öffnet sich nicht**
   - Prüfe ob Spieler Police Job hat
   - Console auf Lua-Fehler prüfen

2. **Database Errors**
   - Stelle sicher, dass oxmysql läuft
   - Prüfe Database-Verbindung
   - Führe database.sql komplett aus

3. **Fahrzeuge spawnen nicht**
   - Prüfe ob Fahrzeug-Models existieren
   - Dienststatus muss aktiv sein

4. **NUI nicht sichtbar**
   - Browser-Console auf JavaScript-Fehler prüfen
   - Stelle sicher, dass HTML-Files korrekt geladen werden

## Anpassungen

### Design ändern
- `html/styles.css`: Farben, Layout anpassen
- Hauptfarbe: `#dc2626` (rot) überall ändern

### Neue Features hinzufügen
- `client/client.lua`: Client-seitige Logik
- `server/server.lua`: Server-seitige Logik
- `html/`: UI erweitern

## Support

Bei Problemen:
1. Console-Logs prüfen
2. Database-Verbindung testen
3. Dependencies prüfen
4. Config-Einstellungen validieren

## Credits

- **Framework**: ESX Legacy
- **Design**: Modern Red Theme
- **Icons**: FontAwesome
- **Database**: MySQL/MariaDB

Entwickelt für deutsche FiveM Server mit ESX Framework.