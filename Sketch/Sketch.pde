final float STEP = 1.0 / 240.0;
final float FORCE_SCALE = 0.075;
float accumulator = 0.0;

Environment env = new Environment();
Camera cam = new Camera();
Display display = new Display();

float last;

boolean running = true;
boolean doStep = false;

void setup() {
  size(1280, 800);
  pixelDensity(2);

  Body body = new Body(1.0, 0.25, true);
  body.setPosition(new PVector(0, 2.5));
  env.addBody(body);

  Body dragged = new Body(1.0, 0.25, false);
  dragged.setPosition(new PVector(-2.5, 2.5));
  env.addBody(dragged);

  Spring spring = new Spring(500.0, body, dragged);
  env.addSpring(spring);
  
  last = millis();
}

void tick(float dt) {
  if (!running && !doStep) return;
  if (doStep) doStep = false;

  for (Spring spring : env.getSprings()) {
    Force[] forces = spring.forces(new String[]{
      "|F_D|=%v\\,\\mathrm{N}",
      "|F_D|=%v\\,\\mathrm{N}"
    });

    spring.b.applyForce(forces[0]);
    spring.a.applyForce(forces[1]);
  }

  for (Body body : env.getBodies()) {    
    if (body.fixed) {
      body.clearForces();
      continue;
    }

    // Kräfte
    body.forces.add(new Force(
      body.position,
      new PVector(0.0, -env.gravity * body.mass),
      "|F_g|=" + env.gravity * body.mass + "\\,\\mathrm{N}"
    )); // Gewichtskraft

    float velocity = body.velocity.mag();
    float dragFactor = -0.5 * 1.204 * 0.4 * 0.0491 * velocity;
    PVector drag = PVector.mult(body.velocity, dragFactor);
    body.forces.add(new Force(
      body.position,
      drag,
      "|F_L|=" + round(drag.mag()*10)/10.0 + "\\,\\mathrm{N}"
    )); // Luftwiderstand

    // Resultierende Kraft berechnen 
    PVector res = new PVector(0.0, 0.0);
    for (Force f : body.forces) {
      res = res.add(f.getVector());
    }
    
    body.clearForces();

    // Beschleunigung
    PVector a = res.div(body.mass);
    
    // Geschwindigkeits aenderung
    PVector dv = a.mult(dt);

    //Geschwindigkeits aenderung auf Geschwindigkeit addieren
    body.velocity = body.velocity.add(dv);
    
    // Zurueckgelegte Strecke
    PVector dp = PVector.mult(body.velocity, dt);
    
    // Neue Position
    body.position = body.position.add(dp);
  }
}

void draw() {
  display.draw(cam);
}

void mouseDragged() {
  cam.handleDrag();
}

void mouseWheel(MouseEvent e) {
  float c = e.getCount();
  cam.zoom *= pow(1.05, -c);
}

void keyPressed() {
  if (key == ' ') {
    running = !running;
  }

  if (!running && keyCode == ENTER) {
    doStep = true;
  }
}