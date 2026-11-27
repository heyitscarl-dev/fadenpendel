final float STEP = 1.0 / (1000.0);
final float FORCE_SCALE = 0.075;
float accumulator = 0.0;
float speed = 1.0;

Environment initial = new Environment();
Environment env = new NewtonPendulum();
Camera cam = new Camera();
Display display = new Display();

UIOverlay defaultOverlay = new UIOverlay();
UIContainer controls = new UIContainer(new PVector(50, 50));
UIContainer values = new UIContainer(new PVector(50, 50));
Toggle btnDrawVelocities = new Toggle(false, "\\text{Velocities}");
Toggle btnDrawForces = new Toggle(false, "\\text{Forces}");
Toggle btnDrawQuantities = new Toggle(true, "\\text{Quantities}");
Toggle btnDrawContacts = new Toggle(true, "\\text{Contacts}");
Toggle btnAirResistance = new Toggle(true, "\\text{Drag}");

UIContainer ctnEditor = new UIContainer(new PVector(1280 - 117.0 - 50.0, 50));
Toggle btnEditor = new Toggle(false, "\\text{Edit}");

UIOverlay velocityOverlay = new UIOverlay();
UIOverlay forceOverlay = new UIOverlay();
UIOverlay quantityOverlay = new UIOverlay();
UIOverlay contactOverlay = new UIOverlay();

Selectable selected = null;

float simTime = 0.0;                  // vergangene Simulationszeit (s)
final float CONTACT_LIFETIME = 0.3;   // Sichtbarkeit eines Kontakts nach der letzten Berührung (s)

float last;

boolean running = false;
boolean doStep = false;

void setup() {
  // Initialisiert die UI
  controls.elements.add(btnDrawVelocities);
  controls.elements.add(btnDrawForces);
  controls.elements.add(btnDrawQuantities);
  controls.elements.add(btnDrawContacts);
  ctnEditor.elements.add(btnEditor);
  defaultOverlay.elements.add(controls);
  defaultOverlay.elements.add(ctnEditor);
  
  values.position.x += 50 + controls.dimensions(cam).x;
  values.elements.add(btnAirResistance);
  defaultOverlay.elements.add(values);

  size(1280, 800);
  pixelDensity(2);
  
  initial = env.copy();

  // Um dt (Δd; delta time), also die Zeitdifferenz der letzten Frames
  // zu berrechnen (wodurch die Simulation konstant und unabhängig von 
  // der Bildrate/FPS sein kann), muss der Zeitpunkt des letzten Frames 
  // gespeichert werden. `setup()` wird als "erster Frame" gewertet, damit
  // `last` nicht 0 ist, also `dt` nicht unrealistisch groß.
  last = millis();
}

void draw() {
  float now = millis();
  float dt = (now - last) / 1000.0;  // Δd/Zeitdifferenz der letzten Frames
  last = now;

  // Δd wird auf maximal 100 ms beschränkt, damit sehr großes "Stottern" der Bildrate
  // oder eine extrem niedrige Bildrate nicht zu einem unaufholbaren Vorsprung kommt.
  dt = min(dt, 0.1); 
  
  // 240 Steps pro Sekunde. Pro Frame werden alle Steps "aufgeholt", die während Δd hätten
  // passieren müssen.
  accumulator += speed * dt;
  while (accumulator >= STEP) {
    tick(STEP / speed); // (siehe Sketch/Simulation.pde)
    accumulator -= STEP / speed;
  }

  background(THEME_BACKGROUND);
  if (btnEditor.state) cam.drawGrid();
  if (btnEditor.state) running = false;

  display.draw(cam);
  cam.enter();

  if (btnDrawForces.state) {
    forceOverlay.drawToScreen(cam);
  }
  if (btnDrawVelocities.state) {
    velocityOverlay.drawToScreen(cam);
  }
  if (btnDrawQuantities.state) {
    quantityOverlay.drawToScreen(cam);
  }
  if (btnDrawContacts.state) {
    contactOverlay.drawToScreen(cam);
  }

  cam.leave();

  defaultOverlay.drawToScreen(cam);
}

Body getBodyAt(PVector world) {
  for (Body b : env.bodies) {
    float distance = PVector.dist(world, b.position());
    if (distance <= b.radius) {
      return b;
    }
  }
  return null;
}

Spring getSpringAt(PVector world) {
  for (Spring s : env.springs) {
    PVector a = s.a.position;
    PVector b = s.b.position;

    PVector directionSpring = PVector.sub(b, a);
    directionSpring.normalize();

    PVector directionMouse = PVector.sub(world, a);
    float t = PVector.dot(directionSpring, directionMouse);
    
    PVector point = PVector.add(a, PVector.mult(directionSpring, t));
    float dist = PVector.dist(point, world);

    float gap = 0.4;
    if (dist < gap && t > -gap && t < s.length() + gap) {
      return s;
    }
  }
  return null;
}

void mousePressed() {
  PVector mouseScreen = new PVector(mouseX, mouseY);
  if (defaultOverlay.handleClick(cam, mouseScreen)) return;
  PVector mouseWorld = cam.screenToWorld(mouseScreen);
  selected = getBodyAt(mouseWorld);
  if (selected != null) return;
  selected = getSpringAt(mouseWorld);
}

void mouseDragged() {
  if (btnEditor.state && selected instanceof Body) {
    Body b = (Body) selected;
    PVector mouse = cam.screenToWorld(new PVector(mouseX, mouseY));
    PVector updated = (keyCode == SHIFT && keyPressed) ? mouse : cam.closestGridPoint(mouse);
    b.position = updated;
    return;
  }
  cam.handleDrag();
}

void mouseWheel(MouseEvent e) {
  float c = e.getCount();
  cam.zoom *= pow(1.05, -c);
}

void keyPressed() {
  if (key == ' ' && !btnEditor.state) {
    running = !running;
  }

  if (key == 'r') {
    env = initial.copy();
    running = false;
    contactOverlay.elements.clear();
    simTime = 0;
  }

  // Szenario wechseln (siehe Sketch/Scenarios.pde)
  if (key >= '1' && key <= '9') {
    Environment scenario = createScenario(key - '0');
    if (scenario != null) {
      env = scenario;
      initial = env.copy();
      running = false;
      contactOverlay.elements.clear();
      simTime = 0;
      selected = null;
    }
  }

  if (!running && keyCode == ENTER) {
    doStep = true;
  }

  if (keyCode == TAB) {
    btnEditor.state = !btnEditor.state;
  }
}