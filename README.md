# CourtConnect 🏀

**Dein Team. Deine Verbindung. Dein Erfolg.**

CourtConnect ist eine innovative App, die Trainer, Spieler und Eltern innerhalb eines Vereins vernetzt. Sie vereinfacht die Organisation und Kommunikation im Teamsport und sorgt für eine reibungslose Zusammenarbeit aller Beteiligten.
Die App bietet Funktionen wie Terminverwaltung, Anwesenheitsmanagement und Benachrichtigungen, damit alle Mitglieder stets informiert bleiben. Mit einem Fokus auf Benutzerfreundlichkeit ermöglicht CourtConnect ein effizientes Teammanagement – egal ob auf oder abseits des Spielfelds.


## Design
Coming soon ...

<p>
  <img src="./img/screen1.png" width="200">
  <img src="./img/screen2.png" width="200">
  <img src="./img/screen3.png" width="200">
</p>


## Features 

- [ ] User-Registrierung und Login: Für Trainer, Spieler und Eltern.
- [ ] Vereinsverwaltung: Trainer können Vereine erstellen und Mitglieder hinzufügen.
- [ ] Terminverwaltung: Trainings und Events erstellen, verwalten und anzeigen lassen.
- [ ] Anwesenheit: Trainer können Teilnehmerlisten erstellen; Spieler und Eltern können Zu- oder Absagen senden.
- [ ] Benachrichtigungen: Spieler werden über Trainings und Änderungen direkt informiert. 


## Technischer Aufbau

#### Projektarchitektur 
Die App verwendet das MVVM-Pattern kombiniert mit einem Repository-Pattern und Service-Pattern für eine klare Trennung von Logik und Datenmanagement.

#### Datenspeicherung
- Auth und User-Management: Firebase Auth wird verwendet, um eine Offline-Authentifizierung zu ermöglichen.
- Backend: Daten werden in Supabase gespeichert und mit SwiftData synchronisiert, um sie persistent und lokal verfügbar zu machen.
- Verschlüsselung: Chat-Nachrichten werden verschlüsselt in Supabase gespeichert und lokal auf dem Gerät entschlüsselt.

#### API Calls
- Supabase wird zusätzlich als API genutzt, z. B. für einen Ping-Test zur Erreichbarkeitsprüfung.
- API-Keys werden von einem privaten Server geladen, um Sicherheit und Flexibilität zu gewährleisten.
- https://api.sandbox.push.apple.com/3/device/<Device> für APNS Notifications

#### 3rd-Party Frameworks
- Supabase
- Firebase
- RNCryptor 
- SwiftLint


## Ausblick 
- [ ] Statitiken für Spieler
- [ ] Statitiken für Teams
- [ ] Multi Membership pro User

## Installation

### Voraussetzungen

#### iOS-App: 
Füge die Datei GoogleService-Info.plist in dein Projekt ein. Diese wird für die Integration von Firebase benötigt. 
Füge eine TokenService struct mit einer static let "pemBasedPrivateKey: String" 

#### Supabase:
Installiere Supabase entweder mit NPM:  
```bash
npm install -g supabase
```

oder mit brew:

```bash
brew install supabase
```

#### Docker:
Stelle sicher, dass Docker installiert und betriebsbereit ist.

#### Server Functions:
Lade die JSON-Datei für Firebase Admin (service-account.json) herunter.
Diese Datei muss sich im Ordner Functions auf dem Server befinden, um serverseitige Firebase-Funktionen korrekt auszuführen.

## Kontakt Informationen  
**Frederik Kohler**  
✉️ [info@frederikkohler.de](mailto:info@frederikkohler.de)
