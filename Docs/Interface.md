# Interface

Das Interface (UI) ist auf drei Ebenen gegliedert:

1. Overlay
2. Container
3. Element

Die gliederung in "Overlays", erlaubt es einzelne Komponenten der UI ein oder auszuschalten. So können z.B. Kräftepfeile bestehen bleiben, während Geschwindigkeiten o.ä. ausgeblendet werden.

Container bilden die nächste Ebene. Sie bündeln einzelne Elemente in größere, zusammenhängende Einheiten _(optional)_.

Die letzte Ebene bilden die Elemente. Sie sind z.B. Kräftepfeile oder Labels, aber auch Knöpfe oder Text.

## Objektorientierter Ansatz

`Overlay` und `Container` wurden als Klassen modelliert. `Element` ist hingegen ein `interface`, da unterschiedliche Elemente potentiell sehr verschieden voneinander sein könnten, und nur durch das ähnliche Rendering vereint werden.