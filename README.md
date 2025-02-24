# CourtConnect 🏀

**Dein Team. Deine Verbindung. Dein Erfolg.**

CourtConnect ist eine innovative App, die Trainer, Spieler und Eltern innerhalb eines Vereins vernetzt. Sie vereinfacht die Organisation und Kommunikation im Teamsport und sorgt für eine reibungslose Zusammenarbeit aller Beteiligten.
Die App bietet Funktionen wie Terminverwaltung, Anwesenheitsmanagement und Benachrichtigungen, damit alle Mitglieder stets informiert bleiben. Mit einem Fokus auf Benutzerfreundlichkeit ermöglicht CourtConnect ein effizientes Teammanagement – egal ob auf oder abseits des Spielfelds.


## Design  
<p>
  <img src="./images/screenshot/screenshot_light_1.png" width="200">
  <img src="./images/screenshot/screenshot_light_2.png" width="200"> 
  <img src="./images/screenshot/screenshot_light_3.png" width="200">
  <img src="./images/screenshot/screenshot_light_4.png" width="200"> 
</p>

## Präsentation  
<p>
    <a href="./presentation/praesentation_minimized.pdf" target="_blank">
        <img src="./presentation/WasistCourtConnect.jpg" width="1000">
    </a> 
</p>


## ActivityDiagrams  
<p>
    <img src="./images/diagrams/ActivityDiagramClientServer.jpg" style="max-width: 33%;">
    <img src="./images/diagrams/ActivityDiagramServerClient.jpg" style="max-width: 33%;"> 
    <img src="./images/diagrams/ActivityDiagramNotification.jpg" style="max-width: 33%;"> 
</p>


## Features 

- [ ] User-Registrierung und Login: Für Trainer und Spieler.
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
- Supabase Api
- Google Cloud / Firebase Api

#### 3rd-Party Frameworks
- Supabase
- Firebase
- RNCryptor 
- SwiftLint


## Ausblick 
- [ ] Statitiken für Spieler
- [ ] Statitiken für Teams
- [ ] User-Registrierung und Login: Für Eltern.
- [ ] Dokumentate Verwaltung und Bereitstellung für Teams.


## Ordnerstruktur
* **Data:**
    * APIClients: Verwaltung der API-Interaktionen
    * Models: Definition der Datenmodelle
    * Repositories: Datenzugriffsschicht
    * Resources: Zusätzliche Ressourcen (z.B. lokale Daten)
* **Resources:**
    * Assets: Bilder, Icons und andere Assets
    * Theme: Gestaltungselemente (Farben, Schriftarten)
* **Services:**
    * NotificationService: Verwaltung von Push-Benachrichtigungen
    * Util: Hilfsfunktionen und Erweiterungen
* **View:**
    * Components: Wiederverwendbare UI-Komponenten
    * Public: Öffentliche Schnittstellen und APIs
    * SignedIn: Ansichten für angemeldete Benutzer
    * ViewModel: ViewModels zur Datenverwaltung
* **CourtConnect:**
    * AppDelegate: Anwendungskonfiguration
    * CourtConnectApp: Haupt-App-Datei
    * Info: App-Informationen (z.B. Bundle-ID)
    * TokenService: Verwaltung von Authentifizierungstoken
* **Tests:**
    * CourtConnectTests: Unit-Tests
    * CourtConnectUITests: UI-Tests 


## Installation

### Voraussetzungen

#### iOS-App: 
Füge die Datei GoogleService-Info.plist in dein Projekt ein. Diese wird für die Integration von Firebase benötigt. 
In deine Info.plist:
```
    <key>DefaultEnvironment</key>
    <string>Local</string>
    <key>isStoredInMemoryOnly</key>
    <false/>
    <key>SupabaseEnvironments</key>
    <array>
        <dict>
            <key>Name</key>
            <string>Local</string>
            <key>SupabaseKey</key>
            <string>ey...</string>
            <key>SupabaseUrl</key>
            <string>http://192.168.0.178:54321</string>
        </dict>
        <dict>
            <key>Name</key> 
            <string>Remote</string>
            <key>SupabaseKey</key>
            <string>ey...</string>
            <key>SupabaseUrl</key>
            <string>https://......supabase.co</string>
        </dict>
    </array>
```

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
Lade die JSON-Datei für Firebase Admin herunter und benenne sie in service-account.json, und füge diese in "supabase/functions/<EdgeFuncName>/service-account.json" ein.
Diese Datei muss sich im Ordner Functions auf dem Server befinden, um serverseitige Edge-Funktionen korrekt auszuführen.

Usert für mehrere Unique identifier:
```sql
ALTER TABLE public."<UserOnline>" ADD CONSTRAINT "<UserOnline>_<UserOnline>_<deviceToken>_unique" UNIQUE ("<userId>", "<deviceToken>");
```

#### Deployment für den Appstore:
 TrainerAccount:
 email: trainer@user.de
 pw: CourtConnect

 PlayerAccount:
 email: player@user.de
 pw: CourtConnect
 

## Kontakt Informationen  
**Frederik Kohler**  
✉️ [info@frederikkohler.de](mailto:info@frederikkohler.de)
