// Weitere Szenarien. Jedes Szenario ist eine Unterklasse von Environment
// und baut im Konstruktor seine Körper und Federn auf.
//
// Wichtig: Federn bestimmen ihre Ruhelänge aus den Positionen beim Erzeugen.
// Soll ein Körper ausgelenkt starten, wird er also entweder schon ausgelenkt
// erzeugt (Faden bleibt so lang wie gewollt) oder erst *nach* dem Erzeugen
// der Feder verschoben (Feder ist dann gespannt).
//
// Koordinaten: Ursprung in der Bildmitte, y zeigt nach oben, 1 = 1 m.
// Sichtbar sind ungefähr x ∈ [-12.8, 12.8] und y ∈ [-8, 8].

class Scenario extends Environment {
  int anchors = 0;

  // Fester Aufhängepunkt
  Body anchor(float x, float y) {
    Body a = new Body("a_" + anchors++, 1.0, 0.25, true);
    a.setPosition(new PVector(x, y));
    addBody(a);
    return a;
  }

  // Beweglicher Körper
  Body mass(String name, float m, float r, PVector position) {
    Body b = new Body(name, m, r, false);
    b.setPosition(position);
    addBody(b);
    return b;
  }

  // Punkt im Abstand `length` unter `origin`, um `angle` Grad aus der
  // Senkrechten ausgelenkt (positiv = nach rechts).
  PVector hanging(Body origin, float length, float angle) {
    float t = radians(angle);
    return new PVector(
      origin.position.x + length * sin(t),
      origin.position.y - length * cos(t)
    );
  }

  Spring thread(Body a, Body b) {
    Spring s = new Spring(THREAD_STIFFNESS, a, b);
    addSpring(s);
    return s;
  }

  Spring spring(float stiffness, Body a, Body b) {
    Spring s = new Spring(stiffness, a, b);
    addSpring(s);
    return s;
  }
}

// 1) Einfaches Fadenpendel, um 30° ausgelenkt.
class SimplePendulum extends Scenario {
  SimplePendulum() {
    Body a = anchor(0, 3);
    Body m = mass("m", 1.0, 0.25, hanging(a, 4, 30));
    thread(a, m);
  }
}

// 2) Doppelpendel: zwei Fäden hintereinander, chaotische Bewegung.
class DoublePendulum extends Scenario {
  DoublePendulum() {
    Body a = anchor(0, 2);
    Body m1 = mass("m_1", 1.0, 0.2, hanging(a, 2.5, 120));
    Body m2 = mass("m_2", 1.0, 0.2, hanging(m1, 2.5, 160));
    thread(a, m1);
    thread(m1, m2);
  }
}

// 3) Elastisches Pendel: Masse an einer weichen Feder statt an einem Faden.
//    Pendel- und Federschwingung tauschen Energie aus.
class ElasticPendulum extends Scenario {
  ElasticPendulum() {
    Body a = anchor(0, 4);
    Body m = mass("m", 1.0, 0.25, hanging(a, 3, 50));
    spring(25, a, m);
  }
}

// 4) Gekoppelte Pendel: zwei gleiche Fadenpendel, deren Massen über eine
//    weiche Feder verbunden sind. Die Energie wandert hin und her (Schwebung).
class CoupledPendulums extends Scenario {
  CoupledPendulums() {
    Body a1 = anchor(-1.5, 3);
    Body a2 = anchor(1.5, 3);
    Body m1 = mass("m_1", 1.0, 0.25, hanging(a1, 4, 0));
    Body m2 = mass("m_2", 1.0, 0.25, hanging(a2, 4, 0));
    thread(a1, m1);
    thread(a2, m2);
    spring(8, m1, m2); // Ruhelänge = Abstand in der Ruhelage

    // Erst jetzt auslenken, damit die Kopplungsfeder ihre Ruhelänge
    // aus der Ruhelage bekommt. Die Fadenlänge bleibt dabei gleich.
    m1.setPosition(hanging(a1, 4, -20));
  }
}

// 5) Vertikaler Federschwinger: Masse an einer Feder, startet entspannt
//    und schwingt um die durch die Gewichtskraft gedehnte Lage.
class SpringOscillator extends Scenario {
  SpringOscillator() {
    Body a = anchor(0, 4);
    Body m = mass("m", 1.0, 0.25, hanging(a, 2, 0));
    spring(40, a, m);
  }
}

// 6) Kette: mehrere Massen, verbunden durch Fäden, waagerecht an einem
//    Punkt aufgehängt. Fällt herunter und schwingt wie ein Seil.
//    Massen unter ca. 0,75 kg machen die steifen Fäden bei STEP = 1 ms
//    instabil, deshalb 1 kg pro Glied.
class Chain extends Scenario {
  Chain() {
    Body previous = anchor(-4, 3);
    for (int i = 1; i <= 8; i++) {
      Body m = mass("m_" + i, 1.0, 0.15, new PVector(-4 + i * 0.8, 3));
      if (i == 4 || i == 5) {
        m.velocity = new PVector(0, 2.0);
      }
      thread(previous, m);
      previous = m;
    }
  }
}

// 7) Stoß ungleicher Massen: eine schwere Kugel trifft eine leichte,
//    die in Ruhe direkt daneben hängt.
class UnequalCollision extends Scenario {
  UnequalCollision() {
    float r1 = 0.4;
    float r2 = 0.25;
    float gap = 0.01; // kleiner Abstand, damit die Kugeln sich am Start nicht berühren

    Body a1 = anchor(0, 3);
    Body a2 = anchor(r1 + r2 + gap, 3);
    Body heavy = mass("m_1", 3.0, r1, hanging(a1, 4, -40));
    Body light = mass("m_2", 1.0, r2, hanging(a2, 4, 0));
    thread(a1, heavy);
    thread(a2, light);
  }
}

// Erzeugt das Szenario mit der Nummer `index` (Taste 1–8).
Environment createScenario(int index) {
  switch (index) {
    case 1: return new NewtonPendulum();
    case 2: return new SimplePendulum();
    case 3: return new DoublePendulum();
    case 4: return new ElasticPendulum();
    case 5: return new CoupledPendulums();
    case 6: return new SpringOscillator();
    case 7: return new Chain();
    case 8: return new UnequalCollision();
    default: return null;
  }
}
