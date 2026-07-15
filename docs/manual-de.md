# Bedienungsanleitung — Air Quality Monitor

**Sprache:** Deutsch · **Language:** [English version →](manual-en.md)

Diese Anleitung erklärt, was jede Anzeige und jeder Regler in der Web-UI und in Home Assistant bedeutet, was er misst, wann Du ihn ändern willst und was passiert wenn Du das tust. Sie ist für Nutzer geschrieben, die das Gerät bedienen möchten ohne die technischen Datenblätter lesen zu müssen.

Wenn Du wissen willst *wie* das Gerät gebaut wird oder *warum* eine bestimmte Schwelle gerade so gewählt ist — dann schau in die [README](../README.md) für den Bau und in die [AQI-Bemessungsgrundlage](aqi-basis.md) für die Quellen der Schwellenwerte.

## Inhaltsverzeichnis

1. [Einstieg: Was misst das Gerät?](#einstieg-was-misst-das-gerät)
2. [Das Ampel-System (AQI)](#das-ampel-system-aqi)
3. [Kalibrierung — wann und warum](#kalibrierung--wann-und-warum)
4. [Anzeigen im Detail](#anzeigen-im-detail)
5. [Einstellungen für den Sensor SCD41 (CO₂, Temperatur, Luftfeuchte)](#einstellungen-für-den-sensor-scd41-co-temperatur-luftfeuchte)
6. [Einstellungen für den Sensor PMS5003 (Feinstaub)](#einstellungen-für-den-sensor-pms5003-feinstaub)
7. [Display-Einstellungen](#display-einstellungen)
8. [Nachtmodus](#nachtmodus)
9. [System-Funktionen](#system-funktionen)
10. [Diagnose-Werte](#diagnose-werte)
11. [Häufige Fragen](#häufige-fragen)

---

## Einstieg: Was misst das Gerät?

Das Gerät misst vier Dinge, aus denen sich zusammen ein Bild Deiner Innenraumluft ergibt:

| Was | Warum es zählt |
|---|---|
| **CO₂ (Kohlendioxid)** | Steigt in geschlossenen Räumen durch die Atmung an. Zu viel CO₂ macht müde, unkonzentriert, und ist der Hauptgrund, warum man „stickige" Luft bemerkt. Draußen sind es rund 420 ppm, drinnen sollten es unter 1000 ppm sein. |
| **PM 1.0, PM 2.5, PM 10 (Feinstaub)** | Kleine Partikel in der Luft. Je kleiner, desto tiefer gelangen sie in die Lunge. Entstehen beim Kochen, Kerzen, Rauchen, aber auch durch Straßenverkehr von draußen. |
| **Temperatur** | Selbsterklärend, aber wichtiger als man denkt für die Feuchte-Bewertung. |
| **Luftfeuchtigkeit** | Zu trocken → Schleimhäute reizen und Atemwegs­infekte begünstigen. Zu feucht → Schimmelgefahr. Wohlfühl­bereich: 40–60 %. |

Zwei physikalische Sensoren tun die Arbeit:

- Der **SCD41** von Sensirion misst CO₂, Temperatur und Luftfeuchte per Infrarot-Absorption. Das ist ein hochwertiger Sensor mit ±40 ppm Genauigkeit.
- Der **PMS5003** von Plantower misst Feinstaub per Laserstreulicht. Er hat einen kleinen Lüfter, den Du leise hören kannst — der saugt Raumluft durch die Messkammer.

Alle anderen Werte in der Web-UI werden aus diesen gemessenen Werten berechnet.

---

## Das Ampel-System (AQI)

„AQI" steht für **Air Quality Index** — Luftqualitäts-Index. Das Gerät berechnet für jede Messgröße getrennt eine Klasse von **0 bis 4**:

| Klasse | Deutsch | Englisch | Farbe |
|---|---|---|---|
| **0** | TOP | TOP | grün |
| **1** | GUT | GOOD | blaugrün |
| **2** | MITTEL | FAIR | gelb |
| **3** | SCHLECHT | POOR | orange |
| **4** | KRITISCH | CRITICAL | rot |

Die schlechteste Einzelklasse bestimmt die **Gesamt-Bewertung** („AQI Overall Score"). Das ist bewusst konservativ: wenn eine Messgröße kritisch ist, muss man handeln, auch wenn die anderen drei perfekt aussehen.

Die Schwellwerte kommen aus veröffentlichten Standards (WHO 2021, Pettenkofer 1858, DIN EN ISO 7730). Details in [aqi-basis.md](aqi-basis.md).

Praxis-Beispiele:

- Nach dem Aufstehen im Schlafzimmer: **CO₂ oft 1200–1800 ppm**, Klasse 2–3 → Fenster auf.
- Beim Kochen (Braten): **PM 2.5 kurz 50–200 µg/m³**, Klasse 4 → Dunstabzug an, danach lüften.
- Kerze angezündet: **PM 2.5 direkt 100+ µg/m³**, Klasse 4 → Auspusten produziert noch mehr Rauch als das Brennen selbst.
- Winter bei Heizung: **Luftfeuchte oft 25–30 %**, Klasse 2 → Wäsche im Raum aufhängen oder Pflanzen.

---

## Kalibrierung — wann und warum

Der SCD41 ist bei der Auslieferung schon vor-kalibriert. Aber es gibt zwei Situationen, in denen Du selbst kalibrieren solltest:

**1. Wenn die angezeigte Temperatur zu hoch ist.**

Der SCD41-Chip sitzt im Gehäuse zusammen mit dem ESP32, der ihn leicht aufwärmt. Deshalb liest der Sensor **typisch 2–6 °C zu warm** gegenüber der echten Raumluft. Das kannst Du mit der Einstellung **Temperature Offset** korrigieren.

**2. Wenn die CO₂-Werte langfristig ungenau werden.**

CO₂-Sensoren driften mit der Zeit. Der SCD41 hat eine automatische Nachkalibrierung (ASC), die den niedrigsten Wert der letzten 7 Tage als „Frischluft = 400 ppm" annimmt. Das funktioniert nur, wenn Dein Raum regelmäßig gelüftet wird. Wenn er das nie tut, kannst Du manuell mit **Force Recalibration Now** kalibrieren.

Für beide Fälle gibt es die passenden Einstellungen weiter unten in der SCD41-Sektion. Wenn Du unsicher bist: **die Werkseinstellung reicht für normale Anwendung.**

---

## Anzeigen im Detail

Diese Werte werden gemessen und angezeigt. Du kannst sie nicht direkt beeinflussen, aber sie sind die Grundlage aller Bewertungen.

### CO2

**Was steht da:** Kohlendioxid-Konzentration in ppm (parts per million, Teile pro Million).

**Was ist normal:**
- Draußen frische Luft: ~420 ppm (Stand 2026, steigt langsam)
- Drinnen gut gelüftet: 500–700 ppm
- Normale Wohnraumluft: 700–1000 ppm
- Erhöht: 1000–1400 ppm (Konzentration lässt nach)
- Schlecht: 1400–2000 ppm (spürbar müde, Kopfschmerzen möglich)
- Kritisch: über 2000 ppm

**Wann Du handelst:** Bei über 1000 ppm Fenster für 5 Minuten auf, Stoßlüftung.

### Room Temperature (Raumtemperatur)

**Was steht da:** Die vom Sensor gemessene Lufttemperatur in Grad Celsius, bereits **korrigiert** um den Temperature Offset.

Beispiel: Wenn der Sensor-Chip roh 30 °C misst und Du hast den Offset auf 4.0 °C eingestellt, wird 26 °C angezeigt.

**Wann Du handelst:** Wenn der angezeigte Wert nicht zu einem Referenz-Thermometer im gleichen Raum passt, den Temperature Offset anpassen (siehe unten).

### Humidity (Luftfeuchtigkeit)

**Was steht da:** Relative Luftfeuchtigkeit in Prozent.

**Was ist normal:**
- Wohlfühlbereich: 40–60 %
- Winter mit Heizung: oft nur 25–35 % (zu trocken)
- Nach dem Duschen im Bad: kurz 70–90 % (zu feucht, aber normal, lüftet sich)
- Schimmel-Gefahrenbereich: dauerhaft über 65–70 %

**Wann Du handelst:** Bei dauerhaft unter 30 % Luftbefeuchter oder Wäsche im Raum aufhängen; bei dauerhaft über 65 % nach der Ursache suchen und lüften.

### PM 1.0, PM 2.5, PM 10 (Feinstaub-Massen)

**Was steht da:** Wie viel Feinstaub in der Luft ist, in Mikrogramm pro Kubikmeter (µg/m³), aufgeteilt nach Partikelgröße:

- **PM 1.0** — sehr kleine Partikel (bis 1 Mikrometer). Diese sind gesundheitlich am relevantesten, weil sie am tiefsten in die Lunge gelangen. Entstehen vor allem bei Verbrennung (Kochen, Kerzen, Rauch, Straßenverkehr).
- **PM 2.5** — kleine Partikel (bis 2,5 Mikrometer). Enthält PM 1.0 und alles bis 2,5 µm. Der wichtigste Wert für die Ampel.
- **PM 10** — Grobstaub (bis 10 Mikrometer). Blütenpollen, aufgewirbelter Hausstaub, Straßenaerosole.

**Was ist normal (Innenraum, kein aktives Ereignis):**
- Alle drei Werte: unter 5 µg/m³, oft 0 µg/m³ bei sauberer Luft.

**Was ist ein Alarmsignal:**
- PM 2.5 über 15 µg/m³ länger als kurz → Quelle suchen
- PM 2.5 über 37 µg/m³ → Luftreiniger einschalten, Fenster zu wenn draußen die Quelle ist

**Hinweis zur Auflösung:** Der PMS5003 kann laut Datenblatt nicht feiner als 1 µg/m³ unterscheiden, und im Bereich 0–10 µg/m³ hat er ±10 µg/m³ Toleranz. Ein Wert von „0" heißt also nicht garantiert 0, aber „nach Sensor-Auflösung nicht messbar". Deshalb gibt es zusätzlich die Partikelzahlen (nächster Abschnitt).

### Particles > 0.3 / 0.5 / 1.0 / 2.5 / 5.0 / 10 µm (Partikelzahlen)

**Was steht da:** Die **Anzahl** einzelner Partikel oberhalb der jeweiligen Größe, in „Partikel pro 0,1 Liter Luft" (pcs/0.1L).

Warum wichtig: Die Massenwerte oben (µg/m³) unterschätzen kleine Partikel systematisch, weil ein einzelnes 10-µm-Partikel gewichtsmäßig etwa so viel wiegt wie **40.000 Partikel à 0,3 µm**. Wenn nur die Massen angezeigt würden, könnten wir übersehen, dass viele feine Partikel da sind.

**Praktisches Beispiel:**

Saubere Wohnraumluft:
- PM 2.5 = 0 µg/m³ (unter Auflösung)
- Particles > 0,3 µm = **200–500** pcs/0.1L (das sind schon eine Menge Partikel, sie sind nur zu leicht)

Kerze in 1 m Abstand:
- PM 2.5 kann auf 400 µg/m³ springen
- Particles > 0,3 µm kann auf **60.000+** pcs/0.1L springen

**Was ist normal:** Für die kleinste Größe (> 0.3 µm) einige hundert bis tausend pcs/0.1L in Innenräumen. Die Zahlen fallen mit größeren Klassen stark ab: > 2,5 µm sind es oft 0–5 pcs/0.1L in sauberer Luft.

### AQI-Scores (fünf Werte)

Alle fünf sind abgeleitet und nicht direkt bearbeitbar:

- **AQI CO2 Score** — Klasse 0–4 für den aktuellen CO₂-Wert
- **AQI Humidity Score** — Klasse 0–4 für die Luftfeuchte
- **AQI PM2.5 Score** — Klasse 0–4 für Feinstaub PM 2.5
- **AQI PM10 Score** — Klasse 0–4 für Grobstaub PM 10
- **AQI Overall Score** — die schlechteste der obigen vier

### Air Quality Verdict (Luftqualität-Urteil)

**Was steht da:** Ein Wort — TOP, GUT, MITTEL, SCHLECHT oder KRITISCH — das der AQI-Overall-Klasse entspricht. Auf Englisch: TOP, GOOD, FAIR, POOR, CRITICAL. Die Sprache folgt der Language-Einstellung.

### Air Quality Action (Luftqualität-Empfehlung)

**Was steht da:** Ein kurzer Handlungshinweis auf Basis der schlechtesten Einzelmessung. Beispiele:

- „alles gut" (wenn alles Klasse 0)
- „Fenster auf!" (bei kritischem CO₂)
- „Reiniger MAX!" (bei kritischem Feinstaub)
- „zu feucht, lueften"
- „zu trocken"

### Dust Action (Feinstaub-Empfehlung)

**Was steht da:** Ein spezifischer Hinweis nur zum Feinstaub, unabhängig von CO₂ oder Feuchte. Beispiele:

- „alles sauber"
- „leicht erhoeht"
- „Quelle? (Kochen?)"
- „Luftreiniger an!"
- „Reiniger MAX, zu!" (Reiniger auf Maximum, Fenster zu)

---

## Einstellungen für den Sensor SCD41 (CO₂, Temperatur, Luftfeuchte)

Diese Werte kannst Du anpassen.

### Temperature Offset (Temperatur-Korrektur)

**Was macht das:** Zieht einen festen Wert von der roh gemessenen Temperatur ab. Formel im Sensor: `Anzeige = Rohwert − Offset`.

**Wann Du das änderst:** Wenn Dein Sensor eine andere Temperatur zeigt als ein Referenz-Thermometer im gleichen Raum.

**Wie herum:**
- Der Sensor zeigt **zu warm** → Offset **erhöhen** (z.B. von 4,0 auf 6,5)
- Der Sensor zeigt **zu kalt** → Offset **verringern** (z.B. von 4,0 auf 2,5)

**Beispiel:** Sensor zeigt 32 °C, Dein Referenzthermometer zeigt 27 °C. Differenz: 5 °C zu warm. Alten Offset (z.B. 4,0) plus 5 = **neuer Offset 9,0 °C**.

**Werkswert:** 4,0 °C (Sensirion-Werksdefault, passt für viele Bauformen)

**Bereich:** 0–20 °C in 0,1 °C Schritten (Eingabe als Textfeld, feine Werte wie 9,5 sind möglich)

**Was passiert nach dem Ändern:**
- Nach etwa 5 Sekunden erste neue Messung
- Nach 30–60 Sekunden pendelt sich der Wert wirklich ein (der Sensor mittelt intern)
- Der neue Offset wird beim ESP im NVS gespeichert, überlebt also einen normalen Reboot

**Wichtig zu wissen:** Änderungen werden nur im ESP-Speicher gespeichert, nicht direkt im Sensor-EEPROM. Für dauerhafte Speicherung *im Sensor selbst* die Schaltfläche „Save Offset to Sensor EEPROM" drücken (siehe unten).

### Altitude (m) — Höhe über Meer

**Was macht das:** Die CO₂-Messung ist druckabhängig. In höheren Lagen ist die Luft dünner, deshalb misst der Sensor systematisch zu wenig. Die Angabe der Höhe erlaubt dem Sensor, das intern zu korrigieren.

**Wann Du das änderst:** Einmalig nach der Erstinbetriebnahme, wenn Du weißt, wie hoch über dem Meer Du wohnst (Google „Höhe über Meer" plus Deine Stadt).

**Ungefähre Auswirkung:**
- Meereshöhe (0 m): kein Korrekturbedarf
- 500 m Höhe: ohne Korrektur liegen die Werte um ca. 1,5 % zu tief
- 1000 m: ca. 3 % zu tief
- 2000 m (Berghütte): ca. 6 % zu tief

**Werkswert:** 0 m

**Bereich:** 0–3000 m

**Beispiel:** Wenn Du in München wohnst (Stadtzentrum ~520 m), setze den Wert auf 520.

### Reference CO2 (ppm) — Referenzwert für die manuelle Kalibrierung

**Was macht das:** Speichert den CO₂-Wert, gegen den sich der Sensor beim nächsten Drücken von „Force Recalibration Now" neu einnorden soll.

**Wann Du das änderst:** Nur wenn Du eine manuelle CO₂-Kalibrierung durchführen willst — also Gerät ins Freie mitnehmen (oder an einen gut gelüfteten Ort) und dem Sensor sagen „hier ist gerade 420 ppm, rechne den Nullpunkt entsprechend um".

**Werkswert:** 420 ppm — der weltweite Frischluft-Wert (Stand 2026, in urbanen Gegenden eher 430, ländlich 410).

**Wenn Du unsicher bist:** Lass ihn auf 420. Für 99 % der Kalibrier-Situationen ist das der richtige Wert.

### Auto Calibration (ASC) — Automatische Selbstkalibrierung

**Was macht das:** Wenn ASC eingeschaltet ist, sucht der Sensor den **niedrigsten** CO₂-Wert der letzten 7 Tage und nimmt an: „Das muss Frischluft gewesen sein → 400 ppm." Dann korrigiert er sich intern.

**Wann Du das lassen willst:** In den meisten Wohnungen, die regelmäßig gelüftet werden (mindestens einmal die Woche). Der Sensor bleibt so über Monate genau, ohne dass Du etwas tun musst.

**Wann Du das abschalten willst:**
- Ein Raum, der nie gelüftet wird (z.B. Serverraum, geschlossenes Büro über ein langes Wochenende)
- Ein Raum mit dauerhaft erhöhtem CO₂ (z.B. Gewächshaus)

Wenn ASC in einem solchen Raum eingeschaltet ist, denkt der Sensor irgendwann, der niedrigste Wert (z.B. 800 ppm) sei Frischluft und rechnet ihn auf 400 herunter. Danach liest der Sensor **permanent 400 ppm zu wenig** an. In dem Fall lieber ASC aus und einmal manuell kalibrieren.

**Werkswert:** Eingeschaltet.

### Save Offset to Sensor EEPROM (Schaltfläche)

**Was macht das:** Speichert die aktuelle Temperature-Offset-Einstellung dauerhaft **im Sensor-Chip selbst** (in dessen EEPROM). Ohne diese Aktion wird der Offset nur im ESP gespeichert.

**Wann Du das drückst:** Wenn Du sicher bist, dass der aktuelle Offset gut passt, und ihn auch nach einem Firmware-Neuflash (der den ESP-Speicher komplett löschen könnte) im Sensor behalten willst.

**Nicht oft drücken:** Der Sensor-EEPROM verträgt laut Hersteller nur etwa 2000 Schreibvorgänge. Ein bewusster einmaliger Klick pro Kalibrier-Session ist genau richtig. Nicht bei jeder kleinen Änderung.

### Force Recalibration Now (Schaltfläche)

**Was macht das:** Löst eine manuelle Kalibrierung aus. Der Sensor nimmt an: „Der aktuelle Rohwert entspricht dem Wert im Feld Reference CO2." Interne Nullpunkt-Verschiebung entsprechend.

**Der richtige Ablauf:**
1. Gerät ins Freie mitnehmen (schattig, weg von befahrenen Straßen, weg von Personen — auch der ausatmenden eigenen Person, min. 2 m Abstand)
2. Warten. Der Sensor braucht **mindestens 3 Minuten**, bis die Messwerte stabil sind
3. Sicherstellen dass „Reference CO2" auf einem sinnvollen Wert steht (420 ppm ist Standard)
4. „Force Recalibration Now" drücken
5. Ein paar Minuten warten. Der CO₂-Wert sollte sich Deinem Referenzwert annähern

**Fehlermöglichkeit:** Wenn der Sensor nicht mindestens 3 Minuten lief bevor Du drückst, ignoriert er die Kalibrierung. Kein Fehler, aber Wirkungslos.

### Reset Sensor Calibration (Schaltfläche)

**Was macht das:** Setzt **alle** Kalibrier-Einstellungen des SCD41 auf Werkszustand zurück:
- Temperature Offset → 4,0 °C
- Altitude → 0 m
- ASC → eingeschaltet
- Reference CO2 → 420 ppm
- Interne Chip-Kalibrierhistorie → gelöscht

Der Sensor ist danach nicht mehr von einem frisch ausgepackten unterscheidbar.

**Wann Du das drückst:** Wenn Du bei der Kalibrierung etwas verstellt hast und nicht mehr weißt was, oder wenn Du das Gerät an jemand anderen weitergibst und ihm einen sauberen Startpunkt geben willst.

**Was NICHT gelöscht wird:** WLAN-Einstellungen, Display-Einstellungen, Nachtmodus-Zeiten. Wenn Du wirklich alles auf Anfang setzen willst, drücke „Factory Reset" in der System-Gruppe.

---

## Einstellungen für den Sensor PMS5003 (Feinstaub)

### PMS5003 Active (Schalter)

**Was macht das:** Schaltet den Feinstaub-Sensor ein oder aus. Aus heißt: der Lüfter im Sensor stoppt und die Laser-Messung pausiert. Der Sensor braucht dann nur noch ca. 2 mA Strom statt ~100 mA.

**Wann Du das änderst:** Selten. Nutzt evt. Sinn wenn Du für ein paar Minuten Ruhe willst (leises Lüftergeräusch). Für den Alltag: lassen.

**Werkswert:** Eingeschaltet.

### PMS5003 Restart (Schaltfläche)

**Was macht das:** Startet den Sensor neu (kurz aus, dann wieder an). Kann helfen wenn die Werte hängen bleiben oder nach längerer Zeit unplausibel werden.

**Wichtig:** Nach dem Neustart braucht der Sensor ca. **30 Sekunden Warmup**, bevor die ersten Werte stabil sind.

---

## Display-Einstellungen

### Display Brightness (Helligkeit)

**Was macht das:** Regelt die Helligkeit des OLED-Displays von 0 bis 100 Prozent. 0 heißt: Display ist an, aber komplett schwarz.

**Werkswert:** 50 % (angenehm für die meisten Räume, nicht zu grell im Dunkeln)

**Wenn Du das änderst:** Auf 100 % für sehr helle Umgebungen (direkte Sonne), auf 20–30 % für Nachttisch-Bereiche.

### Display Rotation (Drehung)

**Was macht das:** Dreht die Anzeige in 90°-Schritten (0°, 90°, 180°, 270°). Damit kannst Du das Display in Deinem Gehäuse in jede Richtung ausrichten.

**Werkswert:** 0° (Standard).

### Display Power (Schalter)

**Was macht das:** Schaltet das Display komplett aus (Panel-Treiber deaktiviert, nicht nur schwarze Pixel). Spart etwa 15 mA und schont das OLED vor Einbrennen.

**Werkswert:** Eingeschaltet.

**Wann Du das ausschaltest:** Wenn Du das Gerät nur als HA-Sensor nutzt und nicht auf das Display schauen willst.

### Display Refresh (Schaltfläche)

**Was macht das:** Forciert ein sofortiges Neuzeichnen des Displays. Normalerweise nicht nötig — nur zum Testen wenn etwas komisch aussieht.

---

## Nachtmodus

Blanks das Display in einem konfigurierbaren Zeitfenster, während die Sensoren weiter messen. Praktisch für Schlafzimmer.

### Night Mode Enabled (Schalter)

**Was macht das:** Aktiviert oder deaktiviert die zeitgesteuerte Display-Abschaltung.

**Werkswert:** Aus. Aktivieren wenn Du das Gerät nachts nicht leuchten sehen willst.

### Night Mode Start / Night Mode End (Zeitfelder)

**Was macht das:** Legt fest, in welchem Zeitraum der Nachtmodus aktiv ist. Das Fenster darf über Mitternacht laufen (z.B. Start 22:00, Ende 07:00).

**Vorschlag:** 22:00 – 07:00 für ein normales Schlafzimmer.

**Wenn Start = Ende:** Nachtmodus wird nie aktiv.

**Was in dieser Zeit passiert:** Display ist komplett aus. Sensoren laufen weiter, Home-Assistant-History bleibt lückenlos.

---

## Sprache

### Language (Auswahl)

**Was macht das:** Schaltet die Sprache aller Anzeigetexte um — sowohl auf dem OLED-Display als auch bei den Bewertungs-Texten in Home Assistant und der Web-UI.

**Optionen:** English, Deutsch

**Was betroffen ist:**
- Wörter wie „TOP" / „GUT" / „MITTEL" / „SCHLECHT" / „KRITISCH" ↔ „GOOD" / „FAIR" / „POOR" / „CRITICAL"
- Handlungshinweise wie „Fenster auf!" ↔ „Open window!"
- Feinstaub-Hinweise wie „staubfrei" ↔ „dust-free"
- Datum-Formate auf dem Display (DE: 07.07.2026 vs. EN: 2026-07-07)

**Was NICHT betroffen ist:**
- Die Namen der Einstellungen selbst (bleiben englisch, damit Home-Assistant-Automationen nicht kaputt gehen)
- Werte wie CO₂ oder Temperatur (das sind Zahlen, keine Sprache)

**Werkswert:** English.

---

## System-Funktionen

### Restart (Schaltfläche)

**Was macht das:** Startet das Gerät neu. Alle Einstellungen bleiben erhalten (WLAN, Kalibrierung, Nachtmodus).

**Wann Du das drückst:** Wenn irgendwas hängt oder ein Sensorwert nicht mehr aktualisiert wird.

### Restart (Safe Mode) — Neustart im Notfallmodus

**Was macht das:** Startet das Gerät in einem speziellen Modus, in dem es nur die Grundfunktionen lädt (WLAN und Web-Server). Alle Sensoren und das Display bleiben aus.

**Wann Du das drückst:** Wenn nach einem Firmware-Update das Gerät gar nicht mehr richtig startet. Im Safe Mode kannst Du dann ein anderes Firmware-Image hochladen.

### WiFi Reconnect

**Was macht das:** Startet die WLAN-Verbindung neu. Nutzt oft nach einem Router-Wechsel oder Router-Neustart.

### Factory Reset

**Was macht das:** Löscht **alle** vom Nutzer gemachten Einstellungen. Das Gerät ist danach wie fabrikneu:
- WLAN-Zugangsdaten weg → nächstes Mal wieder QR-Code-Onboarding
- Alle Kalibrier-Werte auf Werkszustand
- Display-Einstellungen auf Default
- Nachtmodus-Zeiten auf Default
- Sprache auf English

**Wann Du das drückst:** Wenn Du das Gerät weitergibst oder ganz neu einrichten willst.

**Warnung:** Dies erzeugt keinen „Sind Sie sicher"-Dialog. Ein Klick genügt.

---

## Diagnose-Werte

Diese Werte helfen bei der Fehlersuche, sind aber im Alltag uninteressant.

- **IP Address** — Die Netzwerkadresse des Geräts. Brauchst Du zum Aufruf der Web-UI.
- **SSID** — Der Name des WLANs, in dem das Gerät gerade ist.
- **MAC** — Die eindeutige Hardware-Adresse des Geräts (interessant nur wenn Du sie im Router freigeben willst).
- **WiFi RSSI** — Signalstärke des WLAN-Signals in dBm. −50 ist sehr gut, −70 mittel, −85 grenzwertig, unter −90 fällt die Verbindung ab.
- **Uptime** / **Uptime (human)** — Wie lange das Gerät ohne Neustart läuft.
- **ESPHome Version** — Version der Firmware.
- **Boot Reason** — Warum das Gerät zuletzt neu gestartet ist (Software = normaler Neustart, Brownout = kurze Stromversorgung-Unterbrechung, Panic = ein Firmware-Fehler).
- **CPU Temperature** — Interne Chiptemperatur des ESP32, nicht die Raumtemperatur.
- **Free Heap** / **Max Heap Block** — Freier Arbeitsspeicher in Bytes. Interessant nur bei Firmware-Entwicklung.

Dazu Log-Steuerungs-Buttons:
- **Log INFO (Default)** — normaler Log-Umfang
- **Log DEBUG On** — mehr Details für Fehlersuche
- **Log VERBOSE On** — sehr viele Details, nur kurz aktivieren

---

## Häufige Fragen

**Der Sensor zeigt 0 µg/m³ Feinstaub. Ist er kaputt?**

Vermutlich nicht. Der PMS5003 hat eine Auflösung von 1 µg/m³ und eine Toleranz von ±10 µg/m³ im unteren Bereich. In sauberer Wohnraumluft ist „0" ein normaler und korrekter Wert. Kontroll-Check: die Partikelzahlen (Particles > 0.3 µm) sollten dennoch einen Wert im Bereich einiger hundert zeigen. Falls die auch 0 sind → Sensor prüfen.

**Ich habe den Temperature Offset geändert, aber die Temperatur ändert sich nicht.**

Warte 60 Sekunden. Der Sensor braucht nach jeder Offset-Änderung einige Messzyklen bis er einen stabilen neuen Wert liefert.

**Warum ist die Raumtemperatur so hoch, obwohl es im Raum kühl ist?**

Der Sensor sitzt im Gehäuse, der ESP32 daneben produziert Abwärme. Der Sensor liest deshalb typischerweise 2–6 °C zu warm. Der Temperature Offset korrigiert das. Werkswert ist 4,0 °C, was für viele Gehäuse passt. Wenn Dein Gehäuse besonders klein/geschlossen ist, brauchst Du evtl. 6–9 °C.

**Meine CO₂-Werte gehen nachts nicht runter obwohl ich alleine bin.**

Möglich dass Du Deine Schlafzimmertür geschlossen hast — dann sammelt sich das CO₂ aus Deiner Atmung an. Normal sind über Nacht Werte um 1200–1800 ppm. Nicht gefährlich, aber der Grund warum man morgens „stickige Luft" bemerkt.

**Nach einem Factory Reset sind meine Werte immer noch da.**

Vermutlich hast Du das Gerät noch nicht mit der neuen Firmware neu geflasht, sondern nur den Button gedrückt. Nach einem Factory Reset muss das Gerät sich mit dem WLAN neu verbinden (per QR-Code), und **erst danach** greifen die neuen Werkseinstellungen.

**Kann ich das Gerät im Auto verwenden?**

Grundsätzlich ja, aber der PMS5003 mag keine Erschütterungen und das Betriebstemperatur-Fenster ist begrenzt (-10 bis +60 °C). Nicht in praller Sonne aufs Armaturenbrett legen.

---

*Diese Anleitung wird zusammen mit dem Projekt gepflegt. Wenn etwas unklar ist oder fehlt, [öffne bitte ein Issue auf GitHub](https://github.com/de-sascha/Air-Quality-Index-AQI-ESPHome/issues).*

*[English version →](manual-en.md)*
