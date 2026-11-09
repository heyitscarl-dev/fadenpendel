# Fadenpendel Projekt
## Features (Geplant)

- Kräftepfeile
- Energie
- Geschwindigkeit
- Zeit
- Periodendauer
- Frequenz

- x(t) und y(t) plotten, mit Berücksichtigung der anderen Physikalischen Größen

## Notizen

- t als fortlaufender Wert ab Start

## Größen und Formeln

### Definierte Werte
- m = Definierter Wert
- l = Definierter Wert
- g = Definierter Wert
- Amplitude = Definierter Wert
- Startauslenkung = Definierter Wert

### Periode und Frequenz
- T =  2pi*Wurzel(l/g)
- f = 1/T

### Geschwindigkeiten
- Winkelgeschwindigkeit = Wurzel(g/l)
- Bahngeschwindigkeit = Winkelgeschwindigkeit * r

### Auslenkung
- y(t) =  Amplitude * sin(Wurzel(l/g) * t + Startauslenkung)
- Potenzielle Energie = m * g * y(t)
- Winkel Amplitude: arcsin(Amplitude/länge)
- x(t) = Winkel Amplitude  * cos(Wurzel(g/l) * t)

### Kräfte

- F = m * a
- Fg = m * g
- Ftan = sin(phi) * l
- Frück = -m * g * sin(phi) = -((m * g)/l) * s {mit s = l * phi [Bogenlänge]}
- Fr = Fz - Fg
- Fz = m * v^2/r  // Fz = m * Winkelgeschwindigkeit * r
