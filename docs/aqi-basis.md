# AQI-Bemessungsgrundlage

Dieses Dokument erklärt, **wie und woher** die Air-Quality-Klassifizierung
in diesem Projekt kommt. Es richtet sich an Nutzer, Fork-Autoren und
Reviewer, die die eingebauten Schwellwerte und Empfehlungstexte
nachvollziehen wollen, ohne den YAML-Quelltext zu lesen.

Die Kurzfassung — die Vier-Zeilen-Tabelle mit den Schwellen — steht in
der [`README.md`](../README.md#aqi-thresholds). Dieses Dokument ist die
Langfassung mit Quellenangabe und den Empfehlungstexten.

## Prinzip

Vier Metriken werden gemessen und einzeln in fünf Klassen einsortiert:

| Klasse | Bedeutung | Farbe (Konvention) |
|---|---|---|
| 0 | TOP / excellent | grün |
| 1 | GUT / good | blau-grün |
| 2 | MITTEL / fair | gelb |
| 3 | SCHLECHT / poor | orange |
| 4 | KRITISCH / critical | rot |

Der **Overall Score** ist die **schlechteste** der vier Einzelklassen —
nicht das Mittel. Bewusste Entscheidung: bei Luftqualität ist eine
konservative Warnung wichtiger als ein „im Schnitt geht's ja".

**Temperatur wird nicht bewertet.** Der SCD41 sitzt im Gehäuse und
heizt sich durch Eigenverbrauch um 2–6 °C auf; jede Temperatur-Schwelle
würde falsch alarmieren. Der Wert wird zwar angezeigt, aber nicht in
den AQI eingerechnet.

---

## Schwellen und ihre Quellen

### CO₂ (ppm)

| Klasse | ppm | Herkunft |
|---|---|---|
| 0 | < 800 | Frischluftniveau, unstrittig |
| 1 | 800–1000 | Pettenkofer-Grenzwert 1000 ppm — seit 1858 der Standard-Referenzwert für „gerade noch akzeptable" Innenraumluft, übernommen in DIN EN 13779 und ASHRAE 62.1 |
| 2 | 1000–1400 | DIN EN 13779 Klasse „mittlere Innenraumluftqualität" |
| 3 | 1400–2000 | DIN EN 13779 Klasse „niedrige Innenraumluftqualität" |
| 4 | ≥ 2000 | UBA (Umweltbundesamt): „hygienisch inakzeptabel" |

**Quellen:**
- Max von Pettenkofer, *Über den Luftwechsel in Wohngebäuden*,
  München 1858. Immer noch die zitierte Referenz — die menschliche
  Physiologie hat sich in 168 Jahren nicht verändert.
- DIN EN 13779 (Lüftung von Nichtwohngebäuden — Anforderungen an
  Innenraumklima).
- Umweltbundesamt: *Leitwerte für die Innenraumluft: Kohlendioxid*
  (Bundesgesundheitsblatt 2008).

### PM2.5 (µg/m³, 24-h-Mittel)

| Klasse | µg/m³ | Herkunft |
|---|---|---|
| 0 | < 10 | WHO Interim Target 4 (IT-4) — das ambitionierteste Zwischenziel unterhalb der AQG |
| 1 | 10–15 | WHO Air Quality Guideline (AQG) 2021 = 15 µg/m³ für 24 h |
| 2 | 15–25 | WHO IT-3 = 25 µg/m³ |
| 3 | 25–37 | WHO IT-2 = 37.5 µg/m³ |
| 4 | ≥ 37 | oberhalb WHO IT-2 |

### PM10 (µg/m³, 24-h-Mittel)

| Klasse | µg/m³ | Herkunft |
|---|---|---|
| 0 | < 20 | WHO IT-4 |
| 1 | 20–45 | WHO AQG 2021 = 45 µg/m³ für 24 h |
| 2 | 45–75 | WHO IT-3 = 75 µg/m³ |
| 3 | 75–150 | WHO IT-2 = 100 µg/m³ (bis 150 = IT-1) |
| 4 | ≥ 150 | oberhalb WHO IT-1 |

**Quelle für PM2.5 und PM10:**
WHO Global Air Quality Guidelines, Genf 2021, Table 3.10.
<https://www.who.int/publications/i/item/9789240034228>

### Relative Luftfeuchtigkeit (%)

Symmetrisch um den Behaglichkeitsbereich 40–60 %: höhere Klasse
bedeutet weiter weg vom Optimum in beide Richtungen (zu trocken oder
zu feucht).

| Klasse | Bereich | Herkunft |
|---|---|---|
| 0 | 40–60 % | DIN EN ISO 7730 Behaglichkeitsbereich |
| 1 | 30–65 % | ASHRAE 55 erweiterter Komfortbereich |
| 2 | 25–70 % | Sensirion Anwendungshinweise für Innenräume |
| 3 | 20–75 % | ab hier Schleimhaut- bzw. Schimmelrisiko messbar |
| 4 | außerhalb | < 20 %: Austrocknung; > 75 %: Schimmelgefahr (Sedlbauer, Fraunhofer IBP 2001) |

**Quellen:**
- DIN EN ISO 7730 *„Ergonomie der thermischen Umgebung — Analytische
  Bestimmung und Interpretation der thermischen Behaglichkeit"*.
- ASHRAE Standard 55 *Thermal Environmental Conditions for Human
  Occupancy*.
- Klaus Sedlbauer, *Vorhersage von Schimmelpilzbildung auf und in
  Bauteilen*, Dissertation Fraunhofer IBP 2001.

---

## Empfehlungstexte

Drei Text-Sensoren fassen die vier Klassen in kurze deutsche/englische
Formulierungen. Alle drei folgen dem Prinzip: **die schlechteste
Einzelklasse bestimmt die Empfehlung.** Priorisierung in „Air Quality
Action" folgt der medizinischen Relevanz:

**PM2.5 > PM10 > CO₂ > Feuchte**

Warum diese Reihenfolge? Feine Partikel (< 2.5 µm) sind die einzige
gemessene Größe, die im Kurzzeit-Bereich (Stunden) messbar zu
Lungenerkrankungen führt (WHO 2021, Kapitel 2.1). CO₂ ist unter
2000 ppm nicht toxisch, macht aber müde. Feuchte ist ein
Langzeit-Thema (Schimmel).

### Air Quality Verdict

Ableitung: rein aus `AQI Overall Score`.

| Score | Deutsch | English |
|---|---|---|
| 0 | TOP | TOP |
| 1 | GUT | GOOD |
| 2 | MITTEL | FAIR |
| 3 | SCHLECHT | POOR |
| 4 | KRITISCH | CRITICAL |

### Air Quality Action

Priorisiert PM2.5, dann PM10, dann CO₂, dann Feuchte. Text richtet
sich nach der jeweiligen Klasse.

| Kanal | Klasse | Deutsch | English |
|---|---|---|---|
| PM2.5 | 4 | Reiniger MAX! | Purifier MAX! |
| PM2.5 | 3 | Luftreiniger an! | Purifier on! |
| PM2.5 | ≥ 2 | Feinstaub erhoeht | Fine dust up |
| PM10 | ≥ 3 | Grobstaub, lueften | Coarse dust, vent |
| PM10 | 2 | Grobstaub leicht | Coarse dust mild |
| CO₂ | ≥ 3 | Fenster auf! | Open window! |
| CO₂ | 2 | lueften waere gut | venting advised |
| Feuchte | zu feucht (Klasse ≥ 2, RH > 60 %) | zu feucht, lueften | too humid, vent |
| Feuchte | zu trocken (Klasse ≥ 2, RH ≤ 60 %) | zu trocken | too dry |
| Overall | 0 | alles gut | all good |

### Dust Action

Rein PM-basiert, für die Detailseite Feinstaub. Höhere Priorität hat
die Klasse mit dem höheren Score (PM2.5 vs. PM10).

| Kanal | Klasse | Deutsch | English |
|---|---|---|---|
| PM2.5 | 4 | Reiniger MAX, zu! | Purifier MAX, shut! |
| PM2.5 | 3 | Luftreiniger an! | Purifier on! |
| PM2.5 | 2 | Quelle? (Kochen?) | Source? (cooking?) |
| PM2.5 | 1 | leicht erhoeht | slightly elevated |
| PM2.5 | 0 | alles sauber | all clean |
| PM10 | 4 | stark staubig! | very dusty! |
| PM10 | 3 | Grobstaub, lueften | coarse dust, vent |
| PM10 | 2 | leicht staubig | slightly dusty |
| PM10 | 1 | minimal staubig | mildly dusty |
| PM10 | 0 | staubfrei | dust-free |

---

## Bewusste Design-Entscheidungen (keine Norm)

Ein paar Dinge in diesem Projekt sind **nicht** aus einer Norm
übernommen, sondern gezielt getroffen. Der Vollständigkeit halber:

1. **Temperatur wird nicht bewertet.** Grund: SCD41 im Gehäuse,
   2–6 °C Selbstheizung, jede Schwelle würde falschmelden.
2. **PM2.5 hat Priorität vor PM10 im „Action"-Text.** Weil kleinere
   Partikel medizinisch akuter relevant sind (WHO 2021 §2.1).
3. **Fünf Klassen (0–4).** WHO 2021 nutzt eigentlich vier Zwischenziele
   plus AQG (also fünf Stufen); wir bilden das auf 0–4 ab, damit eine
   klassische Ampel-Logik funktioniert.
4. **„Overall = worst of four".** Konservative Warnung > Mittelwert.
5. **PMS5003-Massewerte werden für den 60-s-Sensortakt eins-zu-eins
   gegen die 24-h-WHO-Grenzwerte verglichen.** Streng genommen sind
   die WHO-Werte 24-h-Mittelwerte; ein Sekundenwert kann von der
   24-h-Statistik abweichen. Für eine Warnleuchte („jetzt lüften!") ist
   das aber der praktikable Kompromiss — Nutzer würden sich schlecht
   fühlen, wenn ein Feinstaub-Peak beim Kochen erst 24 h später als
   solcher gekennzeichnet würde.

---

## Wo im Code steht was

Beim Fehlerbericht oder Fork bitte diese Fundstellen zitieren:

| Feature | Datei | Suchbegriff |
|---|---|---|
| Schwellen CO₂ | `firmware/source/air-quality-monitor.yaml` | `id: aqi_co2` |
| Schwellen PM2.5 | " | `id: aqi_pm25` |
| Schwellen PM10 | " | `id: aqi_pm10` |
| Schwellen Feuchte | " | `id: aqi_hum` |
| Overall-Berechnung | " | `id: aqi_overall` |
| Verdict-Text | " | `id: verdict_text` |
| Action-Text | " | `id: verdict_action` |
| Dust-Action-Text | " | `id: dust_action` |
| Kurzfassung der Schwellen | `README.md` | Section „AQI thresholds" |
